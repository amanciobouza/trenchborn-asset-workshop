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

local function lockEnvelope(model, target, up)
	local aimPoint = targetPosition(model, target)
	if target and target:IsA("BasePart") then
		local height = math.max(32, target.Size.Y + 8)
		local lowerCenter = target.Position - up * (target.Size.Y * 0.5) + up * 4
		return aimPoint, lowerCenter, height
	end
	if target and target:IsA("Model") then
		local boxCFrame, boxSize = target:GetBoundingBox()
		local height = math.max(36, boxSize.Y + 8)
		local lowerCenter = boxCFrame.Position - up * (boxSize.Y * 0.5) + up * 4
		return aimPoint, lowerCenter, height
	end
	return aimPoint, aimPoint - up * 4, 36
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

local function energyLink(part0, part1, lifetime)
	local attachment0 = Instance.new("Attachment")
	attachment0.Name = "SovereignLockLinkA"
	attachment0.Parent = part0
	local attachment1 = Instance.new("Attachment")
	attachment1.Name = "SovereignLockLinkB"
	attachment1.Parent = part1
	local beam = Instance.new("Beam")
	beam.Name = "SovereignLockEdge"
	beam.Attachment0 = attachment0
	beam.Attachment1 = attachment1
	beam.Color = ColorSequence.new(HOT, VIOLET)
	beam.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.05),
		NumberSequenceKeypoint.new(0.55, 0.22),
		NumberSequenceKeypoint.new(1, 0.05),
	})
	beam.Width0 = 1.5
	beam.Width1 = 1.5
	beam.LightEmission = 1
	beam.LightInfluence = 0
	beam.FaceCamera = true
	beam.Parent = effectsFolder()
	Debris:AddItem(beam, lifetime)
	Debris:AddItem(attachment0, lifetime)
	Debris:AddItem(attachment1, lifetime)
	return beam
end

local function barrierPanel(point0, point1, height, lifetime)
	local edge = point1 - point0
	local horizontal = Vector3.new(edge.X, 0, edge.Z)
	if horizontal.Magnitude < 1 then return nil end
	local xAxis = horizontal.Unit
	local yAxis = Vector3.yAxis
	local zAxis = xAxis:Cross(yAxis)
	local midpoint = (point0 + point1) * 0.5 + Vector3.new(0, height * 0.5, 0)
	local panel = Instance.new("Part")
	panel.Name = "SovereignLockBarrier"
	panel.Size = Vector3.new(horizontal.Magnitude, height, 0.35)
	panel.CFrame = CFrame.fromMatrix(midpoint, xAxis, yAxis, zAxis)
	panel.Anchored = true
	panel.CanCollide = false
	panel.CanTouch = false
	panel.CanQuery = false
	panel.Material = Enum.Material.ForceField
	panel.Color = VIOLET
	panel.Transparency = 0.88
	panel.Parent = effectsFolder()
	Debris:AddItem(panel, lifetime)
	return panel
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

function Preview.PlayLock(model, target)
	if not model or active[model] then return false end
	local root = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
	if not root or not root:IsA("BasePart") then return false end

	local drones = {}
	for index, definition in ipairs(ORDER) do
		local side, position = definition[1], definition[2]
		local motor = droneMotor(model, side, position)
		local drone = droneModel(model, side, position)
		if not motor or not motor.Part0 or not motor.Part1 or not drone then
			warn("Missing Sovereign Lock drone rig:", side, position)
			return false
		end
		drones[index] = {Motor = motor, Model = drone, Neutral = motor.C0}
	end

	local token = {}
	active[model] = token
	model:SetAttribute("SovereignDroneDeploymentActive", true)
	model:SetAttribute("SovereignWingInertiaSuspended", true)
	model:SetAttribute("SovereignLockPreviewActive", true)
	local right = root.CFrame.RightVector
	local forward = root.CFrame.LookVector
	local up = root.CFrame.UpVector
	local targetPoint, lowerCenter, prismHeight = lockEnvelope(model, target, up)
	local radius = 42
	local vertices = {}

	-- Every consecutive L/R pair occupies the lower and upper point of one
	-- corner, producing six drone anchors and nine true triangular-prism edges.
	for pair = 1, 3 do
		local angle = math.rad((pair - 1) * 120 + 30)
		local radial = right * math.cos(angle) * radius - forward * math.sin(angle) * radius
		vertices[pair * 2 - 1] = lowerCenter + radial
		vertices[pair * 2] = lowerCenter + radial + up * prismHeight
	end

	for index, drone in ipairs(drones) do
		task.delay((index - 1) * 0.16, function()
			if active[model] ~= token then return end
			drone.Model:SetAttribute("Docked", false)
			moveTo(drone.Motor, CFrame.lookAt(vertices[index], targetPoint), 1.15, Enum.EasingStyle.Quart)
			pulse(dronePosition(drone.Motor), 1.2, 5.5, 0.48)
		end)
	end

	local fieldObjects = {}
	task.delay(2.1, function()
		if active[model] ~= token then return end
		for _, edge in ipairs({
			{1, 3}, {3, 5}, {5, 1},
			{2, 4}, {4, 6}, {6, 2},
			{1, 2}, {3, 4}, {5, 6},
		}) do
			table.insert(fieldObjects, energyLink(
				drones[edge[1]].Motor.Part1,
				drones[edge[2]].Motor.Part1,
				4.65
			))
		end
		for _, edge in ipairs({{1, 3}, {3, 5}, {5, 1}}) do
			local panel = barrierPanel(vertices[edge[1]], vertices[edge[2]], prismHeight, 4.65)
			if panel then table.insert(fieldObjects, panel) end
		end
		pulse(targetPoint, 4, 28, 0.65)
		if target then
			local highlight = Instance.new("Highlight")
			highlight.Name = "SovereignLockTarget"
			highlight.Adornee = target
			highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			highlight.FillColor = VIOLET
			highlight.OutlineColor = HOT
			highlight.FillTransparency = 0.82
			highlight.OutlineTransparency = 0.12
			highlight.Parent = effectsFolder()
			Debris:AddItem(highlight, 4.65)
			table.insert(fieldObjects, highlight)
		end
	end)

	task.delay(6.45, function()
		if active[model] ~= token then return end
		for _, object in ipairs(fieldObjects) do
			if object and object.Parent then
				if object:IsA("Beam") then
					object.Enabled = false
				elseif object:IsA("BasePart") then
					TweenService:Create(object, TweenInfo.new(0.25), {Transparency = 1}):Play()
				elseif object:IsA("Highlight") then
					object.Enabled = false
				end
			end
		end
	end)

	task.delay(6.7, function()
		if active[model] ~= token then return end
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

	task.delay(8.7, function()
		if active[model] ~= token then return end
		for _, drone in ipairs(drones) do
			drone.Motor.C0 = drone.Neutral
			drone.Model:SetAttribute("Docked", true)
		end
		model:SetAttribute("SovereignLockPreviewActive", false)
		model:SetAttribute("SovereignDroneDeploymentActive", false)
		model:SetAttribute("SovereignWingInertiaSuspended", false)
		active[model] = nil
	end)
	return true
end

return Preview
