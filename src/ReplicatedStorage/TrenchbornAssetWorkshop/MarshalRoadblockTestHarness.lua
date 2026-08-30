local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
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
	local stateChanged = api:WaitForChild("StateChanged")
	local damageTaken = api:WaitForChild("DamageTaken")
	local guardianRestCFrame = model:GetPivot()

	local origin = Vector3.new(2, 0.6, -26)
	local board = Instance.new("Part")
	board.Size = Vector3.new(14, 6, 0.7)
	board.Position = origin + Vector3.new(0, 6, 6)
	board.Anchored = true
	board.Color = Color3.fromRGB(22, 29, 36)
	board.Parent = console
	local status = label(board, "ROADBLOCK TEST READY", Enum.NormalId.Front)
	local function show(text)
		status.Text = text
	end

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
	local lockCenter = Instance.new("Part")
	lockCenter.Name = "CyanLockCenter"
	lockCenter.Shape = Enum.PartType.Cylinder
	lockCenter.Size = Vector3.new(0.22, 2.2, 2.2)
	lockCenter.CFrame = groundLock.CFrame + Vector3.new(0, 0.03, 0)
	lockCenter.Anchored = true
	lockCenter.CanCollide = false
	lockCenter.CanQuery = false
	lockCenter.Material = Enum.Material.Neon
	lockCenter.Color = Color3.fromRGB(63, 199, 255)
	lockCenter.Transparency = 1
	lockCenter.Parent = console
	local visor = model:FindFirstChild("VisorSensor", true)
	local scanSource = Instance.new("Attachment")
	scanSource.Name = "ContainmentScanSource"
	scanSource.Parent = visor
	local scanTarget = Instance.new("Attachment")
	scanTarget.Name = "ContainmentScanTarget"
	scanTarget.Parent = target
	local scanBeam = Instance.new("Beam")
	scanBeam.Name = "BlueContainmentScan"
	scanBeam.Attachment0 = scanSource
	scanBeam.Attachment1 = scanTarget
	scanBeam.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(125, 232, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(43, 150, 255)),
	})
	scanBeam.Width0 = 0.16
	scanBeam.Width1 = 0.08
	scanBeam.FaceCamera = true
	scanBeam.LightEmission = 0.75
	scanBeam.Enabled = false
	scanBeam.Parent = visor
	local netModel
	local netSourceAttachment
	local netToken = 0
	local shieldModel = model:FindFirstChild("RiotShield", true)
	local shieldRestCFrame = shieldModel and shieldModel:GetPivot()
	local launcherMouth = model:FindFirstChild("LaunchMouth", true)
	local cannonMuzzle = model:FindFirstChild("MuzzleCore", true)
	local cannonArmParts = {}
	local cannonArmRest = {}
	local shoulderPivotPart = model:FindFirstChild("RightShoulderBearingDrum", true)
	local shieldArmParts = {}
	local shieldArmRest = {}
	local shieldFollowers = {}
	local shieldShoulderPivot = model:FindFirstChild("LeftShoulderBearingDrum", true)
	for _, item in ipairs(model:GetDescendants()) do
		if item:IsA("BasePart") then
			local inRightHand = item:FindFirstAncestor("RightHand") ~= nil
			local inCannon = item:FindFirstAncestor("PulseCannon") ~= nil
			local rightArmName = string.find(item.Name, "RightShoulder", 1, true)
				or string.find(item.Name, "RightUpperArm", 1, true)
				or string.find(item.Name, "RightElbow", 1, true)
				or string.find(item.Name, "RightForearm", 1, true)
			if inRightHand or inCannon or rightArmName then
				table.insert(cannonArmParts, item)
				cannonArmRest[item] = item.CFrame
			end
			local inLeftHand = item:FindFirstAncestor("LeftHand") ~= nil
			local leftArmName = string.find(item.Name, "LeftUpperArm", 1, true)
				or string.find(item.Name, "LeftElbow", 1, true)
				or string.find(item.Name, "LeftForearm", 1, true)
			if (inLeftHand or leftArmName) and not item:FindFirstAncestor("RiotShield") then
				table.insert(shieldArmParts, item)
				shieldArmRest[item] = item.CFrame
				shieldFollowers[item] = inLeftHand or string.find(item.Name, "LeftForearm", 1, true) ~= nil
			end
		end
	end

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

	local function tweenArm(destinationMap, duration)
		for _, item in ipairs(cannonArmParts) do
			if item.Parent and destinationMap[item] then
				TweenService:Create(item, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {CFrame = destinationMap[item]}):Play()
			end
		end
	end

	local function shieldArmPose(angleDegrees, shieldOffset)
		local result = {}
		local pivot = shieldShoulderPivot.Position
		local rotation = CFrame.new(pivot) * CFrame.Angles(0, 0, math.rad(angleDegrees)) * CFrame.new(-pivot)
		for item, restCFrame in pairs(shieldArmRest) do
			if shieldFollowers[item] then
				result[item] = CFrame.new(shieldOffset or Vector3.zero) * restCFrame
			else
				result[item] = rotation * restCFrame
			end
		end
		return result
	end

	local function tweenShieldArm(destinationMap, duration)
		for _, item in ipairs(shieldArmParts) do
			if item.Parent and destinationMap[item] then
				TweenService:Create(item, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {CFrame = destinationMap[item]}):Play()
			end
		end
	end

	local function armPose(angleDegrees, recoilStuds)
		local result = {}
		local pivot = shoulderPivotPart.Position
		local rotation = CFrame.new(pivot) * CFrame.Angles(math.rad(angleDegrees), 0, 0) * CFrame.new(-pivot)
		local recoil = CFrame.new(0, 0, recoilStuds or 0)
		for item, restCFrame in pairs(cannonArmRest) do
			result[item] = recoil * rotation * restCFrame
		end
		return result
	end

	local function firePulse(targetPart, ability)
		local pulse = Instance.new("Part")
		pulse.Name = "SimulatedPulseProjectile"
		pulse.Shape = Enum.PartType.Ball
		pulse.Size = Vector3.new(2.4, 2.4, 2.4)
		pulse.Position = cannonMuzzle.Position
		pulse.Anchored = true
		pulse.CanCollide = false
		pulse.CanQuery = false
		pulse.Material = Enum.Material.Neon
		pulse.Color = Color3.fromRGB(63, 199, 255)
		pulse.Parent = console
		local glow = Instance.new("Highlight")
		glow.FillColor = pulse.Color
		glow.FillTransparency = 0.35
		glow.OutlineTransparency = 1
		glow.Adornee = pulse
		glow.Parent = pulse
		local destination = targetPart.Position
		local travel = TweenService:Create(pulse, TweenInfo.new(0.18, Enum.EasingStyle.Linear), {Position = destination, Size = Vector3.new(3.5, 3.5, 3.5)})
		travel:Play()
		travel.Completed:Connect(function()
			pulse:Destroy()
			local original = targetPart.CFrame
			local away = Vector3.new(targetPart.Position.X - model:GetPivot().Position.X, 0, targetPart.Position.Z - model:GetPivot().Position.Z)
			if away.Magnitude < 0.01 then away = Vector3.new(0, 0, -1) else away = away.Unit end
			TweenService:Create(targetPart, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {CFrame = original + away * ability.KnockbackStuds}):Play()
			show("PULSE HIT\n90 DAMAGE | KNOCKBACK")
			task.delay(0.8, function() targetPart.CFrame = original end)
		end)
	end

	local flashSequence = 0
	local function flashGuardian(blocked)
		flashSequence += 1
		local token = flashSequence
		local originals = {}
		for _, item in ipairs(model:GetDescendants()) do
			if item:IsA("BasePart") and item.Transparency < 1 then
				originals[item] = item.Color
				item.Color = blocked and Color3.fromRGB(255, 166, 92) or Color3.fromRGB(255, 62, 62)
			end
		end
		task.delay(0.2, function()
			if token ~= flashSequence then return end
			for item, color in pairs(originals) do
				if item.Parent then item.Color = color end
			end
		end)
	end

	damageTaken.Event:Connect(function(healthDamage, blocked)
		flashGuardian(blocked > healthDamage)
	end)

	stateChanged.Event:Connect(function(newState)
		if newState == "Staggered" then
			show("GUARDIAN STAGGERED\nBALANCE BROKEN")
			local staggerPose = guardianRestCFrame * CFrame.new(0, -0.5, 0) * CFrame.Angles(0, 0, math.rad(-7))
			tweenModel(model, staggerPose, 0.16)
			task.delay(0.62, function()
				if model:GetAttribute("GuardianState") ~= "Defeated" then tweenModel(model, guardianRestCFrame, 0.28) end
			end)
		elseif newState == "Defeated" then
			show("ROADBLOCK DEFEATED\nSYSTEMS OFFLINE")
			local defeatPose = guardianRestCFrame * CFrame.new(0, -2.2, 1.2) * CFrame.Angles(math.rad(-8), 0, math.rad(11))
			tweenModel(model, defeatPose, 0.65)
		end
	end)

	local function launchInArc(projectile, destination, duration, arcHeight, token)
		local start = projectile.Position
		local elapsed = 0
		task.spawn(function()
			while projectile.Parent and token == netToken and elapsed < duration do
				elapsed += RunService.Heartbeat:Wait()
				local alpha = math.clamp(elapsed / duration, 0, 1)
				local linear = start:Lerp(destination, alpha)
				local lift = 4 * arcHeight * alpha * (1 - alpha)
				local position = linear + Vector3.new(0, lift, 0)
				local nextAlpha = math.min(1, alpha + 0.025)
				local nextLinear = start:Lerp(destination, nextAlpha)
				local nextLift = 4 * arcHeight * nextAlpha * (1 - nextAlpha)
				local nextPosition = nextLinear + Vector3.new(0, nextLift, 0)
				if (nextPosition - position).Magnitude > 0.01 then
					projectile.CFrame = CFrame.lookAt(position, nextPosition) * CFrame.Angles(0, math.rad(90), 0)
				else
					projectile.Position = position
				end
			end
			if projectile.Parent and token == netToken then
				projectile.Position = destination
				projectile.Shape = Enum.PartType.Ball
				projectile.Size = Vector3.new(1.1, 1.1, 1.1)
			end
		end)
	end

	local function clearNet()
		netToken += 1
		if netModel then netModel:Destroy(); netModel = nil end
		if netSourceAttachment then netSourceAttachment:Destroy(); netSourceAttachment = nil end
		targetLabel.Text = "KAIJU TARGET\nFREE"
		lockGui.Enabled = false
		groundLock.Transparency = 1
		lockCenter.Transparency = 1
		scanBeam.Enabled = false
	end

	local function deployNet(ability)
		clearNet()
		local token = netToken
		targetLabel.Text = "SCANNING\nBLUE ACQUISITION LASER"
		scanBeam.Enabled = true
		local lockDelay = math.min(0.55, ability.TelegraphDuration * 0.46)
		task.delay(lockDelay, function()
			if token ~= netToken then return end
			targetLabel.Text = "LOCKED\nNET INCOMING"
			lockGui.Enabled = true
			groundLock.CFrame = CFrame.new(target.Position.X, 0.12, target.Position.Z) * CFrame.Angles(0, 0, math.rad(90))
			groundLock.Transparency = 0.48
			lockCenter.CFrame = CFrame.new(target.Position.X, 0.16, target.Position.Z) * CFrame.Angles(0, 0, math.rad(90))
			lockCenter.Transparency = 0.08
			TweenService:Create(groundLock, TweenInfo.new(ability.TelegraphDuration - lockDelay, Enum.EasingStyle.Linear), {Transparency = 0.12, Size = Vector3.new(0.18, 13, 13)}):Play()
		end)
		task.delay(ability.TelegraphDuration, function()
			if token ~= netToken then return end
			scanBeam.Enabled = false
			lockGui.Enabled = false
			groundLock.Transparency = 1
			lockCenter.Transparency = 1
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
				-- The launcher already sits high above the target. A 9-stud lift only
				-- softened the descent; this larger lift creates a visibly ballistic
				-- apex above the Guardian before the node drops around the Kaiju.
				launchInArc(node, destination, 1.18 + index * 0.055, 22 + index * 0.9, token)
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
			tweenArm(armPose(68, 0), 0.42)
			task.delay(ability.TelegraphDuration, function()
				firePulse(target, ability)
				tweenArm(armPose(63, 0.8), 0.1)
				task.delay(0.16, function() tweenArm(armPose(68, 0), 0.12) end)
				task.delay(0.55, function() tweenArm(cannonArmRest, 0.45) end)
			end)
		elseif name == "ContainmentNet" then deployNet(ability)
		elseif name == "RiotShield" then
			show("SHIELD MOVING TO BLOCK\n85% FRONTAL REDUCTION")
			if shieldModel and shieldRestCFrame then
				local shieldOffset = Vector3.new(10.5, 1.8, -1.2)
				local blockCFrame = shieldRestCFrame + shieldOffset
				tweenModel(shieldModel, blockCFrame, 0.32)
				tweenShieldArm(shieldArmPose(48, shieldOffset), 0.32)
				task.delay(math.max(0.4, ability.Duration - 0.35), function()
					if shieldModel.Parent then
						tweenModel(shieldModel, shieldRestCFrame, 0.32)
						tweenShieldArm(shieldArmRest, 0.32)
					end
				end)
			end
		end
	end)

	local blue = Color3.fromRGB(48, 128, 158)
	button(console, "Shield", "SHIELD BLOCK", origin + Vector3.new(-6, 0, 0), blue, function() local ok, why = request:Invoke("RiotShield"); show("SHIELD: " .. tostring(ok) .. "\n" .. why) end)
	button(console, "Cannon", "PULSE CANNON", origin, blue, function() local ok, why = request:Invoke("PulseCannon", target); show("CANNON: " .. tostring(ok) .. "\n" .. why) end)
	button(console, "Net", "CONTAINMENT NET", origin + Vector3.new(6, 0, 0), blue, function() local ok, why = request:Invoke("ContainmentNet", target); show("NET: " .. tostring(ok) .. "\n" .. why) end)
	button(console, "Damage", "FRONTAL DAMAGE", origin + Vector3.new(-3, 0, 4), Color3.fromRGB(160, 72, 67), function() local hp, shield, blocked = damage:Invoke(1000, true); show(string.format("HP %d | SHIELD %d\nBLOCKED %d", hp, shield, blocked)) end)
	button(console, "Reset", "RESET", origin + Vector3.new(3, 0, 4), Color3.fromRGB(100, 105, 110), function() reset:Invoke(); clearNet(); model:PivotTo(guardianRestCFrame); target.CFrame = CFrame.new(-15, 6, -24); tweenArm(cannonArmRest, 0.15); tweenShieldArm(shieldArmRest, 0.15); if shieldModel and shieldRestCFrame then shieldModel:PivotTo(shieldRestCFrame) end; show("RESET COMPLETE") end)
	workshop:SetAttribute("RoadblockTestConsoleReady", true)
	return console
end

return Harness
