local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

local Preview = {}
local active = setmetatable({}, {__mode = "k"})

local VIOLET = Color3.fromRGB(185, 52, 255)
local HOT = Color3.fromRGB(246, 186, 255)
local ORDER = {
	{"Left", "Inner", -1, 1}, {"Right", "Inner", 1, 1},
	{"Left", "Outer", -1, 2}, {"Right", "Outer", 1, 2},
	{"Left", "Lower", -1, 3}, {"Right", "Lower", 1, 3},
}

local function effectsFolder()
	local folder = workspace:FindFirstChild("SovereignRuntimeEffects")
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "SovereignRuntimeEffects"
		folder.Parent = workspace
	end
	return folder
end

local function targetPosition(model, target)
	if target and target:IsA("BasePart") then return target.Position end
	if target and target:IsA("Model") then
		for _, name in ipairs({"UpperTorso", "Torso", "HumanoidRootPart"}) do
			local part = target:FindFirstChild(name, true)
			if part and part:IsA("BasePart") then return part.Position end
		end
		local boxCFrame, boxSize = target:GetBoundingBox()
		return boxCFrame.Position + Vector3.new(0, boxSize.Y * 0.05, 0)
	end
	local root = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
	return root.Position + root.CFrame.LookVector * 92 + root.CFrame.UpVector * 22
end

local function droneModel(model, side, position)
	local item = model:FindFirstChild(side .. "Drone" .. position, true)
	return item and item:IsA("Model") and item or nil
end

local function droneMotor(model, side, position)
	local item = model:FindFirstChild(side .. "Drone" .. position .. "Mount", true)
	return item and item:IsA("Motor6D") and item or nil
end

local function worldC0(motor, worldCFrame)
	return motor.Part0.CFrame:ToObjectSpace(worldCFrame) * motor.C1
end

local function moveTo(motor, worldCFrame, duration, style)
	local tween = TweenService:Create(motor, TweenInfo.new(
		duration, style or Enum.EasingStyle.Quad, Enum.EasingDirection.InOut
	), {C0 = worldC0(motor, worldCFrame)})
	tween:Play()
	return tween
end

local function pulse(position, startSize, endSize, lifetime)
	local part = Instance.new("Part")
	part.Name = "HunterDronePulse"
	part.Shape = Enum.PartType.Ball
	part.Size = Vector3.new(startSize, startSize, startSize)
	part.Position = position
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Material = Enum.Material.ForceField
	part.Color = VIOLET
	part.Transparency = 0.12
	part.Parent = effectsFolder()
	Debris:AddItem(part, lifetime)
	TweenService:Create(part, TweenInfo.new(lifetime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = Vector3.new(endSize, endSize, endSize), Transparency = 1,
	}):Play()
end

local function laser(start, finish)
	local delta = finish - start
	if delta.Magnitude < 1 then return end
	local beam = Instance.new("Part")
	beam.Name = "HunterDroneStrike"
	beam.Size = Vector3.new(0.65, 0.65, delta.Magnitude)
	beam.CFrame = CFrame.lookAt((start + finish) * 0.5, finish)
	beam.Anchored = true
	beam.CanCollide = false
	beam.CanTouch = false
	beam.CanQuery = false
	beam.Material = Enum.Material.Neon
	beam.Color = HOT
	beam.Transparency = 0.02
	beam.Parent = effectsFolder()
	Debris:AddItem(beam, 0.32)
	TweenService:Create(beam, TweenInfo.new(0.28), {
		Size = Vector3.new(0.08, 0.08, delta.Magnitude), Transparency = 1,
	}):Play()
end

local function marker(targetPoint, lifetime)
	local node = Instance.new("Part")
	node.Name = "HunterTargetMarker"
	node.Shape = Enum.PartType.Ball
	node.Size = Vector3.new(2.2, 2.2, 2.2)
	node.Position = targetPoint
	node.Anchored = true
	node.CanCollide = false
	node.CanTouch = false
	node.CanQuery = false
	node.Material = Enum.Material.Neon
	node.Color = VIOLET
	node.Transparency = 0.08
	node.Parent = effectsFolder()
	Debris:AddItem(node, lifetime)
	local light = Instance.new("PointLight")
	light.Color = VIOLET
	light.Brightness = 5
	light.Range = 28
	light.Shadows = false
	light.Parent = node
	return node
end

local function dronePosition(motor)
	return motor.Part1 and motor.Part1.Position or motor.Part0.Position
end

function Preview.Play(model, target)
	if not model or active[model] then return false end
	local root = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
	if not root or not root:IsA("BasePart") then return false end

	local drones = {}
	for index, definition in ipairs(ORDER) do
		local side, position, sign, tier = table.unpack(definition)
		local motor = droneMotor(model, side, position)
		local drone = droneModel(model, side, position)
		if not motor or not motor.Part0 or not motor.Part1 or not drone then
			warn("Missing Sovereign Hunter Drone rig:", side, position)
			return false
		end
		drones[index] = {
			Side = side, Position = position, Sign = sign, Tier = tier,
			Motor = motor, Model = drone, Neutral = motor.C0,
		}
	end

	local token = {}
	active[model] = token
	model:SetAttribute("SovereignDroneDeploymentActive", true)
	model:SetAttribute("SovereignWingInertiaSuspended", true)
	local targetPoint = targetPosition(model, target)
	local forward = root.CFrame.LookVector
	local right = root.CFrame.RightVector
	local up = root.CFrame.UpVector
	local focus

	for index, drone in ipairs(drones) do
		task.delay((index - 1) * 0.16, function()
			if active[model] ~= token then return end
			drone.Model:SetAttribute("Docked", false)
			local launch = root.Position + right * drone.Sign * (12 + drone.Tier * 4)
				+ up * (22 + (4 - drone.Tier) * 3) + forward * 18
			moveTo(drone.Motor, CFrame.lookAt(launch, targetPoint), 0.82, Enum.EasingStyle.Quart)
			pulse(dronePosition(drone.Motor), 1.2, 5.5, 0.48)
		end)
	end

	task.delay(1.65, function()
		if active[model] ~= token then return end
		focus = marker(targetPoint, 6.5)
		for index, drone in ipairs(drones) do
			local angle = math.rad(-150 + (index - 1) * 60)
			local radius = 34 + (index % 2) * 5
			local orbit = targetPoint + right * math.sin(angle) * radius
				- forward * math.cos(angle) * radius + up * (10 + (index % 3) * 5)
			drone.Orbit = CFrame.lookAt(orbit, targetPoint)
			moveTo(drone.Motor, drone.Orbit, 1.05, Enum.EasingStyle.Quad)
		end
	end)

	task.delay(2.78, function()
		if active[model] ~= token then return end
		pulse(targetPoint, 3, 18, 0.5)
		for _, drone in ipairs(drones) do laser(dronePosition(drone.Motor), targetPoint) end
	end)

	-- Three paired attack waves cross the target from alternating directions.
	for wave = 1, 3 do
		task.delay(3.35 + (wave - 1) * 1.12, function()
			if active[model] ~= token then return end
			for _, index in ipairs({wave * 2 - 1, wave * 2}) do
				local drone = drones[index]
				local diveOffset = right * drone.Sign * 5 + up * (3 + wave * 1.5) - forward * 6
				moveTo(drone.Motor, CFrame.lookAt(targetPoint + diveOffset, targetPoint), 0.52, Enum.EasingStyle.Quart)
				task.delay(0.5, function()
					if active[model] ~= token then return end
					laser(dronePosition(drone.Motor), targetPoint)
					pulse(targetPoint, 2.5, 9 + wave * 2, 0.35)
					moveTo(drone.Motor, drone.Orbit, 0.62, Enum.EasingStyle.Quad)
				end)
			end
		end)
	end

	task.delay(7.0, function()
		if active[model] ~= token then return end
		if focus and focus.Parent then focus:Destroy() end
		for index = #drones, 1, -1 do
			local drone = drones[index]
			task.delay((#drones - index) * 0.13, function()
				if active[model] ~= token then return end
				local tween = TweenService:Create(drone.Motor, TweenInfo.new(
					0.9, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut
				), {C0 = drone.Neutral})
				tween:Play()
			end)
		end
	end)

	task.delay(9.0, function()
		if active[model] ~= token then return end
		for _, drone in ipairs(drones) do
			drone.Motor.C0 = drone.Neutral
			drone.Model:SetAttribute("Docked", true)
		end
		model:SetAttribute("SovereignDroneDeploymentActive", false)
		model:SetAttribute("SovereignWingInertiaSuspended", false)
		active[model] = nil
	end)
	return true
end

return Preview
