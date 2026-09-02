local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Reactions = {}

local function effectsFolder()
	local folder = workspace:FindFirstChild("AegisRuntimeEffects")
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "AegisRuntimeEffects"
		folder.Parent = workspace
	end
	return folder
end

local function targetPosition(model, target, range)
	if typeof(target) == "Instance" then
		if target:IsA("BasePart") then return target.Position end
		if target:IsA("Model") then return target:GetPivot().Position end
	end
	local root = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
	return root.Position + root.CFrame.LookVector * range
end

local function lockedWarning(target, enabled)
	if not target or not target:IsA("BasePart") then return end
	local gui = target:FindFirstChild("AegisTargetLocked")
	if not gui then
		gui = Instance.new("BillboardGui")
		gui.Name = "AegisTargetLocked"
		gui.Size = UDim2.fromOffset(300, 78)
		gui.StudsOffset = Vector3.new(0, 8.5, 0)
		gui.AlwaysOnTop = true
		gui.Parent = target
		local label = Instance.new("TextLabel")
		label.Size = UDim2.fromScale(1, 1)
		label.BackgroundColor3 = Color3.fromRGB(127, 66, 24)
		label.BackgroundTransparency = 0.08
		label.BorderSizePixel = 0
		label.Text = "⚠ MISSILE LOCK ⚠"
		label.TextColor3 = Color3.fromRGB(255, 230, 183)
		label.Font = Enum.Font.GothamBlack
		label.TextScaled = true
		label.Parent = gui
		local stroke = Instance.new("UIStroke")
		stroke.Color = Color3.fromRGB(255, 155, 62)
		stroke.Thickness = 3
		stroke.Parent = label
	end
	gui.Enabled = enabled
end

local function impact(position, color, radius)
	local wave = Instance.new("Part")
	wave.Name = "AegisAbilityImpact"
	wave.Shape = Enum.PartType.Ball
	wave.Size = Vector3.new(3, 3, 3)
	wave.Position = position
	wave.Anchored = true
	wave.CanCollide = false
	wave.CanTouch = false
	wave.CanQuery = false
	wave.Material = Enum.Material.ForceField
	wave.Color = color
	wave.Transparency = 0.25
	wave.Parent = effectsFolder()
	Debris:AddItem(wave, 0.5)
	TweenService:Create(wave, TweenInfo.new(0.42, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = Vector3.new(radius, radius, radius),
		Transparency = 1,
	}):Play()
end

local function fireIon(model, target, config)
	task.delay(config.TelegraphDuration or 0.55, function()
		if not model.Parent then return end
		local destination = targetPosition(model, target, config.Range or 95)
		for index, side in ipairs({"Left", "Right"}) do
			local muzzle = model:FindFirstChild(side .. "IonCannon", true)
			muzzle = muzzle and muzzle:FindFirstChild("IonMuzzleCore", true)
			if muzzle and muzzle:IsA("BasePart") then
				local pulse = Instance.new("Part")
				pulse.Name = side .. "IonProjectile"
				pulse.Shape = Enum.PartType.Ball
				pulse.Size = Vector3.new(2.3, 2.3, 2.3)
				pulse.Position = muzzle.Position
				pulse.Anchored = true
				pulse.CanCollide = false
				pulse.CanTouch = false
				pulse.CanQuery = false
				pulse.Material = Enum.Material.Neon
				pulse.Color = Color3.fromRGB(62, 218, 255)
				pulse.Parent = effectsFolder()
				Debris:AddItem(pulse, 1.5)
				local offset = Vector3.new((index == 1 and -1 or 1) * 1.2, 0, 0)
				local duration = math.clamp((destination - muzzle.Position).Magnitude / 135, 0.18, 0.65)
				local tween = TweenService:Create(pulse, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
					Position = destination + offset,
					Size = Vector3.new(3.1, 3.1, 3.1),
				})
				tween:Play()
				tween.Completed:Connect(function()
					if pulse.Parent then
						local position = pulse.Position
						pulse:Destroy()
						impact(position, Color3.fromRGB(95, 231, 255), 14)
					end
				end)
			end
		end
	end)
end


local function launchSmoke(position)
	local anchor = Instance.new("Part")
	anchor.Name = "AegisMissileLaunchSmoke"
	anchor.Size = Vector3.new(0.2, 0.2, 0.2)
	anchor.Position = position
	anchor.Anchored = true
	anchor.CanCollide = false
	anchor.CanTouch = false
	anchor.CanQuery = false
	anchor.Transparency = 1
	anchor.Parent = effectsFolder()
	local emitter = Instance.new("ParticleEmitter")
	emitter.Name = "LaunchSmokeCloud"
	emitter.Texture = "rbxasset://textures/particles/smoke_main.dds"
	emitter.Rate = 0
	emitter.Lifetime = NumberRange.new(0.65, 1.0)
	emitter.Speed = NumberRange.new(5, 10)
	emitter.SpreadAngle = Vector2.new(48, 48)
	emitter.Rotation = NumberRange.new(0, 360)
	emitter.RotSpeed = NumberRange.new(-35, 35)
	emitter.Drag = 4
	emitter.Color = ColorSequence.new(Color3.fromRGB(174, 184, 192), Color3.fromRGB(72, 83, 94))
	emitter.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.28),
		NumberSequenceKeypoint.new(0.7, 0.62),
		NumberSequenceKeypoint.new(1, 1),
	})
	emitter.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 2.2),
		NumberSequenceKeypoint.new(0.45, 5.5),
		NumberSequenceKeypoint.new(1, 8.5),
	})
	emitter.Parent = anchor
	emitter:Emit(30)
	Debris:AddItem(anchor, 1.4)
end

local function addMissileExhaust(missile)
	local inner = Instance.new("Attachment")
	inner.Name = "ExhaustInner"
	inner.Position = Vector3.new(0, 0, 0.85)
	inner.Parent = missile
	local outer = Instance.new("Attachment")
	outer.Name = "ExhaustOuter"
	outer.Position = Vector3.new(0, 0, 1.55)
	outer.Parent = missile

	local trail = Instance.new("Trail")
	trail.Name = "HotExhaustTrail"
	trail.Attachment0 = inner
	trail.Attachment1 = outer
	trail.Lifetime = 0.24
	trail.MinLength = 0.05
	trail.FaceCamera = true
	trail.LightEmission = 1
	trail.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(235, 250, 255)),
		ColorSequenceKeypoint.new(0.35, Color3.fromRGB(89, 220, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 148, 58)),
	})
	trail.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.04),
		NumberSequenceKeypoint.new(0.75, 0.35),
		NumberSequenceKeypoint.new(1, 1),
	})
	trail.WidthScale = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.9),
		NumberSequenceKeypoint.new(1, 0),
	})
	trail.Parent = missile

	local smoke = Instance.new("ParticleEmitter")
	smoke.Name = "MissileSmokeTrail"
	smoke.Texture = "rbxasset://textures/particles/smoke_main.dds"
	smoke.Rate = 20
	smoke.Lifetime = NumberRange.new(0.55, 0.78)
	smoke.Speed = NumberRange.new(0.8, 2.2)
	smoke.Drag = 3
	smoke.Rotation = NumberRange.new(0, 360)
	smoke.RotSpeed = NumberRange.new(-45, 45)
	smoke.SpreadAngle = Vector2.new(12, 12)
	smoke.Color = ColorSequence.new(Color3.fromRGB(142, 155, 166), Color3.fromRGB(58, 68, 79))
	smoke.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.35),
		NumberSequenceKeypoint.new(0.62, 0.58),
		NumberSequenceKeypoint.new(1, 1),
	})
	smoke.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.75),
		NumberSequenceKeypoint.new(0.45, 1.9),
		NumberSequenceKeypoint.new(1, 3.2),
	})
	smoke.Parent = outer
end


local function launchMissiles(model, target, config)
	lockedWarning(target, true)
	task.delay(config.LockDuration or 1.4, function()
		lockedWarning(target, false)
		if not model.Parent then return end
		local destination = targetPosition(model, target, config.Range or 130)
		local cells = {}
		local sideCells = {Left = {}, Right = {}}
		local launchFaces = {}
		for _, side in ipairs({"Left", "Right"}) do
			local pod = model:FindFirstChild(side .. "ShoulderMissilePod", true)
			local face = pod and pod:FindFirstChild("LauncherFace", true)
			if face and face:IsA("BasePart") then launchFaces[side] = face end
			if pod then
				for _, item in ipairs(pod:GetDescendants()) do
					if item:IsA("BasePart") and string.find(item.Name, "MissileCell", 1, true) then
						table.insert(sideCells[side], item)
					end
				end
				table.sort(sideCells[side], function(a, b) return a.Name < b.Name end)
			end
		end
		local perSide = math.ceil((config.MissileCount or 8) * 0.5)
		for index = 1, perSide do
			if sideCells.Left[index] then table.insert(cells, sideCells.Left[index]) end
		end
		for index = 1, perSide do
			if sideCells.Right[index] then table.insert(cells, sideCells.Right[index]) end
		end
		if launchFaces.Left then launchSmoke(launchFaces.Left.Position) end
		if launchFaces.Right then
			task.delay(0.62, function()
				if launchFaces.Right.Parent then launchSmoke(launchFaces.Right.Position) end
			end)
		end
		for index = 1, math.min(config.MissileCount or 8, #cells) do
			local cell = cells[index]
			local launchDelay = index <= perSide
				and ((index - 1) * 0.11)
				or (0.62 + (index - perSide - 1) * 0.11)
			task.delay(launchDelay, function()
				if not cell.Parent then return end
				local missile = Instance.new("Part")
				missile.Name = "AegisShoulderMissile"
				missile.Size = Vector3.new(0.7, 0.7, 2.4)
				missile.CFrame = cell.CFrame
				missile.Anchored = true
				missile.CanCollide = false
				missile.CanTouch = false
				missile.CanQuery = false
				missile.Material = Enum.Material.Metal
				missile.Color = Color3.fromRGB(185, 190, 195)
				missile.Parent = effectsFolder()
				addMissileExhaust(missile)
				Debris:AddItem(missile, 2)
				local start = missile.Position
				local lateral = ((index % 2 == 0) and 1 or -1) * (3 + index * 0.3)
				local apex = (start + destination) * 0.5 + Vector3.new(lateral, 27 + index, 0)
				local began = os.clock()
				local duration = config.FlightDuration or 1.1
				local connection
				connection = RunService.Heartbeat:Connect(function()
					local alpha = math.clamp((os.clock() - began) / duration, 0, 1)
					local inverse = 1 - alpha
					local position = inverse * inverse * start + 2 * inverse * alpha * apex + alpha * alpha * destination
					local nextAlpha = math.min(1, alpha + 0.02)
					local nextInverse = 1 - nextAlpha
					local nextPosition = nextInverse * nextInverse * start + 2 * nextInverse * nextAlpha * apex + nextAlpha * nextAlpha * destination
					missile.CFrame = CFrame.lookAt(position, nextPosition)
					if alpha >= 1 then
						connection:Disconnect()
						missile:Destroy()
						impact(destination, Color3.fromRGB(255, 156, 63), config.SplashRadius or 12)
					end
				end)
			end)
		end
	end)
end

function Reactions.Attach(model)
	local gameplay = model:WaitForChild("Gameplay")
	local abilityRequested = gameplay:WaitForChild("AbilityRequested")
	local stateChanged = gameplay:WaitForChild("StateChanged")
	local activeField = {}
	local fieldToken = 0

	local function clearField()
		fieldToken += 1
		for _, panel in ipairs(activeField) do
			if panel.Parent then
				TweenService:Create(panel, TweenInfo.new(0.18), {Transparency = 1}):Play()
				Debris:AddItem(panel, 0.2)
			end
		end
		activeField = {}
	end

	local function deployField(config)
		clearField()
		local token = fieldToken
		local root = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
		local torso = model:FindFirstChild("UpperTorso") or root
		if not root or not torso then return end
		for index, data in ipairs({
			{Vector3.new(-7.4, 6.5, -8), 18},
			{Vector3.new(0, 6.2, -9), 0},
			{Vector3.new(7.4, 6.5, -8), -18},
		}) do
			local panel = Instance.new("Part")
			panel.Name = "DirectionalAegisField" .. index
			panel.Size = Vector3.new(8.5, 14, 0.35)
			panel.CFrame = root.CFrame * CFrame.new(data[1]) * CFrame.Angles(0, math.rad(data[2]), 0)
			panel.Anchored = false
			panel.CanCollide = false
			panel.CanTouch = false
			panel.CanQuery = false
			panel.Massless = true
			panel.Material = Enum.Material.ForceField
			panel.Color = Color3.fromRGB(62, 218, 255)
			panel.Transparency = 1
			panel.Parent = effectsFolder()
			local outline = Instance.new("Highlight")
			outline.Name = "DirectionalAegisOutline"
			outline.Adornee = panel
			outline.DepthMode = Enum.HighlightDepthMode.Occluded
			outline.FillColor = Color3.fromRGB(62, 218, 255)
			outline.FillTransparency = 0.72
			outline.OutlineColor = Color3.fromRGB(184, 246, 255)
			outline.OutlineTransparency = 0
			outline.Parent = panel

			-- Physical neon edge bars keep the ForceField readable from every angle.
			for edgeIndex, edge in ipairs({
				{Vector3.new(0.28, panel.Size.Y, 0.42), CFrame.new(-panel.Size.X * 0.5, 0, 0)},
				{Vector3.new(0.28, panel.Size.Y, 0.42), CFrame.new(panel.Size.X * 0.5, 0, 0)},
				{Vector3.new(panel.Size.X, 0.28, 0.42), CFrame.new(0, panel.Size.Y * 0.5, 0)},
				{Vector3.new(panel.Size.X, 0.28, 0.42), CFrame.new(0, -panel.Size.Y * 0.5, 0)},
			}) do
				local border = Instance.new("Part")
				border.Name = "AegisEdge" .. edgeIndex
				border.Size = edge[1]
				border.CFrame = panel.CFrame * edge[2]
				border.Anchored = false
				border.CanCollide = false
				border.CanTouch = false
				border.CanQuery = false
				border.Massless = true
				border.CastShadow = false
				border.Material = Enum.Material.Neon
				border.Color = Color3.fromRGB(108, 235, 255)
				border.Parent = panel
				local edgeWeld = Instance.new("WeldConstraint")
				edgeWeld.Part0 = panel
				edgeWeld.Part1 = border
				edgeWeld.Parent = border
			end
			if index == 2 then
				local fieldLight = Instance.new("PointLight")
				fieldLight.Name = "DirectionalAegisGlow"
				fieldLight.Color = Color3.fromRGB(62, 218, 255)
				fieldLight.Brightness = 5
				fieldLight.Range = 34
				fieldLight.Shadows = false
				fieldLight.Parent = panel
			end
			local weld = Instance.new("WeldConstraint")
			weld.Part0 = torso
			weld.Part1 = panel
			weld.Parent = panel
			table.insert(activeField, panel)
			TweenService:Create(panel, TweenInfo.new(0.24, Enum.EasingStyle.Quad), {Transparency = 0.16}):Play()
		end
		task.delay(config.Duration, function()
			if token == fieldToken then clearField() end
		end)
	end

	abilityRequested.Event:Connect(function(name, target, config)
		if name == "TwinIonCannons" then fireIon(model, target, config)
		elseif name == "ShoulderMissiles" then launchMissiles(model, target, config)
		elseif name == "DirectionalAegis" then deployField(config) end
	end)
	stateChanged.Event:Connect(function(state)
		if state == "Idle" or state == "Defeated" then clearField() end
	end)

	model:SetAttribute("AegisAbilityVFXReady", true)
	model:SetAttribute("AegisVFXUsesPermanentParts", false)
	return model
end

return Reactions
