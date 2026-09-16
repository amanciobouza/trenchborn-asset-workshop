local SignDressing = {}

local SIGN_TEXT = "TRENCHBORN BAY\nRESORT"

local function findSign(model)
	local dressing = model:FindFirstChild("Dressing")
	if not dressing then return nil end
	local entrance = dressing:FindFirstChild("Entrance")
	if not entrance then return nil end
	return entrance:FindFirstChild("ResortNameSign")
end

function SignDressing.Apply(model)
	assert(model and model:IsA("Model"), "LargeCityWaterfrontResortSignDressing.Apply expects a Model")

	local sign = findSign(model)
	assert(sign and sign:IsA("BasePart"), "ResortNameSign not found after dressing")

	-- The original one-line sign forced TextScaled to fit a very wide phrase into
	-- a shallow panel, which made the lettering look compressed. Keep TextScaled
	-- (Trenchborn UI standard), but give the sign a better aspect ratio and use a
	-- deliberate two-line lockup with an explicit text-size range.
	sign.Size = Vector3.new(22, 3.4, 0.45)

	local oldGui = sign:FindFirstChild("SignSurface")
	if oldGui then oldGui:Destroy() end

	local gui = Instance.new("SurfaceGui")
	gui.Name = "SignSurface"
	gui.Face = Enum.NormalId.Front
	gui.AlwaysOnTop = false
	gui.LightInfluence = 0.25
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 50
	gui.Adornee = sign
	gui.Parent = sign

	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = SIGN_TEXT
	label.TextColor3 = Color3.fromRGB(244, 239, 224)
	label.TextStrokeTransparency = 0.82
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.TextWrapped = true
	label.TextXAlignment = Enum.TextXAlignment.Center
	label.TextYAlignment = Enum.TextYAlignment.Center
	label.LineHeight = 0.9
	label.Parent = gui

	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0.055, 0)
	padding.PaddingRight = UDim.new(0.055, 0)
	padding.PaddingTop = UDim.new(0.08, 0)
	padding.PaddingBottom = UDim.new(0.08, 0)
	padding.Parent = label

	local textSize = Instance.new("UITextSizeConstraint")
	textSize.MinTextSize = 18
	textSize.MaxTextSize = 46
	textSize.Parent = label

	model:SetAttribute("ResortSignRevision", "TwoLineAspectSafe-v2")
	model:SetAttribute("TextLabelsScaled", true)
	return sign
end

return SignDressing
