local ReviewControls = {}

function ReviewControls.Attach(workshop, gameplayApi, position, damageStep)
	local old = workshop:FindFirstChild("LargeCityResortReviewControls")
	if old then old:Destroy() end

	local pedestal = Instance.new("Part")
	pedestal.Name = "LargeCityResortReviewControls"
	pedestal.Size = Vector3.new(5.5, 0.8, 5.5)
	pedestal.Position = position
	pedestal.Anchored = true
	pedestal.CanCollide = true
	pedestal.Material = Enum.Material.Metal
	pedestal.Color = Color3.fromRGB(74, 82, 87)
	pedestal.TopSurface = Enum.SurfaceType.Smooth
	pedestal.BottomSurface = Enum.SurfaceType.Smooth
	pedestal.Parent = workshop

	local damagePrompt = Instance.new("ProximityPrompt")
	damagePrompt.Name = "DamagePrompt"
	damagePrompt.ActionText = string.format("%d Damage", damageStep)
	damagePrompt.ObjectText = "Resort Destruction Review"
	damagePrompt.KeyboardKeyCode = Enum.KeyCode.E
	damagePrompt.MaxActivationDistance = 12
	damagePrompt.HoldDuration = 0
	damagePrompt.RequiresLineOfSight = false
	damagePrompt.Parent = pedestal

	local resetPrompt = Instance.new("ProximityPrompt")
	resetPrompt.Name = "ResetPrompt"
	resetPrompt.ActionText = "Reset Resort"
	resetPrompt.ObjectText = "Resort Destruction Review"
	resetPrompt.KeyboardKeyCode = Enum.KeyCode.R
	resetPrompt.MaxActivationDistance = 12
	resetPrompt.HoldDuration = 0
	resetPrompt.RequiresLineOfSight = false
	resetPrompt.Parent = pedestal

	local applyDamage = gameplayApi:WaitForChild("ApplyDamage")
	local reset = gameplayApi:WaitForChild("Reset")

	damagePrompt.Triggered:Connect(function()
		applyDamage:Invoke(damageStep)
	end)
	resetPrompt.Triggered:Connect(function()
		reset:Invoke()
	end)

	workshop:SetAttribute("Phase6ReviewDamageKey", "E")
	workshop:SetAttribute("Phase6ReviewResetKey", "R")
	workshop:SetAttribute("Phase6ReviewDamageStep", damageStep)
	return pedestal
end

return ReviewControls
