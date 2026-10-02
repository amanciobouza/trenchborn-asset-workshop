-- Optional portable input only. No camera, combat test UI or practice targets.
local Players=game:GetService("Players")
local CAS=game:GetService("ContextActionService")
local UIS=game:GetService("UserInputService")
local RunService=game:GetService("RunService")
local player=Players.LocalPlayer
local prefix="RiftStalker_"
local running,ascending=false,false
local alive=true
local function model()
 local c=player.Character
 return c and c:FindFirstChild("Stage_3_Rift_Stalker"),c and c:FindFirstChildOfClass("Humanoid")
end
local function send(name,value)
 local m=model();local remote=m and m:FindFirstChild(name)
 if remote then remote:FireServer(value) end
end
local names={}
local function bind(name,title,keys,handler,position)
 local action=prefix..name;table.insert(names,action)
 CAS:BindActionAtPriority(action,handler,true,3000,table.unpack(keys))
 CAS:SetTitle(action,title);CAS:SetPosition(action,position)
 local button=CAS:GetButton(action)
 if button then for _,label in ipairs(button:GetDescendants()) do if label:IsA("TextLabel") then label.TextScaled=true end end end
end
bind("Jump","Jump",{Enum.KeyCode.Space,Enum.KeyCode.ButtonA},function(_,state)
 if state==Enum.UserInputState.End or state==Enum.UserInputState.Cancel then ascending=false end
 if UIS:GetFocusedTextBox() then return Enum.ContextActionResult.Pass end
 if state==Enum.UserInputState.Begin then
  local m,h=model()
  if m and h then
   if h:GetState()==Enum.HumanoidStateType.Swimming then ascending=true
   else send("RequestJump",h.MoveDirection) end
  end
 end
 return Enum.ContextActionResult.Sink
end,UDim2.new(1,-65,1,-100))
bind("Run","Run",{Enum.KeyCode.LeftShift,Enum.KeyCode.RightShift,Enum.KeyCode.ButtonL3},function(_,state,input)
 local keyboard=input.KeyCode==Enum.KeyCode.LeftShift or input.KeyCode==Enum.KeyCode.RightShift
 if state==Enum.UserInputState.Cancel or (keyboard and state==Enum.UserInputState.End) then running=false;send("SetRunning",false)
 elseif UIS:GetFocusedTextBox() then return Enum.ContextActionResult.Pass
 elseif state==Enum.UserInputState.Begin then running=keyboard or not running;send("SetRunning",running) end
 CAS:SetTitle(prefix.."Run",running and "Walk" or "Run")
 return Enum.ContextActionResult.Sink
end,UDim2.new(1,-150,1,-90))
for i,definition in ipairs({{"Attack","RequestAttack",Enum.KeyCode.F,Enum.KeyCode.ButtonR2},
 {"Focus","RequestFocus",Enum.KeyCode.E,Enum.KeyCode.ButtonL2},{"Discharge","RequestArea",Enum.KeyCode.R,Enum.KeyCode.ButtonY}}) do
 bind(definition[1],definition[1],{definition[3],definition[4]},function(_,state)
  if UIS:GetFocusedTextBox() then return Enum.ContextActionResult.Pass end
  if state==Enum.UserInputState.Begin then send(definition[2]) end
  return Enum.ContextActionResult.Sink
 end,UDim2.new(1,-65-i*85,1,-180))
end
local function clear()
 running=false;ascending=false;send("SetRunning",false);CAS:SetTitle(prefix.."Run","Run")
end
local connections={UIS.WindowFocusReleased:Connect(clear),UIS.TextBoxFocused:Connect(clear),
 UIS.GamepadDisconnected:Connect(clear),player.CharacterAdded:Connect(clear)}
table.insert(connections,UIS.InputBegan:Connect(function(input,processed)
 if not processed and not UIS:GetFocusedTextBox() and input.UserInputType==Enum.UserInputType.MouseButton1 then send("RequestAttack") end
end))
local lastSteer=0
local stepName=prefix.."Swim_"..player.UserId
RunService:BindToRenderStep(stepName,Enum.RenderPriority.Input.Value+1,function()
 local m,h=model()
 if not m or not h then ascending=false;return end
 if UIS:GetFocusedTextBox() then ascending=false;return end
 if h:GetState()==Enum.HumanoidStateType.Swimming then
  if ascending then local d=h.MoveDirection;h:Move(Vector3.new(d.X,0.75,d.Z),false) end
 else ascending=false end
 local phase=m:GetAttribute("JumpPhase")
 if (phase=="Air" or phase=="Windup") and os.clock()-lastSteer>=0.08 then
  lastSteer=os.clock();send("SteerJump",h.MoveDirection)
 end
end)
local function stop()
 if not alive then return end;alive=false
 clear();for _,c in ipairs(connections) do c:Disconnect() end
 RunService:UnbindFromRenderStep(stepName)
 for _,name in ipairs(names) do CAS:UnbindAction(name) end
end
script.Destroying:Connect(stop)
