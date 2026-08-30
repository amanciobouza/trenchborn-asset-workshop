local TweenService = game:GetService("TweenService")

local Reactions = {}

local HIT_FLASH = Color3.fromRGB(218, 76, 67)
local PULSE_FLASH = Color3.fromRGB(226, 255, 238)

local function tweenPivot(targetModel, targetCFrame, duration, easingStyle, easingDirection)
	local driver = Instance.new("CFrameValue")
	driver.Value = targetModel:GetPivot()
	local connection = driver:GetPropertyChangedSignal("Value"):Connect(function()
		targetModel:PivotTo(driver.Value)
	end)
	local tween = TweenService:Create(
		driver,
		TweenInfo.new(
			duration,
			easingStyle or Enum.EasingStyle.Quad,
			easingDirection or Enum.EasingDirection.Out
		),
		{Value = targetCFrame}
	)
	tween.Completed:Connect(function()
		connection:Disconnect()
		driver:Destroy()
	end)
	tween:Play()
	return tween
end

local function collectVisibleParts(folder)
	local result = {}
	if not folder then
		return result
	end
	for _, descendant in ipairs(folder:GetDescendants()) do
		if descendant:IsA("BasePart") and descendant.Transparency < 1 then
			table.insert(result, descendant)
		end
	end
	return result
end

local function captureColors(parts)
	local colors = {}
	for _, part in ipairs(parts) do
		colors[part] = part.Color
	end
	return colors
end

local function restoreColors(colors)
	for part, color in pairs(colors) do
		if part.Parent then
			part.Color = color
		end
	end
end

local function flash(parts, colors, flashColor, duration)
	for _, part in ipairs(parts) do
		if part.Parent then
			part.Color = flashColor
		end
	end
	task.delay(duration, function()
		restoreColors(colors)
	end)
end

local function appendPart(parts, value)
	if value and value:IsA("BasePart") then
		table.insert(parts, value)
	end
end

local function appendDescendantParts(parts, container)
	if not container then
		return
	end
	for _, descendant in ipairs(container:GetDescendants()) do
		appendPart(parts, descendant)
	end
end

local function captureCFrames(parts)
	local result = {}
	for _, part in ipairs(parts) do
		result[part] = part.CFrame
	end
	return result
end

function Reactions.Attach(model)
	local gameplay = model:WaitForChild("Gameplay")
	local healthChanged = gameplay:WaitForChild("HealthChanged")
	local staggered = gameplay:WaitForChild("Staggered")
	local defeated = gameplay:WaitForChild("Defeated")
	local batonStrikeRequested = gameplay:WaitForChild("BatonStrikeRequested")
	local warningPulseRequested = gameplay:WaitForChild("WarningPulseRequested")
	local protectedBuilding = gameplay:WaitForChild("ProtectedBuilding")

	local armorParts = collectVisibleParts(model:FindFirstChild("Armor"))
	local armorColors = captureColors(armorParts)
	local restPivot = model:GetPivot()
	local baton = model:FindFirstChild("ShockBaton", true)
	local shoulderBearing = model:FindFirstChild("LeftShoulderBearingDrum", true)
	local elbowBearing = model:FindFirstChild("LeftElbowBearing", true)
	local upperArmParts = {}
	local lowerArmParts = {}
	appendPart(upperArmParts, model:FindFirstChild("LeftUpperArm", true))
	appendPart(upperArmParts, model:FindFirstChild("LeftUpperArmPlate", true))
	appendPart(upperArmParts, elbowBearing)
	appendPart(lowerArmParts, model:FindFirstChild("LeftForearm", true))
	appendPart(lowerArmParts, model:FindFirstChild("LeftForearmPlate", true))
	appendDescendantParts(lowerArmParts, model:FindFirstChild("LeftHand", true))
	appendDescendantParts(lowerArmParts, baton)
	local upperArmCFrames = captureCFrames(upperArmParts)
	local lowerArmCFrames = captureCFrames(lowerArmParts)
	local shoulderPivot = shoulderBearing and CFrame.new(shoulderBearing.Position)
	local elbowPivot = elbowBearing and CFrame.new(elbowBearing.Position)
	local strikeBusy = false
	local currentArmPose = Vector3.zero
	local visor = model:FindFirstChild("VisorSensor", true)
	local pulseCore = model:FindFirstChild("ChestPulseCore", true)
	local pulseParts = collectVisibleParts(pulseCore)
	if visor then
		table.insert(pulseParts, visor)
	end
	local pulseColors = captureColors(pulseParts)

	local function applyArmPose(shoulderDegrees, elbowDegrees)
		if not shoulderPivot or not elbowPivot then
			return
		end
		local shoulderTransform = shoulderPivot
			* CFrame.Angles(math.rad(shoulderDegrees), 0, 0)
			* shoulderPivot:Inverse()
		local elbowTransform = elbowPivot
			* CFrame.Angles(math.rad(elbowDegrees), 0, 0)
			* elbowPivot:Inverse()
		for part, original in pairs(upperArmCFrames) do
			if part.Parent then
				part.CFrame = shoulderTransform * original
			end
		end
		for part, original in pairs(lowerArmCFrames) do
			if part.Parent then
				part.CFrame = shoulderTransform * elbowTransform * original
			end
		end
	end

	local function tweenArmPose(targetPose, duration, easingStyle)
		local driver = Instance.new("Vector3Value")
		driver.Value = currentArmPose
		local connection = driver:GetPropertyChangedSignal("Value"):Connect(function()
			currentArmPose = driver.Value
			applyArmPose(driver.Value.X, driver.Value.Y)
		end)
		local tween = TweenService:Create(
			driver,
			TweenInfo.new(duration, easingStyle or Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{Value = targetPose}
		)
		tween.Completed:Connect(function()
			connection:Disconnect()
			driver:Destroy()
		end)
		tween:Play()
		return tween
	end

	healthChanged.Event:Connect(function(_, _, source)
		if source == "Reset" then
			model:PivotTo(restPivot)
			applyArmPose(0, 0)
			currentArmPose = Vector3.zero
			strikeBusy = false
			restoreColors(armorColors)
			restoreColors(pulseColors)
			return
		end
		flash(armorParts, armorColors, HIT_FLASH, 0.16)
	end)

	staggered.Event:Connect(function(duration)
		local staggerPivot = restPivot * CFrame.Angles(math.rad(-7), 0, math.rad(2))
		local outward = tweenPivot(model, staggerPivot, 0.18, Enum.EasingStyle.Back)
		outward.Completed:Connect(function()
			task.delay(math.max(0, duration - 0.38), function()
				tweenPivot(model, restPivot, 0.2, Enum.EasingStyle.Quad)
			end)
		end)
	end)

	batonStrikeRequested.Event:Connect(function()
		if strikeBusy or not shoulderPivot or not elbowPivot then
			return
		end
		strikeBusy = true
		local windupTween = tweenArmPose(Vector3.new(-12, -8, 0), 0.14, Enum.EasingStyle.Quad)
		windupTween.Completed:Connect(function()
			local swingTween = tweenArmPose(Vector3.new(48, 22, 0), 0.18, Enum.EasingStyle.Quart)
			swingTween.Completed:Connect(function()
				local returnTween = tweenArmPose(Vector3.zero, 0.22, Enum.EasingStyle.Quad)
				returnTween.Completed:Connect(function()
					applyArmPose(0, 0)
					currentArmPose = Vector3.zero
					strikeBusy = false
				end)
			end)
		end)
	end)

	warningPulseRequested.Event:Connect(function(_, pulseConfig)
		flash(pulseParts, pulseColors, PULSE_FLASH, pulseConfig.TelegraphDuration)
		model:SetAttribute("GuardianState", "WarningPulse")
		task.delay(pulseConfig.TelegraphDuration, function()
			if model:GetAttribute("GuardianState") == "WarningPulse" then
				model:SetAttribute("GuardianState", "Idle")
			end
		end)
	end)

	protectedBuilding:GetPropertyChangedSignal("Value"):Connect(function()
		if protectedBuilding.Value then
			flash(pulseParts, pulseColors, Color3.fromRGB(88, 190, 255), 0.7)
		end
	end)

	defeated.Event:Connect(function(_, delaySeconds)
		task.delay(delaySeconds, function()
			local fallenPivot = restPivot
				* CFrame.new(0, -13, 8)
				* CFrame.Angles(math.rad(-72), 0, math.rad(4))
			tweenPivot(model, fallenPivot, 0.85, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		end)
	end)

	model:SetAttribute("VisualReactionsReady", true)
	model:SetAttribute("VisualReactionsUseHeartbeatLoop", false)
	return model
end

return Reactions
