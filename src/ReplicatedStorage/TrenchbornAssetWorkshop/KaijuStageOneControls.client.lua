local Players = game:GetService("Players")
local CAS = game:GetService("ContextActionService")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer
local action = "KaijuStageOneAttack"
local lastRequest = -math.huge
local function attack()
	if UIS:GetFocusedTextBox() or os.clock()-lastRequest < 0.12 then return end
	local character = player.Character
	local model = character and character:FindFirstChild("Stage_1_Primal_Beast")
	local remote = model and model:FindFirstChild("RequestAttack")
	if remote and remote:IsA("RemoteEvent") then
		lastRequest = os.clock()
		remote:FireServer()
	end
end
CAS:BindAction(action, function(_, state)
	if UIS:GetFocusedTextBox() then return Enum.ContextActionResult.Pass end
	if state == Enum.UserInputState.Begin then attack() end
	return Enum.ContextActionResult.Sink
end, true, Enum.KeyCode.F, Enum.KeyCode.ButtonR2)
CAS:SetTitle(action, "Angriff")
CAS:SetPosition(action, UDim2.new(1,-150,1,-180))
local mouse = UIS.InputBegan:Connect(function(input, processed)
	if not processed and input.UserInputType == Enum.UserInputType.MouseButton1 then attack() end
end)
task.spawn(function()
	local button = CAS:GetButton(action)
	if button then
		for _, label in ipairs(button:GetDescendants()) do
			if label:IsA("TextLabel") then label.TextScaled = true end
		end
	end
end)
script.Destroying:Connect(function()
	mouse:Disconnect()
	CAS:UnbindAction(action)
end)
