local RunService = game:GetService("RunService")

local Inertia = {}
local active = setmetatable({}, {__mode = "k"})

local function clampVector(value, limit)
	return Vector3.new(
		math.clamp(value.X, -limit, limit),
		math.clamp(value.Y, -limit, limit),
		math.clamp(value.Z, -limit, limit)
	)
end

function Inertia.Ensure(model)
	if not model or active[model] then return end
	local torso = model:FindFirstChild("UpperTorso")
	local joint = model:FindFirstChild("HeavyRailCannonInertia", true)
	if not torso or not joint or not joint:IsA("Motor6D") then return end

	local state = {
		previous = torso.CFrame,
		offset = Vector3.zero,
		rotation = Vector3.zero,
	}
	active[model] = state

	local connection
	connection = RunService.RenderStepped:Connect(function(deltaTime)
		if not model.Parent or not joint.Parent or not torso.Parent then
			connection:Disconnect()
			active[model] = nil
			return
		end
		deltaTime = math.clamp(deltaTime, 1 / 240, 1 / 20)
		local current = torso.CFrame
		local relative = state.previous:ToObjectSpace(current)
		local rx, ry, rz = relative:ToOrientation()
		local localTravel = current:VectorToObjectSpace(current.Position - state.previous.Position)

		-- Counter-motion gives the cannon a restrained, heavy delay. Limits keep
		-- it mounted firmly instead of making it look loose or rubbery.
		local targetRotation = Vector3.new(
			math.clamp(-rx * 2.8, -0.07, 0.07),
			math.clamp(-ry * 3.2, -0.09, 0.09),
			math.clamp(-rz * 2.4, -0.055, 0.055)
		)
		local targetOffset = clampVector(-localTravel * 0.22, 0.32)
		local follow = 1 - math.exp(-deltaTime / 0.16)
		local settle = 1 - math.exp(-deltaTime / 0.24)
		state.rotation = state.rotation:Lerp(targetRotation, follow)
		state.offset = state.offset:Lerp(targetOffset, settle)
		joint.Transform = CFrame.new(state.offset)
			* CFrame.Angles(state.rotation.X, state.rotation.Y, state.rotation.Z)
		state.previous = current
	end)
end

return Inertia
