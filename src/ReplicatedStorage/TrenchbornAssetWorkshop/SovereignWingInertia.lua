local RunService = game:GetService("RunService")

local Inertia = {}
local active = setmetatable({}, {__mode = "k"})

local DRONE_LEVELS = {
	Inner = 0.35,
	Outer = 0.72,
	Lower = 1.0,
}

local function findMotor(model, name)
	local item = model:FindFirstChild(name, true)
	return item and item:IsA("Motor6D") and item or nil
end

local function collectMotors(model)
	local result = {}
	for _, side in ipairs({"Left", "Right"}) do
		local root = findMotor(model, side .. "DroneWingRootMount")
		if not root then return nil end
		result[side] = {Root = root, Drones = {}}
		for position in pairs(DRONE_LEVELS) do
			local drone = findMotor(model, side .. "Drone" .. position .. "Mount")
			if not drone then return nil end
			result[side].Drones[position] = drone
		end
	end
	return result
end

function Inertia.Ensure(model)
	if not model or active[model] then return end
	if model:GetAttribute("AssetName") ~= "Sovereign-V Apex" then return end
	local torso = model:FindFirstChild("UpperTorso")
	local motors = collectMotors(model)
	if not torso or not torso:IsA("BasePart") or not motors then return end

	local state = {
		Previous = torso.CFrame,
		Fold = 0,
		Turn = 0,
		Lift = 0,
		Neutral = {},
	}
	for side, group in pairs(motors) do
		state.Neutral[group.Root] = group.Root.C0
		for _, motor in pairs(group.Drones) do state.Neutral[motor] = motor.C0 end
	end
	active[model] = state
	model:SetAttribute("SovereignWingInertiaReady", true)

	local connection
	connection = RunService.RenderStepped:Connect(function(deltaTime)
		if not model.Parent or not torso.Parent then
			connection:Disconnect()
			for motor, neutral in pairs(state.Neutral) do
				if motor.Parent then motor.C0 = neutral end
			end
			active[model] = nil
			return
		end

		deltaTime = math.clamp(deltaTime, 1 / 240, 1 / 20)
		local current = torso.CFrame
		-- Deployment owns the six drone motors on the server. Leaving their C0
		-- untouched here prevents client-side inertia from snapping them to dock.
		if model:GetAttribute("SovereignDroneDeploymentActive") == true then
			state.Previous = current
			return
		end
		local relative = state.Previous:ToObjectSpace(current)
		local _, yaw = relative:ToOrientation()
		local localTravel = current:VectorToObjectSpace(current.Position - state.Previous.Position)
		local planarTravel = Vector2.new(localTravel.X, localTravel.Z).Magnitude
		local suspended = model:GetAttribute("SovereignWingInertiaSuspended") == true
		local defeated = model:GetAttribute("SovereignWingDefeated") == true

		local idleLift = (suspended or defeated) and 0 or math.sin(os.clock() * 0.9) * math.rad(3.2)
		local targetFold = defeated and math.rad(7)
			or (suspended and 0 or math.rad(math.clamp(planarTravel * 16, 0, 11)))
		local targetTurn = (suspended or defeated) and 0
			or math.clamp(-yaw * 6.0, math.rad(-12), math.rad(12))
		local targetLift = defeated and math.rad(-17)
			or (suspended and 0 or idleLift + math.clamp(-localTravel.Y * 0.2, math.rad(-5.5), math.rad(5.5)))
		local rootFollow = 1 - math.exp(-deltaTime / 0.3)
		state.Fold += (targetFold - state.Fold) * rootFollow
		state.Turn += (targetTurn - state.Turn) * rootFollow
		state.Lift += (targetLift - state.Lift) * (1 - math.exp(-deltaTime / 0.42))

		for side, group in pairs(motors) do
			local sign = side == "Right" and 1 or -1
			group.Root.C0 = state.Neutral[group.Root]
				* CFrame.Angles(0, -sign * state.Fold + state.Turn * 0.38, sign * state.Lift)
			for position, motor in pairs(group.Drones) do
				local response = DRONE_LEVELS[position]
				local secondaryLift = defeated and 0
					or math.sin(os.clock() * 0.9 - response * 0.65) * math.rad(1.25) * response
				motor.C0 = state.Neutral[motor]
					* CFrame.Angles(
						0,
						-sign * state.Fold * response * 0.55 + state.Turn * response,
						sign * (state.Lift * response * 0.75 + secondaryLift)
					)
			end
		end
		state.Previous = current
	end)
end

function Inertia.Suspend(model, suspended)
	if model then model:SetAttribute("SovereignWingInertiaSuspended", suspended == true) end
end

return Inertia
