local TweenService = game:GetService("TweenService")

local Harness = {}

local function label(part, text)
	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Top
	gui.PixelsPerStud = 28
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.Parent = part
	local value = Instance.new("TextLabel")
	value.Name = "ButtonLabel"
	value.Size = UDim2.fromScale(1, 1)
	value.BackgroundTransparency = 1
	value.TextColor3 = Color3.fromRGB(235, 245, 248)
	value.Font = Enum.Font.GothamBold
	value.TextScaled = true
	value.TextWrapped = true
	value.Text = text
	value.Parent = gui
	return value
end

local function button(parent, name, text, position, color, callback)
	local item = Instance.new("Part")
	item.Name = name
	item.Size = Vector3.new(5.8, 0.8, 3.1)
	item.Position = position
	item.Anchored = true
	item.Color = color
	item.Material = Enum.Material.SmoothPlastic
	item.Parent = parent
	local value = label(item, text)
	local click = Instance.new("ClickDetector")
	click.MaxActivationDistance = 50
	click.Parent = item
	click.MouseClick:Connect(function(player)
		item.Color = Color3.fromRGB(235, 178, 55)
		value.Text = "RUNNING"
		callback(player)
		task.delay(0.55, function()
			if item.Parent then
				item.Color = color
				value.Text = text
			end
		end)
	end)
	return item
end

local function motor(model, name)
	local item = model:FindFirstChild(name, true)
	assert(item and item:IsA("Motor6D"), "Missing fleet rig motor: " .. name)
	return item
end

function Harness.Attach(model)
	local old = workspace:FindFirstChild("GuardianFleetRigTestConsole")
	if old then old:Destroy() end

	local console = Instance.new("Model")
	console.Name = "GuardianFleetRigTestConsole"
	console.Parent = workspace

	local joints = {
		LeftShoulder = motor(model, "LeftShoulder"),
		LeftElbow = motor(model, "LeftElbow"),
		LeftWrist = motor(model, "LeftWrist"),
		RightShoulder = motor(model, "RightShoulder"),
		RightElbow = motor(model, "RightElbow"),
		LeftHip = motor(model, "LeftHip"),
		LeftKnee = motor(model, "LeftKnee"),
		RightHip = motor(model, "RightHip"),
		RightKnee = motor(model, "RightKnee"),
	}

	local neutralC0 = {}
	for name, joint in pairs(joints) do
		neutralC0[name] = joint.C0
	end

	local function pose(targets, duration)
		for name, joint in pairs(joints) do
			local offset = targets[name] or CFrame.identity
			TweenService:Create(
				joint,
				TweenInfo.new(duration or 0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
				{C0 = neutralC0[name] * offset}
			):Play()
		end
	end

	local origin = model:GetPivot().Position + Vector3.new(0, 0.6, -28)
	local blue = Color3.fromRGB(48, 128, 158)
	local green = Color3.fromRGB(48, 145, 104)
	local gray = Color3.fromRGB(96, 102, 110)

	button(console, "LeftShoulderTest", "LEFT SHOULDER", origin + Vector3.new(-9, 0, 0), blue, function()
		pose({
			LeftShoulder = CFrame.Angles(math.rad(-28), math.rad(-12), math.rad(-30)),
		}, 0.45)
	end)

	button(console, "LeftElbowTest", "LEFT ELBOW", origin + Vector3.new(-3, 0, 0), blue, function()
		pose({
			LeftShoulder = CFrame.Angles(math.rad(-18), math.rad(-8), math.rad(-18)),
			LeftElbow = CFrame.Angles(math.rad(-62), 0, 0),
			LeftWrist = CFrame.Angles(0, math.rad(12), 0),
		}, 0.45)
	end)

	button(console, "RightArmTest", "RIGHT ARM", origin + Vector3.new(3, 0, 0), blue, function()
		pose({
			RightShoulder = CFrame.Angles(math.rad(-42), 0, math.rad(22)),
			RightElbow = CFrame.Angles(math.rad(-38), 0, 0),
		}, 0.45)
	end)

	button(console, "KneeTest", "KNEE LOAD", origin + Vector3.new(9, 0, 0), green, function()
		pose({
			LeftHip = CFrame.Angles(math.rad(-10), 0, 0),
			RightHip = CFrame.Angles(math.rad(-10), 0, 0),
			LeftKnee = CFrame.Angles(math.rad(24), 0, 0),
			RightKnee = CFrame.Angles(math.rad(24), 0, 0),
		}, 0.45)
	end)

	button(console, "Neutral", "NEUTRAL", origin + Vector3.new(0, 0, 4), gray, function()
		pose({}, 0.35)
	end)

	model:SetAttribute("FleetRigMotionTestReady", true)
	model:SetAttribute("FleetRigMotionDriver", "Motor6D.C0")
	return console
end

return Harness
