local TweenService = game:GetService("TweenService")

local TestHarness = {}

local COLORS = {
	Damage = Color3.fromRGB(174, 74, 68),
	Ability = Color3.fromRGB(63, 132, 153),
	Protection = Color3.fromRGB(83, 145, 99),
	Reset = Color3.fromRGB(128, 128, 128),
	Panel = Color3.fromRGB(28, 35, 32),
	Text = Color3.fromRGB(235, 238, 225),
}

local function addText(part, name, text, face)
	local surface = Instance.new("SurfaceGui")
	surface.Name = name
	surface.Face = face or Enum.NormalId.Top
	surface.PixelsPerStud = 30
	surface.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	surface.Parent = part

	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = COLORS.Text
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.TextWrapped = true
	label.Parent = surface
	return label
end

local function button(parent, name, text, position, color, callback)
	local item = Instance.new("Part")
	item.Name = name
	item.Size = Vector3.new(5.5, 0.8, 3.2)
	item.Position = position
	item.Anchored = true
	item.CanCollide = true
	item.Material = Enum.Material.SmoothPlastic
	item.Color = color
	item.Parent = parent
	addText(item, "ButtonLabel", text, Enum.NormalId.Top)

	local click = Instance.new("ClickDetector")
	click.MaxActivationDistance = 40
	click.Parent = item
	click.MouseClick:Connect(callback)
	return item
end

function TestHarness.Attach(workshop, model)
	local oldConsole = workspace:FindFirstChild("WardenShepherdTestConsole")
	if oldConsole then
		oldConsole:Destroy()
	end

	local console = Instance.new("Model")
	console.Name = "WardenShepherdTestConsole"
	console:SetAttribute("WorkshopOnly", true)
	console.Parent = workspace

	local gameplay = model:WaitForChild("Gameplay")
	local applyDamage = gameplay:WaitForChild("ApplyDamage")
	local requestAbility = gameplay:WaitForChild("RequestAbility")
	local resetGuardian = gameplay:WaitForChild("ResetGuardian")
	local protectedBuilding = gameplay:WaitForChild("ProtectedBuilding")
	local isProtectingBuilding = gameplay:WaitForChild("IsProtectingBuilding")
	local batonStrikeRequested = gameplay:WaitForChild("BatonStrikeRequested")
	local warningPulseRequested = gameplay:WaitForChild("WarningPulseRequested")

	local origin = Vector3.new(20, 0.6, -10)
	local board = Instance.new("Part")
	board.Name = "StatusBoard"
	board.Size = Vector3.new(13, 6, 0.7)
	board.Position = origin + Vector3.new(0, 6, 5)
	board.Anchored = true
	board.CanCollide = true
	board.Material = Enum.Material.SmoothPlastic
	board.Color = COLORS.Panel
	board.Parent = console
	local statusLabel = addText(board, "StatusDisplay", "WARDEN TEST READY", Enum.NormalId.Front)

	local testBuilding = Instance.new("Part")
	testBuilding.Name = "TestBuilding"
	testBuilding.Size = Vector3.new(8, 4, 8)
	testBuilding.Position = origin + Vector3.new(13, 2, 8)
	testBuilding.Anchored = true
	testBuilding.CanCollide = true
	testBuilding.Material = Enum.Material.Concrete
	testBuilding.Color = Color3.fromRGB(112, 116, 118)
	testBuilding:SetAttribute("MaxHealth", 500)
	testBuilding:SetAttribute("Health", 500)
	testBuilding.Parent = console
	local buildingLabel = addText(testBuilding, "BuildingLabel", "TEST BUILDING\nHP 500", Enum.NormalId.Top)

	local targetNearCFrame = CFrame.new(0, 6, -10)
	local targetFarCFrame = CFrame.new(0, 6, -24)
	local targetNear = true
	local testTarget = Instance.new("Part")
	testTarget.Name = "TestKaijuTarget"
	testTarget.Size = Vector3.new(6, 12, 6)
	testTarget.CFrame = targetNearCFrame
	testTarget.Anchored = true
	testTarget.CanCollide = true
	testTarget.Material = Enum.Material.SmoothPlastic
	testTarget.Color = Color3.fromRGB(105, 72, 91)
	testTarget:SetAttribute("MaxHealth", 1000)
	testTarget:SetAttribute("Health", 1000)
	testTarget.Parent = console
	local targetLabel = addText(testTarget, "TargetLabel", "KAIJU TARGET\nHP 1000", Enum.NormalId.Front)

	local function show(message)
		statusLabel.Text = message
	end

	local function refreshTarget()
		targetLabel.Text = string.format("KAIJU TARGET\nHP %d", testTarget:GetAttribute("Health"))
	end

	local function refreshBuilding()
		buildingLabel.Text = string.format("TEST BUILDING\nHP %d", testBuilding:GetAttribute("Health"))
	end

	local function targetMetrics()
		local root = model.PrimaryPart
		if not root then
			return math.huge, -1
		end
		local delta = testTarget.Position - root.Position
		local planar = Vector3.new(delta.X, 0, delta.Z)
		if planar.Magnitude <= 0.001 then
			return 0, 1
		end
		local facing = Vector3.new(root.CFrame.LookVector.X, 0, root.CFrame.LookVector.Z).Unit
		return planar.Magnitude, facing:Dot(planar.Unit)
	end

	local function flashAndPushTarget(distance)
		local originalColor = testTarget.Color
		local originalCFrame = testTarget.CFrame
		testTarget.Color = Color3.fromRGB(232, 91, 104)
		local direction = Vector3.new(
			testTarget.Position.X - model.PrimaryPart.Position.X,
			0,
			testTarget.Position.Z - model.PrimaryPart.Position.Z
		).Unit
		local pushedCFrame = originalCFrame + direction * distance
		local outward = TweenService:Create(
			testTarget,
			TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{CFrame = pushedCFrame}
		)
		outward:Play()
		outward.Completed:Connect(function()
			testTarget.Color = originalColor
			task.delay(0.18, function()
				TweenService:Create(
					testTarget,
					TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{CFrame = originalCFrame}
				):Play()
			end)
		end)
	end

	batonStrikeRequested.Event:Connect(function(target, batonConfig)
		if target ~= testTarget then
			return
		end
		local distance, facingDot = targetMetrics()
		local requiredDot = math.cos(math.rad(batonConfig.ArcDegrees * 0.5))
		task.delay(0.05, function()
			if distance > batonConfig.Range then
				show(string.format("BATON MISSED\nOUT OF RANGE %.1f / %.1f", distance, batonConfig.Range))
				return
			end
			if facingDot < requiredDot then
				show("BATON MISSED\nOUTSIDE ATTACK ARC")
				return
			end
			local health = math.max(0, testTarget:GetAttribute("Health") - batonConfig.Damage)
			testTarget:SetAttribute("Health", health)
			refreshTarget()
			flashAndPushTarget(math.min(4, batonConfig.Knockback * 0.08))
			show(string.format("BATON HIT\n%d DAMAGE | TARGET HP %d", batonConfig.Damage, health))
		end)
	end)

	warningPulseRequested.Event:Connect(function(target, pulseConfig)
		if target ~= testTarget then
			return
		end
		local distance = targetMetrics()
		task.delay(pulseConfig.TelegraphDuration, function()
			if distance > pulseConfig.Radius then
				show(string.format("PULSE MISSED\nOUT OF RANGE %.1f / %.1f", distance, pulseConfig.Radius))
				return
			end
			flashAndPushTarget(math.min(6, pulseConfig.Knockback * 0.08))
			show(string.format("PULSE HIT\nKNOCKBACK | RANGE %.1f", distance))
		end)
	end)

	button(console, "Damage100", "DAMAGE 100", origin + Vector3.new(-3.2, 0, 0), COLORS.Damage, function()
		local health, result = applyDamage:Invoke(100, "WorkshopButton")
		show(string.format("100 DAMAGE\n%s | HP %d", result, health))
	end)

	button(console, "Damage500", "DAMAGE 500", origin + Vector3.new(3.2, 0, 0), COLORS.Damage, function()
		local health, result = applyDamage:Invoke(500, "WorkshopButton")
		show(string.format("500 DAMAGE\n%s | HP %d", result, health))
	end)

	button(console, "ShockBaton", "SHOCK BATON", origin + Vector3.new(-3.2, 0, 3.8), COLORS.Ability, function()
		local accepted, result = requestAbility:Invoke("ShockBaton", testTarget)
		show(string.format("SHOCK BATON\n%s | %s", accepted and "ACCEPTED" or "BLOCKED", result))
	end)

	button(console, "WarningPulse", "WARNING PULSE", origin + Vector3.new(3.2, 0, 3.8), COLORS.Ability, function()
		local accepted, result = requestAbility:Invoke("WarningPulse", testTarget)
		show(string.format("WARNING PULSE\n%s | %s", accepted and "ACCEPTED" or "BLOCKED", result))
	end)

	button(console, "ProtectBuilding", "PROTECT BUILDING", origin + Vector3.new(-3.2, 0, 7.6), COLORS.Protection, function()
		protectedBuilding.Value = testBuilding
		local active = isProtectingBuilding:Invoke(testBuilding)
		show(active and "BUILDING PROTECTED" or "PROTECTION FAILED")
	end)

	button(console, "AttackBuilding", "ATTACK BUILDING", origin + Vector3.new(3.2, 0, 7.6), COLORS.Damage, function()
		if isProtectingBuilding:Invoke(testBuilding) then
			show(string.format("BUILDING DAMAGE BLOCKED\nHP %d", testBuilding:GetAttribute("Health")))
			return
		end
		local health = math.max(0, testBuilding:GetAttribute("Health") - 100)
		testBuilding:SetAttribute("Health", health)
		refreshBuilding()
		show(string.format("BUILDING DAMAGED\nHP %d", health))
	end)

	button(console, "ToggleTargetRange", "TARGET NEAR / FAR", origin + Vector3.new(-3.2, 0, 11.4), COLORS.Ability, function()
		targetNear = not targetNear
		testTarget.CFrame = targetNear and targetNearCFrame or targetFarCFrame
		show(targetNear and "TARGET NEAR\nIN RANGE" or "TARGET FAR\nBATON OUT OF RANGE")
	end)

	button(console, "ResetGuardian", "RESET ALL", origin + Vector3.new(3.2, 0, 11.4), COLORS.Reset, function()
		resetGuardian:Invoke()
		targetNear = true
		testTarget.CFrame = targetNearCFrame
		testTarget:SetAttribute("Health", 1000)
		testBuilding:SetAttribute("Health", 500)
		refreshTarget()
		refreshBuilding()
		show("RESET ALL\nWARDEN | TARGET | BUILDING")
	end)

	model:GetAttributeChangedSignal("GuardianState"):Connect(function()
		show(string.format(
			"STATE: %s\nHP %d / %d",
			model:GetAttribute("GuardianState"),
			model:GetAttribute("Health"),
			model:GetAttribute("MaxHealth")
		))
	end)

	workshop:SetAttribute("TestConsoleReady", true)
	return console
end

return TestHarness
