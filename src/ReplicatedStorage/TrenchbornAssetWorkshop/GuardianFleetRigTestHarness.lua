local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

local Harness = {}

local function motor(model, name)
	local item = model:FindFirstChild(name, true)
	assert(item and item:IsA("Motor6D"), "Missing fleet rig motor: " .. name)
	return item
end

function Harness.Attach(model)
	local oldConsole = workspace:FindFirstChild("GuardianFleetRigTestConsole")
	if oldConsole then oldConsole:Destroy() end

	local oldRemote = ReplicatedStorage:FindFirstChild("GuardianFleetRigTestRemote")
	if oldRemote then oldRemote:Destroy() end
	local remote = Instance.new("RemoteEvent")
	remote.Name = "GuardianFleetRigTestRemote"
	remote.Parent = ReplicatedStorage

	local hudTemplate = script.Parent:WaitForChild("GuardianFleetRigTestHUD")
	local function installHud(player)
		local playerGui = player:WaitForChild("PlayerGui")
		local oldClient = playerGui:FindFirstChild("GuardianFleetRigTestHUDClient")
		if oldClient then oldClient:Destroy() end
		local client = hudTemplate:Clone()
		client.Name = "GuardianFleetRigTestHUDClient"
		client.Parent = playerGui
	end
	for _, player in ipairs(Players:GetPlayers()) do
		task.spawn(installHud, player)
	end
	Players.PlayerAdded:Connect(installHud)

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

	local animator = model:FindFirstChildWhichIsA("Animator", true)
	assert(animator, "Missing Guardian Fleet Rig Animator")
	local root = model:FindFirstChild("HumanoidRootPart")
	assert(root and root:IsA("BasePart"), "Missing Guardian HumanoidRootPart")
	local lastRequest = {}
	local controllerPlayer
	local controlDirection = Vector3.zero
	local controlUpdatedAt = 0
	local controlSpeed = 12
	local runSpeed = 20
	local walkStepDuration = 1
	local runStepDuration = 0.6
	local controlRunning = false
	local controlBackward = false
	local backwardStepDuration = 1.1
	local movementStartedAt = 0
	local wasControlMoving = false
	local maxTurnRate = math.rad(110)
	local soundscape = model:FindFirstChild("GuardianSoundscape")
	local soundRequested = soundscape and soundscape:FindFirstChild("SoundRequested")
	local lastFootstepIndex = -1
	local function requestSound(name, speedScale, volumeScale)
		if soundRequested and soundRequested:IsA("BindableEvent") then
			soundRequested:Fire(name, speedScale, volumeScale)
		end
	end

	local function stepSpeed(now)
		local duration = controlRunning and runStepDuration or (controlBackward and backwardStepDuration or walkStepDuration)
		local phase = ((now - movementStartedAt) % duration) / duration
		if controlRunning then
			if phase < 0.10 then return 6 end
			if phase < 0.52 then return 34 end
			if phase < 0.78 then return 15 end
			return 7
		end
		if phase < 0.12 then return 3 end
		if phase < 0.52 then return 21 end
		if phase < 0.78 then return 9 end
		return 4
	end

	RunService.Heartbeat:Connect(function(deltaTime)
		if not controllerPlayer then return end
		local now = os.clock()
		local direction = now - controlUpdatedAt <= 0.3 and controlDirection or Vector3.zero
		if direction.Magnitude < 0.01 then
			wasControlMoving = false
			return
		end
		if not wasControlMoving then
			wasControlMoving = true
			movementStartedAt = now
			lastFootstepIndex = -1
		end
		local soundStepDuration = controlRunning and runStepDuration or (controlBackward and backwardStepDuration or walkStepDuration)
		local footstepIndex = math.floor((now - movementStartedAt) / soundStepDuration)
		if footstepIndex ~= lastFootstepIndex then
			lastFootstepIndex = footstepIndex
			requestSound(controlRunning and "FootstepRun" or "FootstepWalk", 0.96 + math.random() * 0.08)
		end
		direction = Vector3.new(direction.X, 0, direction.Z).Unit
		local desiredFacing = controlBackward and -direction or direction
		local facing = Vector3.new(root.CFrame.LookVector.X, 0, root.CFrame.LookVector.Z).Unit
		local angle = math.acos(math.clamp(facing:Dot(desiredFacing), -1, 1))
		local target = CFrame.lookAt(root.Position, root.Position + desiredFacing)
		local alpha = angle > 0.001 and math.min(1, maxTurnRate * deltaTime / angle) or 1
		local turned = root.CFrame:Lerp(target, alpha)
		local facingDirection = Vector3.new(turned.LookVector.X, 0, turned.LookVector.Z).Unit
		local travelDirection = controlBackward and -facingDirection or facingDirection
		local speedScale = controlBackward and 0.67 or 1
		local nextPosition = root.Position + travelDirection * stepSpeed(now) * speedScale * deltaTime
		root.CFrame = CFrame.lookAt(nextPosition, nextPosition + facingDirection)
	end)

	Players.PlayerRemoving:Connect(function(player)
		if player == controllerPlayer then
			controllerPlayer = nil
			controlDirection = Vector3.zero
			wasControlMoving = false
		end
		lastRequest[player] = nil
	end)

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

	local actions = {
		LeftShoulder = function()
			pose({LeftShoulder = CFrame.Angles(math.rad(28), math.rad(-12), math.rad(-30))}, 0.45)
		end,
		LeftElbow = function()
			pose({
				LeftShoulder = CFrame.Angles(math.rad(18), math.rad(-8), math.rad(-18)),
				LeftElbow = CFrame.Angles(math.rad(62), 0, 0),
				LeftWrist = CFrame.Angles(0, math.rad(12), 0),
			}, 0.45)
		end,
		RightArm = function()
			pose({
				RightShoulder = CFrame.Angles(math.rad(42), 0, math.rad(22)),
				RightElbow = CFrame.Angles(math.rad(38), 0, 0),
			}, 0.45)
		end,
		KneeLoad = function()
			pose({
				LeftHip = CFrame.Angles(math.rad(10), 0, 0),
				RightHip = CFrame.Angles(math.rad(10), 0, 0),
				LeftKnee = CFrame.Angles(math.rad(-24), 0, 0),
				RightKnee = CFrame.Angles(math.rad(-24), 0, 0),
			}, 0.45)
		end,
		IdleLoop = function() end,
		AlertIdle = function() end,
		Walk = function() end,
		Run = function() end,
		TurnLeft = function() end,
		TurnRight = function() end,
		Fall = function() end,
		Land = function() end,
		WalkBackward = function() end,
		DamageReact = function() end,
		Stagger = function() end,
		Defeat = function() end,
		ShockBaton = function() end,
		ShieldBlock = function() end,
		PulseCannonFire = function() end,
		ContainmentNetLaunch = function() end,
		ControlGuardian = function() end,
		Neutral = function()
			pose({}, 0.35)
		end,
	}


	local effects = workspace:FindFirstChild("GuardianFleetRigEffects")
	if not effects then
		effects = Instance.new("Folder")
		effects.Name = "GuardianFleetRigEffects"
		effects.Parent = workspace
	end



	local function shockBatonPreview()
		local strikeHead = model:FindFirstChild("StrikeHead", true)
		local target = workspace:FindFirstChild("TestKaijuTarget", true)
		if not strikeHead or not strikeHead:IsA("BasePart") or not target or not target:IsA("BasePart") then return end

		local source = Instance.new("Attachment")
		source.Name = "ShockArcSource"
		source.Parent = strikeHead
		local contact = Instance.new("Attachment")
		contact.Name = "ShockArcContact"
		contact.Position = target.CFrame:PointToObjectSpace(strikeHead.Position)
		contact.Parent = target
		Debris:AddItem(source, 0.35)
		Debris:AddItem(contact, 0.35)

		local light = Instance.new("PointLight")
		light.Color = Color3.fromRGB(126, 255, 173)
		light.Brightness = 10
		light.Range = 22
		light.Parent = strikeHead
		Debris:AddItem(light, 0.22)

		for index = 1, 5 do
			local beam = Instance.new("Beam")
			beam.Name = "ShockBatonArc" .. index
			beam.Attachment0 = source
			beam.Attachment1 = contact
			beam.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(215, 255, 231)),
				ColorSequenceKeypoint.new(0.45, Color3.fromRGB(75, 255, 147)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(228, 255, 238)),
			})
			beam.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.05),
				NumberSequenceKeypoint.new(0.72, 0.15),
				NumberSequenceKeypoint.new(1, 1),
			})
			beam.Width0 = 0.2 + index * 0.025
			beam.Width1 = 0.08
			beam.CurveSize0 = math.random(-30, 30) / 10
			beam.CurveSize1 = math.random(-30, 30) / 10
			beam.Segments = 5
			beam.LightEmission = 1
			beam.FaceCamera = true
			beam.Parent = strikeHead
			Debris:AddItem(beam, 0.14 + index * 0.018)
		end

		local burst = Instance.new("Part")
		burst.Name = "ShockBatonContactFlash"
		burst.Shape = Enum.PartType.Ball
		burst.Size = Vector3.new(1.8, 1.8, 1.8)
		burst.CFrame = CFrame.new(strikeHead.Position)
		burst.Anchored = true
		burst.CanCollide = false
		burst.CanTouch = false
		burst.CanQuery = false
		burst.Material = Enum.Material.Neon
		burst.Color = Color3.fromRGB(176, 255, 205)
		burst.Parent = effects
		Debris:AddItem(burst, 0.25)
		TweenService:Create(burst, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = Vector3.new(7, 7, 7),
			Transparency = 1,
		}):Play()
	end


	local function setEnemyLocked(enabled)
		local target = workspace:FindFirstChild("TestKaijuTarget", true)
		if not target or not target:IsA("BasePart") then return end
		local lockGui = target:FindFirstChild("EnemyLockedWarning")
		if not lockGui then
			lockGui = Instance.new("BillboardGui")
			lockGui.Name = "EnemyLockedWarning"
			lockGui.Size = UDim2.fromOffset(300, 78)
			lockGui.StudsOffset = Vector3.new(0, 8.5, 0)
			lockGui.AlwaysOnTop = true
			lockGui.Parent = target

			local lockLabel = Instance.new("TextLabel")
			lockLabel.Name = "LockLabel"
			lockLabel.Size = UDim2.fromScale(1, 1)
			lockLabel.BackgroundColor3 = Color3.fromRGB(107, 24, 30)
			lockLabel.BackgroundTransparency = 0.08
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
		end
		lockGui.Enabled = enabled
	end

	local function launchNetPreview()
		local mouth = model:FindFirstChild("LaunchMouth", true)
		if not mouth or not mouth:IsA("BasePart") then
			warn("Guardian Containment Net LaunchMouth not found")
			return
		end
		local target = workspace:FindFirstChild("TestKaijuTarget", true)
		local destination = target and target.Position or (mouth.Position + root.CFrame.LookVector * 36)
		local ground = Vector3.new(destination.X, math.max(0.2, destination.Y - 6), destination.Z)

		local warning = Instance.new("Part")
		warning.Name = "ContainmentTargetWarning"
		warning.Shape = Enum.PartType.Cylinder
		warning.Size = Vector3.new(0.22, 12, 12)
		warning.CFrame = CFrame.new(ground) * CFrame.Angles(0, 0, math.rad(90))
		warning.Anchored = true
		warning.CanCollide = false
		warning.CanTouch = false
		warning.CanQuery = false
		warning.Material = Enum.Material.Neon
		warning.Color = Color3.fromRGB(63, 199, 255)
		warning.Transparency = 0.35
		warning.Parent = effects
		Debris:AddItem(warning, 5.2)

		local visor = model:FindFirstChild("VisorSensor", true)
		local scanBeam
		if visor and visor:IsA("BasePart") then
			local scanTarget = Instance.new("Part")
			scanTarget.Name = "ContainmentScanTarget"
			scanTarget.Size = Vector3.new(0.2, 0.2, 0.2)
			scanTarget.Position = destination
			scanTarget.Transparency = 1
			scanTarget.Anchored = true
			scanTarget.CanCollide = false
			scanTarget.Parent = effects
			Debris:AddItem(scanTarget, 1.1)
			local a0 = Instance.new("Attachment")
			a0.Parent = visor
			local a1 = Instance.new("Attachment")
			a1.Parent = scanTarget
			scanBeam = Instance.new("Beam")
			scanBeam.Attachment0 = a0
			scanBeam.Attachment1 = a1
			scanBeam.Color = ColorSequence.new(Color3.fromRGB(70, 190, 255))
			scanBeam.Width0 = 0.18
			scanBeam.Width1 = 0.08
			scanBeam.LightEmission = 0.9
			scanBeam.FaceCamera = true
			scanBeam.Parent = visor
			Debris:AddItem(a0, 1.1)
			Debris:AddItem(scanBeam, 1.1)
		end

		local nodeCount = 5
		local deployed = {}
		local launcherAttachment = Instance.new("Attachment")
		launcherAttachment.Name = "NetLauncherTetherSource"
		launcherAttachment.Parent = mouth
		Debris:AddItem(launcherAttachment, 5.2)
		for index = 1, nodeCount do
			local projectile = Instance.new("Part")
			projectile.Name = "ContainmentNetNodeProjectile"
			projectile.Shape = Enum.PartType.Ball
			projectile.Size = Vector3.new(1.3, 1.3, 1.3)
			projectile.Position = mouth.Position
			projectile.Anchored = true
			projectile.CanCollide = false
			projectile.CanTouch = false
			projectile.CanQuery = false
			projectile.Material = Enum.Material.Neon
			projectile.Color = Color3.fromRGB(63, 226, 255)
			projectile.Parent = effects
			Debris:AddItem(projectile, 5.2)

			local nodeAttachment = Instance.new("Attachment")
			nodeAttachment.Name = "NetNodeTether"
			nodeAttachment.Parent = projectile
			local tether = Instance.new("Beam")
			tether.Name = "LauncherTether" .. index
			tether.Attachment0 = launcherAttachment
			tether.Attachment1 = nodeAttachment
			tether.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(141, 239, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(42, 184, 255)),
			})
			tether.Width0 = 0.18
			tether.Width1 = 0.1
			tether.LightEmission = 0.9
			tether.FaceCamera = true
			tether.Parent = projectile
			table.insert(deployed, projectile)
		end

		local startTime = os.clock()
		local flightDuration = 0.92
		local connection
		connection = RunService.Heartbeat:Connect(function()
			local alpha = math.clamp((os.clock() - startTime) / flightDuration, 0, 1)
			local oneMinus = 1 - alpha
			for index, projectile in ipairs(deployed) do
				if projectile.Parent then
					local angle = (index - 1) / nodeCount * math.pi * 2
					local landing = ground + Vector3.new(math.cos(angle) * 5, 2.4, math.sin(angle) * 5)
					local apex = (mouth.Position + landing) * 0.5 + Vector3.new(0, 27 + index * 1.2, 0)
					projectile.Position = oneMinus * oneMinus * mouth.Position
						+ 2 * oneMinus * alpha * apex
						+ alpha * alpha * landing
				end
			end
			if alpha >= 1 then
				connection:Disconnect()
				warning.Transparency = 0.72
				for index, node in ipairs(deployed) do
					if node.Parent then
						node.Size = Vector3.new(2.1, 2.1, 2.1)
						local nextNode = deployed[index % nodeCount + 1]
						if nextNode and nextNode.Parent then
							local a0 = Instance.new("Attachment")
							a0.Parent = node
							local a1 = Instance.new("Attachment")
							a1.Parent = nextNode
							local beam = Instance.new("Beam")
							beam.Attachment0 = a0
							beam.Attachment1 = a1
							beam.Color = ColorSequence.new(Color3.fromRGB(63, 226, 255))
							beam.Width0 = 0.22
							beam.Width1 = 0.22
							beam.LightEmission = 0.85
							beam.FaceCamera = true
							beam.Parent = node
						end
					end
				end
			end
		end)
	end

	local function firePulsePreview()
		local muzzle = model:FindFirstChild("MuzzleCore", true)
		if not muzzle or not muzzle:IsA("BasePart") then
			warn("Guardian Pulse Cannon MuzzleCore not found")
			return
		end
		local target = workspace:FindFirstChild("TestKaijuTarget", true)
		local destination = target and target.Position
			or (muzzle.Position + root.CFrame.LookVector * 42)

		local pulse = Instance.new("Part")
		pulse.Name = "GuardianPulseProjectile"
		pulse.Shape = Enum.PartType.Ball
		pulse.Size = Vector3.new(3.2, 3.2, 3.2)
		pulse.CFrame = CFrame.new(muzzle.Position)
		pulse.Anchored = true
		pulse.CanCollide = false
		pulse.CanTouch = false
		pulse.CanQuery = false
		pulse.Material = Enum.Material.Neon
		pulse.Color = Color3.fromRGB(63, 217, 255)
		pulse.Parent = effects
		Debris:AddItem(pulse, 2)

		local light = Instance.new("PointLight")
		light.Color = pulse.Color
		light.Brightness = 7
		light.Range = 22
		light.Shadows = true
		light.Parent = pulse

		local glow = Instance.new("Highlight")
		glow.Adornee = pulse
		glow.FillColor = pulse.Color
		glow.FillTransparency = 0.18
		glow.OutlineColor = Color3.fromRGB(205, 250, 255)
		glow.OutlineTransparency = 0.15
		glow.Parent = pulse

		local distance = (destination - muzzle.Position).Magnitude
		local duration = math.clamp(distance / 105, 0.18, 0.55)
		local travel = TweenService:Create(pulse, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
			Position = destination,
			Size = Vector3.new(4.2, 4.2, 4.2),
		})
		travel:Play()
		travel.Completed:Connect(function()
			if not pulse.Parent then return end
			pulse:Destroy()

			local core = Instance.new("Part")
			core.Name = "GuardianPulseImpact"
			core.Shape = Enum.PartType.Ball
			core.Size = Vector3.new(4, 4, 4)
			core.Position = destination
			core.Anchored = true
			core.CanCollide = false
			core.CanTouch = false
			core.CanQuery = false
			core.Material = Enum.Material.Neon
			core.Color = Color3.fromRGB(110, 231, 255)
			core.Transparency = 0.12
			core.Parent = effects
			Debris:AddItem(core, 0.35)
			TweenService:Create(core, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = Vector3.new(11, 11, 11),
				Transparency = 1,
			}):Play()

			local pressureWave = Instance.new("Part")
			pressureWave.Name = "GuardianPulsePressureWave"
			pressureWave.Shape = Enum.PartType.Ball
			pressureWave.Size = Vector3.new(5, 5, 5)
			pressureWave.Position = destination
			pressureWave.Anchored = true
			pressureWave.CanCollide = false
			pressureWave.CanTouch = false
			pressureWave.CanQuery = false
			pressureWave.Material = Enum.Material.ForceField
			pressureWave.Color = Color3.fromRGB(151, 239, 255)
			pressureWave.Transparency = 0.38
			pressureWave.Parent = effects
			Debris:AddItem(pressureWave, 0.55)
			TweenService:Create(pressureWave, TweenInfo.new(0.48, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = Vector3.new(24, 24, 24),
				Transparency = 1,
			}):Play()
		end)
	end

	local gameplayApi = model:FindFirstChild("Gameplay")
	local requestAbility = gameplayApi and gameplayApi:FindFirstChild("RequestAbility")
	local applyDamage = gameplayApi and gameplayApi:FindFirstChild("ApplyDamage")
	local resetGameplay = gameplayApi and (gameplayApi:FindFirstChild("Reset") or gameplayApi:FindFirstChild("ResetGuardian"))
	local abilityRequested = gameplayApi and gameplayApi:FindFirstChild("AbilityRequested")
	local stateChanged = gameplayApi and gameplayApi:FindFirstChild("StateChanged")
	local damageTaken = gameplayApi and gameplayApi:FindFirstChild("DamageTaken")
	local healthChanged = gameplayApi and gameplayApi:FindFirstChild("HealthChanged")
	local wardenStaggered = gameplayApi and gameplayApi:FindFirstChild("Staggered")
	local wardenDefeated = gameplayApi and gameplayApi:FindFirstChild("Defeated")

	local function broadcast(message)
		remote:FireAllClients(message, model)
	end

	if abilityRequested and abilityRequested:IsA("BindableEvent") then
		abilityRequested.Event:Connect(function(name, target, ability)
			if name == "RiotShield" then
				broadcast("PlayShieldBlock")
				task.delay(ability.Duration, function()
					if model:GetAttribute("GuardianState") ~= "Defeated" then broadcast("PlayIdle") end
				end)
			elseif name == "PulseCannon" then
				broadcast("PlayPulseCannonFire")
				task.delay(0.9, firePulsePreview)
				task.delay(1.62, function()
					if model:GetAttribute("GuardianState") ~= "Defeated" then broadcast("PlayIdle") end
				end)
			elseif name == "ContainmentNet" then
				broadcast("PlayContainmentNetLaunch")
				setEnemyLocked(true)
				task.delay(1.35, function()
					setEnemyLocked(false)
					launchNetPreview()
				end)
				task.delay(2.1, function()
					if model:GetAttribute("GuardianState") ~= "Defeated" then broadcast("PlayIdle") end
				end)
			end
		end)
	end

	if damageTaken and damageTaken:IsA("BindableEvent") then
		damageTaken.Event:Connect(function(healthDamage)
			if healthDamage > 0 and model:GetAttribute("GuardianState") ~= "Defeated" then
				broadcast("PlayDamageReact")
			end
		end)
	end

	if stateChanged and stateChanged:IsA("BindableEvent") then
		stateChanged.Event:Connect(function(newState)
			if newState == "Staggered" then
				broadcast("PlayStagger")
			elseif newState == "Defeated" then
				broadcast("PlayDefeat")
			elseif newState == "Idle" then
				broadcast("PlayIdle")
			end
		end)
	end

	-- Warden-I uses dedicated gameplay events instead of Marshal-II's generic events.
	if healthChanged and healthChanged:IsA("BindableEvent") then
		healthChanged.Event:Connect(function(currentHealth, _, source)
			if source ~= "Reset" and currentHealth > 0 then broadcast("PlayDamageReact") end
			if source == "Reset" then broadcast("PlayIdle") end
		end)
	end
	if wardenStaggered and wardenStaggered:IsA("BindableEvent") then
		wardenStaggered.Event:Connect(function()
			broadcast("PlayStagger")
		end)
	end
	if wardenDefeated and wardenDefeated:IsA("BindableEvent") then
		wardenDefeated.Event:Connect(function()
			broadcast("PlayDefeat")
		end)
	end

	local function invokeAbility(name)
		if not requestAbility or not requestAbility:IsA("BindableFunction") then return false end
		local target = workspace:FindFirstChild("TestKaijuTarget", true)
		local ok, reason = requestAbility:Invoke(name, target)
		if not ok then warn("Guardian ability request rejected:", name, reason) end
		return ok
	end

	remote.OnServerEvent:Connect(function(player, actionName, payload, option, backwardOption)
		if type(actionName) ~= "string" then return end
		if actionName == "ControlMove" then
			if player == controllerPlayer and typeof(payload) == "Vector3" then
				local flat = Vector3.new(payload.X, 0, payload.Z)
				controlDirection = flat.Magnitude > 1 and flat.Unit or flat
				local nextRunning = option == true
				local nextBackward = backwardOption == true
				if nextRunning ~= controlRunning or nextBackward ~= controlBackward then
					controlRunning = nextRunning
					controlBackward = nextBackward
					movementStartedAt = os.clock()
				end
				controlUpdatedAt = os.clock()
			end
			return
		end
		if not actions[actionName] then return end
		local now = os.clock()
		if lastRequest[player] and now - lastRequest[player] < 0.12 then return end
		lastRequest[player] = now
		if actionName == "ControlGuardian" then
			if controllerPlayer == player then
				controllerPlayer = nil
				controlDirection = Vector3.zero
				wasControlMoving = false
				remote:FireClient(player, "ControlDisabled")
			else
				if controllerPlayer then remote:FireClient(controllerPlayer, "ControlDisabled") end
				controllerPlayer = player
				controlDirection = Vector3.zero
				wasControlMoving = false
				controlUpdatedAt = os.clock()
				remote:FireClient(player, "ControlEnabled", model)
			end
		elseif actionName == "IdleLoop" then
			remote:FireClient(player, "PlayIdle", model)
		elseif actionName == "AlertIdle" then
			remote:FireClient(player, "PlayAlertIdle", model)
		elseif actionName == "Walk" then
			remote:FireClient(player, "PlayWalk", model)
			requestSound("FootstepWalk")
		elseif actionName == "Run" then
			remote:FireClient(player, "PlayRun", model)
			requestSound("FootstepRun")
		elseif actionName == "TurnLeft" then
			remote:FireClient(player, "PlayTurnLeft", model)
		elseif actionName == "TurnRight" then
			remote:FireClient(player, "PlayTurnRight", model)
		elseif actionName == "Fall" then
			remote:FireClient(player, "PlayFall", model)
		elseif actionName == "Land" then
			remote:FireClient(player, "PlayLand", model)
			requestSound("Land")
		elseif actionName == "WalkBackward" then
			remote:FireClient(player, "PlayWalkBackward", model)
		elseif actionName == "DamageReact" then
			if applyDamage and applyDamage:IsA("BindableFunction") then
				applyDamage:Invoke(250, true)
			else
				remote:FireClient(player, "PlayDamageReact", model)
			end
		elseif actionName == "Stagger" then
			if applyDamage and applyDamage:IsA("BindableFunction") then
				applyDamage:Invoke(model:GetAttribute("StaggerThreshold") or 1800, false)
			else
				remote:FireClient(player, "PlayStagger", model)
			end
		elseif actionName == "Defeat" then
			if applyDamage and applyDamage:IsA("BindableFunction") then
				applyDamage:Invoke(model:GetAttribute("Health") or 999999, false)
			else
				remote:FireClient(player, "PlayDefeat", model)
			end
		elseif actionName == "ShockBaton" then
			remote:FireClient(player, "PlayShockBaton", model)
			task.delay(0.56, function()
				shockBatonPreview()
				invokeAbility("ShockBaton")
			end)
		elseif actionName == "ShieldBlock" then
			if not invokeAbility("RiotShield") then remote:FireClient(player, "PlayShieldBlock", model) end
		elseif actionName == "PulseCannonFire" then
			if not invokeAbility("PulseCannon") then
				remote:FireClient(player, "PlayPulseCannonFire", model)
				task.delay(0.9, firePulsePreview)
			end
		elseif actionName == "ContainmentNetLaunch" then
			if not invokeAbility("ContainmentNet") then
				remote:FireClient(player, "PlayContainmentNetLaunch", model)
				setEnemyLocked(true)
				task.delay(1.35, function()
					setEnemyLocked(false)
					launchNetPreview()
				end)
			end
		else
			if actionName == "Neutral" and resetGameplay and resetGameplay:IsA("BindableFunction") then
				resetGameplay:Invoke()
			end
			actions[actionName]()
		end
		remote:FireClient(player, "Completed", actionName)
	end)

	model:SetAttribute("FleetRigMotionTestReady", true)
	model:SetAttribute("FleetRigMotionDriver", "Motor6D.C0")
	model:SetAttribute("GuardianIdlePreviewReady", true)
	model:SetAttribute("GuardianAlertIdlePreviewReady", true)
	model:SetAttribute("GuardianWalkPreviewReady", true)
	model:SetAttribute("GuardianRunPreviewReady", true)
	model:SetAttribute("GuardianTurnPreviewReady", true)
	model:SetAttribute("GuardianAirStatePreviewReady", true)
	model:SetAttribute("GuardianWalkBackwardPreviewReady", true)
	model:SetAttribute("GuardianDamageReactPreviewReady", true)
	model:SetAttribute("GuardianStaggerPreviewReady", true)
	model:SetAttribute("GuardianDefeatPreviewReady", true)
	model:SetAttribute("WardenShockBatonPreviewReady", true)
	model:SetAttribute("GuardianShieldBlockPreviewReady", true)
	model:SetAttribute("GuardianPulseCannonFirePreviewReady", true)
	model:SetAttribute("GuardianContainmentNetLaunchPreviewReady", true)
	model:SetAttribute("FleetRigTestInterface", "HUD")
	model:SetAttribute("GuardianPossessionTestReady", true)
	model:SetAttribute("GuardianControlSpeed", controlSpeed)
	model:SetAttribute("GuardianRunSpeed", runSpeed)
	model:SetAttribute("GuardianLocomotionMode", "StepDriven")
	model:SetAttribute("GuardianStepDuration", walkStepDuration)
	model:SetAttribute("GuardianRunStepDuration", runStepDuration)
	return remote
end

return Harness
