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
CAS:SetTitle(action, "Attack")
CAS:SetPosition(action, UDim2.new(1,-150,1,-180))
local prompt=Instance.new("TextLabel")
prompt.Name="FinisherPrompt"
prompt.AnchorPoint=Vector2.new(0.5,1)
prompt.Position=UDim2.fromScale(0.5,0.83)
prompt.Size=UDim2.fromScale(0.38,0.06)
prompt.BackgroundColor3=Color3.fromRGB(30,32,38)
prompt.BackgroundTransparency=0.15
prompt.TextColor3=Color3.fromRGB(255,230,80)
prompt.TextScaled=true
prompt.Text="RIP APART"
prompt.Visible=false
prompt.Parent=script.Parent
local availabilityConnection
local alive=true
local function watchCharacter(character)
	if availabilityConnection then availabilityConnection:Disconnect();availabilityConnection=nil end
	prompt.Visible=false
	CAS:SetTitle(action,"Attack")
	task.spawn(function()
		local model=character:WaitForChild("Stage_1_Primal_Beast",20)
		if not alive or not model or player.Character~=character then return end
		local function update()
			local available=model:GetAttribute("FinisherAvailable")==true
			prompt.Visible=available
			CAS:SetTitle(action,available and "Rip Apart" or "Attack")
		end
		availabilityConnection=model:GetAttributeChangedSignal("FinisherAvailable"):Connect(update)
		update()
	end)
end
local characterConnection=player.CharacterAdded:Connect(watchCharacter)
if player.Character then watchCharacter(player.Character) end
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
	alive=false
	characterConnection:Disconnect()
	if availabilityConnection then availabilityConnection:Disconnect() end
	prompt:Destroy()
	mouse:Disconnect()
	CAS:UnbindAction(action)
end)
