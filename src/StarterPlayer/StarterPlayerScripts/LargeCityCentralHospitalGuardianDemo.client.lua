local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local packageFolder = ReplicatedStorage:WaitForChild("TrenchbornAssetWorkshop")
local runtime = packageFolder:WaitForChild("CentralHospitalGuardianDemo", 30)
if not runtime then
	warn("[Guardian Demo] Runtime folder missing")
	return
end

local inputEvent = runtime:WaitForChild("Input")
local attackEvent = runtime:WaitForChild("Attack")
local resetEvent = runtime:WaitForChild("Reset")

local workshop = Workspace:WaitForChild("TrenchbornAssetWorkshop")
local guardian = workshop:WaitForChild("PlayerGuardian_WardenI", 30)
if not guardian then
	warn("[Guardian Demo] Player Guardian missing")
	return
end

local camera = Workspace.CurrentCamera
camera.CameraType = Enum.CameraType.Scriptable
camera.FieldOfView = 72

local gui = Instance.new("ScreenGui")
gui.Name = "CentralHospitalGuardianDemoHUD"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.Parent = player:WaitForChild("PlayerGui")

local panel = Instance.new("Frame")
panel.Name = "ControlPanel"
panel.AnchorPoint = Vector2.new(0, 1)
panel.Position = UDim2.new(0, 18, 1, -18)
panel.Size = UDim2.fromOffset(430, 150)
panel.BackgroundColor3 = Color3.fromRGB(16, 23, 25)
panel.BackgroundTransparency = 0.12
panel.BorderSizePixel = 0
panel.Parent = gui

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 10)
panelCorner.Parent = panel

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Position = UDim2.fromOffset(14, 10)
title.Size = UDim2.new(1, -28, 0, 34)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.Text = "WARDEN-I  •  HOSPITAL DEMOLITION"
title.TextColor3 = Color3.fromRGB(164, 238, 198)
title.TextScaled = true
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = panel

local status = Instance.new("TextLabel")
status.Name = "Status"
status.Position = UDim2.fromOffset(14, 48)
status.Size = UDim2.new(1, -28, 0, 42)
status.BackgroundTransparency = 1
status.Font = Enum.Font.GothamBold
status.Text = "SPITAL 64000 / 64000 HP"
status.TextColor3 = Color3.fromRGB(240, 240, 232)
status.TextScaled = true
status.TextXAlignment = Enum.TextXAlignment.Left
status.TextYAlignment = Enum.TextYAlignment.Center
status.Parent = panel

local controls = Instance.new("TextLabel")
controls.Name = "Controls"
controls.Position = UDim2.fromOffset(14, 96)
controls.Size = UDim2.new(1, -28, 0, 42)
controls.BackgroundTransparency = 1
controls.Font = Enum.Font.GothamMedium
controls.Text = "W/S laufen  •  A/D drehen  •  Q/E seitwärts  •  Shift sprinten\nLINKSKLICK/F Schlag  •  SPACE Slam  •  R Reset"
controls.TextColor3 = Color3.fromRGB(205, 213, 211)
controls.TextScaled = true
controls.TextWrapped = true
controls.TextXAlignment = Enum.TextXAlignment.Left
controls.Parent = panel

local crosshair = Instance.new("TextLabel")
crosshair.Name = "Crosshair"
crosshair.AnchorPoint = Vector2.new(0.5, 0.5)
crosshair.Position = UDim2.fromScale(0.5, 0.5)
crosshair.Size = UDim2.fromOffset(28, 28)
crosshair.BackgroundTransparency = 1
crosshair.Font = Enum.Font.GothamBold
crosshair.Text = "+"
crosshair.TextColor3 = Color3.fromRGB(164, 238, 198)
crosshair.TextScaled = true
crosshair.Parent = gui

local held = {
	W = false,
	S = false,
	A = false,
	D = false,
	Q = false,
	E = false,
	Shift = false,
}

local function setKey(keyCode, value)
	if keyCode == Enum.KeyCode.W then held.W = value end
	if keyCode == Enum.KeyCode.S then held.S = value end
	if keyCode == Enum.KeyCode.A then held.A = value end
	if keyCode == Enum.KeyCode.D then held.D = value end
	if keyCode == Enum.KeyCode.Q then held.Q = value end
	if keyCode == Enum.KeyCode.E then held.E = value end
	if keyCode == Enum.KeyCode.LeftShift or keyCode == Enum.KeyCode.RightShift then held.Shift = value end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	setKey(input.KeyCode, true)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.KeyCode == Enum.KeyCode.F then
		attackEvent:FireServer("Baton")
	elseif input.KeyCode == Enum.KeyCode.Space then
		attackEvent:FireServer("Slam")
	elseif input.KeyCode == Enum.KeyCode.R then
		resetEvent:FireServer()
	end
end)

UserInputService.InputEnded:Connect(function(input)
	setKey(input.KeyCode, false)
end)

local sendAccumulator = 0
local cameraCFrame = nil

RunService.RenderStepped:Connect(function(dt)
	if not guardian.Parent then
		return
	end

	local pivot = guardian:GetPivot()
	local cameraPosition = (pivot * CFrame.new(0, 12, 44)).Position
	local targetPosition = (pivot * CFrame.new(0, 5, -8)).Position
	local desired = CFrame.new(cameraPosition, targetPosition)
	if cameraCFrame then
		cameraCFrame = cameraCFrame:Lerp(desired, math.clamp(dt * 7, 0, 1))
	else
		cameraCFrame = desired
	end
	camera.CFrame = cameraCFrame

	sendAccumulator += dt
	if sendAccumulator >= 0.05 then
		sendAccumulator = 0
		inputEvent:FireServer({
			Forward = (held.W and 1 or 0) + (held.S and -1 or 0),
			Strafe = (held.E and 1 or 0) + (held.Q and -1 or 0),
			Turn = (held.D and 1 or 0) + (held.A and -1 or 0),
			Sprint = held.Shift,
		})
	end

	local health = runtime:GetAttribute("HospitalHealth") or 0
	local maxHealth = runtime:GetAttribute("HospitalMaxHealth") or 0
	local message = runtime:GetAttribute("LastMessage") or ""
	status.Text = string.format("SPITAL %d / %d HP   •   %s", health, maxHealth, message)
end)
