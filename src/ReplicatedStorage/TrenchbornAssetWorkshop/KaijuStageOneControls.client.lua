local Players = game:GetService("Players")
local CAS = game:GetService("ContextActionService")
local UIS = game:GetService("UserInputService")
local RunService=game:GetService("RunService")
local player = Players.LocalPlayer
local action = "KaijuStageOneAttack"
local jumpAction="KaijuStageOneJump"
local focusAction="KaijuStageOneFocus"
local areaAction="KaijuStageOneArea"
local runAction="KaijuStageOneRun"
local runHeld=false
local function setRun(enabled)
	runHeld=enabled
	CAS:SetTitle(runAction,enabled and "Walk" or "Run")
	local character=player.Character
	local model=character and character:FindFirstChild("Stage_1_Primal_Beast")
	local remote=model and model:FindFirstChild("SetRunning")
	if remote then remote:FireServer(enabled) end
end
CAS:BindActionAtPriority(runAction,function(_,state,input)
	local keyboard=input.KeyCode==Enum.KeyCode.LeftShift or input.KeyCode==Enum.KeyCode.RightShift
	if state==Enum.UserInputState.Cancel or (keyboard and state==Enum.UserInputState.End) then
		setRun(false);return Enum.ContextActionResult.Sink
	end
	if UIS:GetFocusedTextBox() then return Enum.ContextActionResult.Pass end
	if state==Enum.UserInputState.Begin then setRun(keyboard or not runHeld) end
	return Enum.ContextActionResult.Sink
end,true,3000,Enum.KeyCode.LeftShift,Enum.KeyCode.RightShift,Enum.KeyCode.ButtonL3)
CAS:SetTitle(runAction,"Run")
CAS:SetPosition(runAction,UDim2.new(1,-150,1,-90))
local runFocusLost=UIS.WindowFocusReleased:Connect(function() setRun(false) end)
local runTextFocus=UIS.TextBoxFocused:Connect(function() setRun(false) end)
local runGamepadLost=UIS.GamepadDisconnected:Connect(function() setRun(false) end)
local lastArea=-math.huge
CAS:BindAction(areaAction,function(_,state)
	if UIS:GetFocusedTextBox() then return Enum.ContextActionResult.Pass end
	if state==Enum.UserInputState.Begin and os.clock()-lastArea>=0.2 then
		local character=player.Character
		local model=character and character:FindFirstChild("Stage_1_Primal_Beast")
		local remote=model and model:FindFirstChild("RequestArea")
		if remote then lastArea=os.clock();remote:FireServer() end
	end
	return Enum.ContextActionResult.Sink
end,true,Enum.KeyCode.R,Enum.KeyCode.ButtonY)
CAS:SetTitle(areaAction,"Discharge")
CAS:SetPosition(areaAction,UDim2.new(1,-240,1,-90))
local lastFocus=-math.huge
CAS:BindAction(focusAction,function(_,state)
	if UIS:GetFocusedTextBox() then return Enum.ContextActionResult.Pass end
	if state==Enum.UserInputState.Begin and os.clock()-lastFocus>=0.2 then
		local character=player.Character
		local model=character and character:FindFirstChild("Stage_1_Primal_Beast")
		local remote=model and model:FindFirstChild("RequestFocus")
		if remote then lastFocus=os.clock();remote:FireServer() end
	end
	return Enum.ContextActionResult.Sink
end,true,Enum.KeyCode.E,Enum.KeyCode.ButtonL2)
CAS:SetTitle(focusAction,"Focus")
CAS:SetPosition(focusAction,UDim2.new(1,-240,1,-180))
local lastJump=-math.huge
CAS:BindActionAtPriority(jumpAction,function(_,state)
	if UIS:GetFocusedTextBox() then return Enum.ContextActionResult.Pass end
	if state==Enum.UserInputState.Begin and os.clock()-lastJump>=0.15 then
		local character=player.Character
		local model=character and character:FindFirstChild("Stage_1_Primal_Beast")
		local remote=model and model:FindFirstChild("RequestJump")
		local humanoid=character and character:FindFirstChildOfClass("Humanoid")
		if remote and humanoid then lastJump=os.clock();remote:FireServer(humanoid.MoveDirection) end
	end
	return Enum.ContextActionResult.Sink
end,true,3000,Enum.KeyCode.Space,Enum.KeyCode.ButtonA)
CAS:SetTitle(jumpAction,"Jump")
CAS:SetPosition(jumpAction,UDim2.new(1,-65,1,-100))
local lastSteer=0
local steering=RunService.Heartbeat:Connect(function()
	if os.clock()-lastSteer<0.08 then return end
	lastSteer=os.clock()
	local character=player.Character
	local model=character and character:FindFirstChild("Stage_1_Primal_Beast")
	local phase=model and model:GetAttribute("JumpPhase")
	if phase~="Air" and phase~="Windup" then return end
	local humanoid=character:FindFirstChildOfClass("Humanoid")
	local remote=model:FindFirstChild("SteerJump")
	if remote and humanoid then
		remote:FireServer(UIS:GetFocusedTextBox() and Vector3.zero or humanoid.MoveDirection)
	end
end)
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
local reactionPanel
if RunService:IsStudio() then
	reactionPanel=Instance.new("Frame");reactionPanel.Name="ReactionTests"
	reactionPanel.Position=UDim2.new(0,12,0,120);reactionPanel.Size=UDim2.fromOffset(200,112)
	reactionPanel.BackgroundTransparency=0.25;reactionPanel.BackgroundColor3=Color3.fromRGB(25,30,40);reactionPanel.Parent=script.Parent
	local title=Instance.new("TextLabel");title.Size=UDim2.new(1,0,0,28);title.BackgroundTransparency=1
	title.Text="Reaction test";title.TextScaled=true;title.TextColor3=Color3.new(1,1,1);title.Parent=reactionPanel
	for i,command in ipairs({"Hit","Heavy Hit","Defeat","Heal"}) do
		local button=Instance.new("TextButton");button.Size=UDim2.fromOffset(92,34)
		button.Position=UDim2.fromOffset(6+((i-1)%2)*96,32+math.floor((i-1)/2)*38)
		button.Text=command;button.TextScaled=true;button.BackgroundColor3=Color3.fromRGB(55,65,80)
		button.TextColor3=Color3.new(1,1,1);button.Parent=reactionPanel
		button.Activated:Connect(function()
			local character=player.Character
			local model=character and character:FindFirstChild("Stage_1_Primal_Beast")
			local remote=model and model:FindFirstChild("TestReaction")
			if remote then remote:FireServer(command) end
		end)
	end
end
local availabilityConnection
local focusConnection
local areaConnection
local alive=true
local function watchCharacter(character)
	setRun(false)
	if availabilityConnection then availabilityConnection:Disconnect();availabilityConnection=nil end
	if focusConnection then focusConnection:Disconnect();focusConnection=nil end
	if areaConnection then areaConnection:Disconnect();areaConnection=nil end
	CAS:SetTitle(areaAction,"Discharge")
	CAS:SetTitle(focusAction,"Focus")
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
		areaConnection=model:GetAttributeChangedSignal("AreaPhase"):Connect(function()
			local phase=model:GetAttribute("AreaPhase")
			CAS:SetTitle(areaAction,phase=="Charging" and "Charging" or phase=="Recovery" and "Recovery" or "Discharge")
		end)
		focusConnection=model:GetAttributeChangedSignal("FocusPhase"):Connect(function()
			local phase=model:GetAttribute("FocusPhase")
			CAS:SetTitle(focusAction,phase=="Charging" and "Charging" or phase=="Firing" and "Firing"
				or phase=="Recovery" and "Recovery" or phase=="No target" and "No target" or "Focus")
		end)
		update()
	end)
end
local characterConnection=player.CharacterAdded:Connect(watchCharacter)
if player.Character then watchCharacter(player.Character) end
local mouse = UIS.InputBegan:Connect(function(input, processed)
	if not processed and input.UserInputType == Enum.UserInputType.MouseButton1 then attack() end
end)
task.spawn(function()
	for _,name in ipairs({action,jumpAction,focusAction,areaAction,runAction}) do
		local button = CAS:GetButton(name)
		if button then
			for _, label in ipairs(button:GetDescendants()) do
				if label:IsA("TextLabel") then label.TextScaled = true end
			end
		end
	end
end)
script.Destroying:Connect(function()
	setRun(false)
	runFocusLost:Disconnect();runTextFocus:Disconnect();runGamepadLost:Disconnect()
	CAS:UnbindAction(runAction)
	steering:Disconnect()
	alive=false
	characterConnection:Disconnect()
	if availabilityConnection then availabilityConnection:Disconnect() end
	if focusConnection then focusConnection:Disconnect() end
	if areaConnection then areaConnection:Disconnect() end
	if reactionPanel then reactionPanel:Destroy() end
	prompt:Destroy()
	mouse:Disconnect()
	CAS:UnbindAction(action)
	CAS:UnbindAction(jumpAction)
	CAS:UnbindAction(focusAction)
	CAS:UnbindAction(areaAction)
end)
