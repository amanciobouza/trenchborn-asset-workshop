-- Server-authorized vertical impulse only. No input bindings, camera or horizontal steering.
local Players=game:GetService("Players")
local player=Players.LocalPlayer
local connection
local alive=true
local generation=0
local function watch(character)
 generation=generation+1;local ticket=generation
 if connection then connection:Disconnect();connection=nil end
 task.spawn(function()
  local deadline=os.clock()+30
  local model,remote
  repeat
   if not alive or ticket~=generation or player.Character~=character then return end
   model=character:FindFirstChild("Stage_1_Primal_Beast") or character:FindFirstChild("Stage_2_Storm_Hunter")
   remote=model and model:FindFirstChild("KaijuJumpImpulse")
   if not remote then task.wait(0.03) end
  until remote or os.clock()>deadline
  if not remote or not alive or ticket~=generation then return end
  connection=remote.OnClientEvent:Connect(function(rise)
   if not alive or player.Character~=character or not model.Parent then return end
   local h=character:FindFirstChildOfClass("Humanoid")
   local root=character:FindFirstChild("HumanoidRootPart")
   if not h or h.Health<=0 or not root or root.Anchored or h:GetState()==Enum.HumanoidStateType.Swimming then return end
   if type(rise)~="number" or rise~=rise or rise<=0 or rise>500 then return end
   local velocity=root.AssemblyLinearVelocity
   h:ChangeState(Enum.HumanoidStateType.Freefall)
   root.AssemblyLinearVelocity=Vector3.new(velocity.X,rise,velocity.Z)
  end)
 end)
end
local added=player.CharacterAdded:Connect(watch)
if player.Character then watch(player.Character) end
script.Destroying:Connect(function()
 alive=false;generation=generation+1;added:Disconnect()
 if connection then connection:Disconnect() end
end)
