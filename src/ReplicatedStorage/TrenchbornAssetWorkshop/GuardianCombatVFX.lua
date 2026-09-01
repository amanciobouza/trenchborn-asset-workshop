local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local VFX = {}

local function effectsFolder()
	local folder = workspace:FindFirstChild("GuardianRuntimeEffects")
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "GuardianRuntimeEffects"
		folder.Parent = workspace
	end
	return folder
end

local function targetPosition(model, target, distance)
	if typeof(target) == "Instance" then
		if target:IsA("BasePart") then return target.Position end
		if target:IsA("Model") then return target:GetPivot().Position end
	end
	local root = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
	return root.Position + root.CFrame.LookVector * distance
end

local function lockedWarning(target, enabled)
	if not target or not target:IsA("BasePart") then return end
	local gui = target:FindFirstChild("GuardianEnemyLocked")
	if not gui then
		gui = Instance.new("BillboardGui")
		gui.Name = "GuardianEnemyLocked"
		gui.Size = UDim2.fromOffset(300, 78)
		gui.StudsOffset = Vector3.new(0, 8.5, 0)
		gui.AlwaysOnTop = true
		gui.Parent = target
		local label = Instance.new("TextLabel")
		label.Size = UDim2.fromScale(1, 1)
		label.BackgroundColor3 = Color3.fromRGB(107, 24, 30)
		label.BackgroundTransparency = 0.08
		label.BorderSizePixel = 0
		label.Text = "⚠ ENEMY LOCKED ⚠"
		label.TextColor3 = Color3.fromRGB(255, 226, 184)
		label.Font = Enum.Font.GothamBlack
		label.TextScaled = true
		label.Parent = gui
		local stroke = Instance.new("UIStroke")
		stroke.Color = Color3.fromRGB(255, 91, 91)
		stroke.Thickness = 3
		stroke.Parent = label
	end
	gui.Enabled = enabled
end

function VFX.Pulse(model, target, ability)
	task.delay(0.9, function()
		if not model.Parent then return end
		local muzzle = model:FindFirstChild("MuzzleCore", true)
		if not muzzle or not muzzle:IsA("BasePart") then return end
		local destination = targetPosition(model, target, ability.Range or 48)
		local pulse = Instance.new("Part")
		pulse.Name = "GuardianPulseProjectile"
		pulse.Shape = Enum.PartType.Ball
		pulse.Size = Vector3.new(3.2, 3.2, 3.2)
		pulse.Position = muzzle.Position
		pulse.Anchored = true
		pulse.CanCollide = false
		pulse.CanTouch = false
		pulse.CanQuery = false
		pulse.Material = Enum.Material.Neon
		pulse.Color = Color3.fromRGB(63, 217, 255)
		pulse.Parent = effectsFolder()
		Debris:AddItem(pulse, 2)
		local light = Instance.new("PointLight")
		light.Color = pulse.Color
		light.Brightness = 7
		light.Range = 22
		light.Parent = pulse
		local duration = math.clamp((destination - muzzle.Position).Magnitude / 105, 0.18, 0.55)
		local travel = TweenService:Create(pulse, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
			Position = destination,
			Size = Vector3.new(4.2, 4.2, 4.2),
		})
		travel:Play()
		travel.Completed:Connect(function()
			if not pulse.Parent then return end
			pulse:Destroy()
			local wave = Instance.new("Part")
			wave.Name = "GuardianPulsePressureWave"
			wave.Shape = Enum.PartType.Ball
			wave.Size = Vector3.new(5, 5, 5)
			wave.Position = destination
			wave.Anchored = true
			wave.CanCollide = false
			wave.CanTouch = false
			wave.CanQuery = false
			wave.Material = Enum.Material.ForceField
			wave.Color = Color3.fromRGB(151, 239, 255)
			wave.Transparency = 0.32
			wave.Parent = effectsFolder()
			Debris:AddItem(wave, 0.6)
			TweenService:Create(wave, TweenInfo.new(0.48, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = Vector3.new(24, 24, 24),
				Transparency = 1,
			}):Play()
			if target and target:IsA("BasePart") and not target.Anchored then
				local root = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
				local away = target.Position - root.Position
				if away.Magnitude > 0.01 then target:ApplyImpulse(away.Unit * target.AssemblyMass * (ability.KnockbackStuds or 11)) end
			end
		end)
	end)
end

function VFX.ContainmentNet(model, target, ability)
	local baseTarget = target and (target:IsA("BasePart") and target or nil)
	lockedWarning(baseTarget, true)
	task.delay(1.35, function()
		lockedWarning(baseTarget, false)
		if not model.Parent then return end
		local mouth = model:FindFirstChild("LaunchMouth", true)
		if not mouth or not mouth:IsA("BasePart") then return end
		local destination = targetPosition(model, target, 42)
		local ground = Vector3.new(destination.X, destination.Y, destination.Z)
		local source = Instance.new("Attachment")
		source.Name = "NetLauncherTetherSource"
		source.Parent = mouth
		Debris:AddItem(source, (ability.Duration or 4) + 2)

		local count = ability.NodeCount or 5
		local nodes = {}
		for index = 1, count do
			local node = Instance.new("Part")
			node.Name = "ContainmentNetNode" .. index
			node.Shape = Enum.PartType.Ball
			node.Size = Vector3.new(1.4, 1.4, 1.4)
			node.Position = mouth.Position
			node.Anchored = true
			node.CanCollide = false
			node.Material = Enum.Material.Neon
			node.Color = Color3.fromRGB(63, 226, 255)
			node.Parent = effectsFolder()
			Debris:AddItem(node, (ability.Duration or 4) + 2)
			local attachment = Instance.new("Attachment")
			attachment.Parent = node
			local tether = Instance.new("Beam")
			tether.Attachment0 = source
			tether.Attachment1 = attachment
			tether.Color = ColorSequence.new(Color3.fromRGB(63, 226, 255))
			tether.Width0 = 0.18
			tether.Width1 = 0.1
			tether.LightEmission = 0.9
			tether.FaceCamera = true
			tether.Parent = node
			nodes[index] = node
		end

		local started = os.clock()
		local flight = 0.92
		local connection
		connection = RunService.Heartbeat:Connect(function()
			local alpha = math.clamp((os.clock() - started) / flight, 0, 1)
			local inverse = 1 - alpha
			for index, node in ipairs(nodes) do
				if node.Parent then
					local angle = (index - 1) / count * math.pi * 2
					local landing = ground + Vector3.new(math.cos(angle) * 5, ((index % 2) * 4) - 1, math.sin(angle) * 5)
					local apex = (mouth.Position + landing) * 0.5 + Vector3.new(0, 27 + index * 1.2, 0)
					node.Position = inverse * inverse * mouth.Position + 2 * inverse * alpha * apex + alpha * alpha * landing
				end
			end
			if alpha >= 1 then
				connection:Disconnect()
				for index, node in ipairs(nodes) do
					local nextNode = nodes[index % count + 1]
					if node.Parent and nextNode and nextNode.Parent then
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
				task.delay(ability.Duration or 4, function()
					for _, node in ipairs(nodes) do if node.Parent then node:Destroy() end end
					if source.Parent then source:Destroy() end
				end)
			end
		end)
	end)
end

return VFX
