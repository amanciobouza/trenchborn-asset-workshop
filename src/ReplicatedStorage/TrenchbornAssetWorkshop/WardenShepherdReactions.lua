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
	local batonRestPivot = baton and baton:GetPivot()
	local visor = model:FindFirstChild("VisorSensor", true)
	local pulseCore = model:FindFirstChild("ChestPulseCore", true)
	local pulseParts = collectVisibleParts(pulseCore)
	if visor then
		table.insert(pulseParts, visor)
	end
	local pulseColors = captureColors(pulseParts)

	healthChanged.Event:Connect(function(_, _, source)
		if source == "Reset" then
			model:PivotTo(restPivot)
			if baton and batonRestPivot then
				baton:PivotTo(batonRestPivot)
			end
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
		if not baton or not batonRestPivot then
			return
		end
		local windup = batonRestPivot * CFrame.Angles(0, 0, math.rad(-32))
		local swing = batonRestPivot * CFrame.Angles(0, 0, math.rad(38))
		local windupTween = tweenPivot(baton, windup, 0.12, Enum.EasingStyle.Quad)
		windupTween.Completed:Connect(function()
			local swingTween = tweenPivot(baton, swing, 0.16, Enum.EasingStyle.Quart)
			swingTween.Completed:Connect(function()
				tweenPivot(baton, batonRestPivot, 0.18, Enum.EasingStyle.Quad)
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
