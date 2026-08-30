local TweenService = game:GetService("TweenService")
local Harness = {}

local function label(part, text, face)
	local gui = Instance.new("SurfaceGui")
	gui.Face = face or Enum.NormalId.Top
	gui.PixelsPerStud = 28
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.Parent = part
	local value = Instance.new("TextLabel")
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
	item.Size = Vector3.new(5.6, 0.8, 3.1)
	item.Position = position
	item.Anchored = true
	item.Color = color
	item.Material = Enum.Material.SmoothPlastic
	item.Parent = parent
	label(item, text)
	local click = Instance.new("ClickDetector")
	click.MaxActivationDistance = 45
	click.Parent = item
	click.MouseClick:Connect(callback)
	return item
end

function Harness.Attach(workshop, model, config)
	local old = workspace:FindFirstChild("MarshalRoadblockTestConsole")
	if old then old:Destroy() end
	local console = Instance.new("Model")
	console.Name = "MarshalRoadblockTestConsole"
	console.Parent = workspace
	local api = model:WaitForChild("Gameplay")
	local request = api:WaitForChild("RequestAbility")
	local damage = api:WaitForChild("ApplyDamage")
	local reset = api:WaitForChild("Reset")
	local event = api:WaitForChild("AbilityRequested")

	local origin = Vector3.new(2, 0.6, -26)
	local board = Instance.new("Part")
	board.Size = Vector3.new(14, 6, 0.7)
	board.Position = origin + Vector3.new(0, 6, 6)
	board.Anchored = true
	board.Color = Color3.fromRGB(22, 29, 36)
	board.Parent = console
	local status = label(board, "ROADBLOCK TEST READY", Enum.NormalId.Front)

	local target = Instance.new("Part")
	target.Name = "TestKaijuTarget"
	target.Size = Vector3.new(6, 12, 6)
	target.Position = Vector3.new(-15, 6, -24)
	target.Anchored = true
	target.Color = Color3.fromRGB(105, 72, 91)
	target.Parent = console
	local targetLabel = label(target, "KAIJU TARGET\nFREE", Enum.NormalId.Front)
	local lockGui = Instance.new("BillboardGui")
	lockGui.Name = "EnemyLockedWarning"
	lockGui.Size = UDim2.fromOffset(280, 74)
	lockGui.StudsOffset = Vector3.new(0, 8.5, 0)
	lockGui.AlwaysOnTop = true
	lockGui.Enabled = false
	lockGui.Parent = target
	local lockLabel = Instance.new("TextLabel")
	lockLabel.Size = UDim2.fromScale(1, 1)
	lockLabel.BackgroundColor3 = Color3.fromRGB(107, 24, 30)
	lockLabel.BackgroundTransparency = 0.12
	lockLabel.BorderSizePixel = 0
	lockLabel.Text = "⚠ ENEMY LOCKED ⚠"
	lockLabel.TextColor3 = Color3.fromRGB(255, 226, 184)
	lockLabel.Font = Enum.Font.GothamBlack
	lockLabel.TextScaled = true
	lockLabel.Parent = lockGui
	local lockStroke = Instance.new("UIStroke")
	lockStroke.Color = Color3.fromRGB(255, 91, 91)
	lockStroke.Thickness = 3
	lockStroke.Parent = lockLabel
	local groundLock = Instance.new("Part")
	groundLock.Name = "NetTargetGroundWarning"
	groundLock.Shape = Enum.PartType.Cylinder
	groundLock.Size = Vector3.new(0.18, 10, 10)
	groundLock.CFrame = CFrame.new(target.Position.X, 0.12, target.Position.Z) * CFrame.Angles(0, 0, math.rad(90))
	groundLock.Anchored = true
	groundLock.CanCollide = false
	groundLock.CanQuery = false
	groundLock.Material = Enum.Material.Neon
	groundLock.Color = Color3.fromRGB(255, 73, 73)
	groundLock.Transparency = 1
	groundLock.Parent = console
	local netModel
	local netSourceAttachment
	local netToken = 0
	local shieldModel = model:FindFirstChild("RiotShield", true)
	local shieldRestCFrame = shieldModel and shieldModel:GetPivot()
	local launcherMouth = model:FindFirstChild("LaunchMouth", true)

	local function tweenModel(targetModel, destination, duration)
		local driver = Instance.new("CFrameValue")
		driver.Value = targetModel:GetPivot()
		local connection = driver:GetPropertyChangedSignal("Value"):Connect(function()
			if targetModel.Parent then targetModel:PivotTo(driver.Value) end
		end)
		local tween = TweenService:Create(driver, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Value = destination})
		tween.Completed:Connect(function()
			connection:Disconnect()
			driver:Destroy()
		end)
		tween:Play()
	end

	local function show(text) status.Text = text end
	local function clearNet()
		netToken += 1
		if netModel then netModel:Destroy(); netModel = nil end
		if netSourceAttachment then netSourceAttachment:Destroy(); netSourceAttachment = nil end
		targetLabel.Text = "KAIJU TARGET\nFREE"
		lockGui.Enabled = false
		groundLock.Transparency = 1
	end

	local function deployNet(ability)
		clearNet()
		local token = netToken
		targetLabel.Text = "LOCKED\nTELEGRAPH 1.2s"
		lockGui.Enabled = true
		groundLock.CFrame = CFrame.new(target.Position.X, 0.12, target.Position.Z) * CFrame.Angles(0, 0, math.rad(90))
		groundLock.Transparency = 0.48
		TweenService:Create(groundLock, TweenInfo.new(ability.TelegraphDuration, Enum.EasingStyle.Linear), {Transparency = 0.12, Size = Vector3.new(0.18, 13, 13)}):Play()
		task.delay(ability.TelegraphDuration, function()
			if token ~= netToken then return end
			lockGui.Enabled = false
			groundLock.Transparency = 1
			groundLock.Size = Vector3.new(0.18, 10, 10)
			netModel = Instance.new("Model")
			netModel.Name = "SimulatedContainmentNet"
			netModel.Parent = console
			netSourceAttachment = Instance.new("Attachment")
			netSourceAttachment.Name = "NetLauncherSource"
			netSourceAttachment.Parent = launcherMouth
			local activeNodes = ability.NodeCount
			for index = 1, ability.NodeCount do
				local angle = (index - 1) / ability.NodeCount * math.pi * 2
				local node = Instance.new("Part")
				node.Name = "NetNode" .. index
				node.Shape = Enum.PartType.Cylinder
				node.Size = Vector3.new(2.2, 0.85, 0.85)
				node.CFrame = launcherMouth.CFrame
				node.Anchored = true
				node.Material = Enum.Material.Neon
				node.Color = Color3.fromRGB(63, 199, 255)
				node:SetAttribute("HitsRemaining", ability.NodeHealth)
				node.Parent = netModel
				local nodeAttachment = Instance.new("Attachment")
				nodeAttachment.Parent = node
				local tether = Instance.new("Beam")
				tether.Name = "LauncherTether"
				tether.Attachment0 = netSourceAttachment
				tether.Attachment1 = nodeAttachment
				tether.Color = ColorSequence.new(Color3.fromRGB(63, 199, 255))
				tether.Width0 = 0.16
				tether.Width1 = 0.09
				tether.FaceCamera = true
				tether.Parent = node
				local destination = target.Position + Vector3.new(math.cos(angle) * 4, (index % 2) * 5 - 2, math.sin(angle) * 4)
				local flight = TweenService:Create(node, TweenInfo.new(0.42 + index * 0.035, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = destination})
				flight:Play()
				flight.Completed:Connect(function()
					if node.Parent then
						node.Shape = Enum.PartType.Ball
						node.Size = Vector3.new(1.1, 1.1, 1.1)
					end
				end)
				local click = Instance.new("ClickDetector")
				click.MaxActivationDistance = 45
				click.Parent = node
				click.MouseClick:Connect(function()
					local hits = node:GetAttribute("HitsRemaining") - 1
					node:SetAttribute("HitsRemaining", hits)
					node.Size *= 0.72
					if hits <= 0 then
						activeNodes -= 1
						node:Destroy()
					end
					if netModel and activeNodes <= 0 then clearNet(); show("NET DESTROYED\nTARGET ESCAPED") end
				end)
			end
			targetLabel.Text = "CONTAINED\n50% SLOW | NO JUMP/DASH"
			show("NET ACTIVE\nATTACK CYAN NODES")
			task.delay(ability.Duration, function()
				if token == netToken then clearNet(); show("NET EXPIRED\n8s RE-CATCH IMMUNITY") end
			end)
		end)
	end

	event.Event:Connect(function(name, requestedTarget, ability)
		if requestedTarget ~= target and name ~= "RiotShield" then return end
		if name == "PulseCannon" then
			show("PULSE CANNON\nARM RAISES | TELEGRAPH")
			task.delay(ability.TelegraphDuration, function()
				local original = target.CFrame
				local pushed = original + Vector3.new(0, 0, -ability.KnockbackStuds)
				TweenService:Create(target, TweenInfo.new(0.25), {CFrame = pushed}):Play()
				show("PULSE HIT\n90 DAMAGE | KNOCKBACK")
				task.delay(0.8, function() target.CFrame = original end)
			end)
		elseif name == "ContainmentNet" then deployNet(ability)
		elseif name == "RiotShield" then
			show("SHIELD MOVING TO BLOCK\n85% FRONTAL REDUCTION")
			if shieldModel and shieldRestCFrame then
				local blockCFrame = shieldRestCFrame + Vector3.new(10.5, 1.8, -1.2)
				tweenModel(shieldModel, blockCFrame, 0.32)
				task.delay(math.max(0.4, ability.Duration - 0.35), function()
					if shieldModel.Parent then tweenModel(shieldModel, shieldRestCFrame, 0.32) end
				end)
			end
		end
	end)

	local blue = Color3.fromRGB(48, 128, 158)
	button(console, "Shield", "SHIELD BLOCK", origin + Vector3.new(-6, 0, 0), blue, function() local ok, why = request:Invoke("RiotShield"); show("SHIELD: " .. tostring(ok) .. "\n" .. why) end)
	button(console, "Cannon", "PULSE CANNON", origin, blue, function() local ok, why = request:Invoke("PulseCannon", target); show("CANNON: " .. tostring(ok) .. "\n" .. why) end)
	button(console, "Net", "CONTAINMENT NET", origin + Vector3.new(6, 0, 0), blue, function() local ok, why = request:Invoke("ContainmentNet", target); show("NET: " .. tostring(ok) .. "\n" .. why) end)
	button(console, "Damage", "FRONTAL DAMAGE", origin + Vector3.new(-3, 0, 4), Color3.fromRGB(160, 72, 67), function() local hp, shield, blocked = damage:Invoke(1000, true); show(string.format("HP %d | SHIELD %d\nBLOCKED %d", hp, shield, blocked)) end)
	button(console, "Reset", "RESET", origin + Vector3.new(3, 0, 4), Color3.fromRGB(100, 105, 110), function() reset:Invoke(); clearNet(); target.CFrame = CFrame.new(-15, 6, -24); if shieldModel and shieldRestCFrame then shieldModel:PivotTo(shieldRestCFrame) end; show("RESET COMPLETE") end)
	workshop:SetAttribute("RoadblockTestConsoleReady", true)
	return console
end

return Harness
