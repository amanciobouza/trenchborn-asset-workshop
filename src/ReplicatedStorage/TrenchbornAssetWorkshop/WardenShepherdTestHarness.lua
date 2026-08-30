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
	testBuilding.Parent = console
	addText(testBuilding, "BuildingLabel", "TEST BUILDING", Enum.NormalId.Top)

	local function show(message)
		statusLabel.Text = message
	end

	button(console, "Damage100", "DAMAGE 100", origin + Vector3.new(-3.2, 0, 0), COLORS.Damage, function()
		local health, result = applyDamage:Invoke(100, "WorkshopButton")
		show(string.format("100 DAMAGE\n%s | HP %d", result, health))
	end)

	button(console, "Damage500", "DAMAGE 500", origin + Vector3.new(3.2, 0, 0), COLORS.Damage, function()
		local health, result = applyDamage:Invoke(500, "WorkshopButton")
		show(string.format("500 DAMAGE\n%s | HP %d", result, health))
	end)

	button(console, "ShockBaton", "SHOCK BATON", origin + Vector3.new(-3.2, 0, 3.8), COLORS.Ability, function(player)
		local target = player.Character
		local accepted, result = requestAbility:Invoke("ShockBaton", target)
		show(string.format("SHOCK BATON\n%s | %s", accepted and "ACCEPTED" or "BLOCKED", result))
	end)

	button(console, "WarningPulse", "WARNING PULSE", origin + Vector3.new(3.2, 0, 3.8), COLORS.Ability, function(player)
		local target = player.Character
		local accepted, result = requestAbility:Invoke("WarningPulse", target)
		show(string.format("WARNING PULSE\n%s | %s", accepted and "ACCEPTED" or "BLOCKED", result))
	end)

	button(console, "ProtectBuilding", "PROTECT BUILDING", origin + Vector3.new(-3.2, 0, 7.6), COLORS.Protection, function()
		protectedBuilding.Value = testBuilding
		local active = isProtectingBuilding:Invoke(testBuilding)
		show(active and "BUILDING PROTECTED" or "PROTECTION FAILED")
	end)

	button(console, "ResetGuardian", "RESET", origin + Vector3.new(3.2, 0, 7.6), COLORS.Reset, function()
		resetGuardian:Invoke()
		show("RESET\nIDLE | HP 2500")
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
