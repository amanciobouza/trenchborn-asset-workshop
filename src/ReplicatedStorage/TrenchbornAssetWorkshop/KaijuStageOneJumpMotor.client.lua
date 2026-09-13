-- Always-installed owner runtime: server-authorized jumps and landing rebound removal.
-- Joint transforms belong exclusively to KaijuPresentationClient.
-- No input bindings, camera or horizontal steering; required with InstallInput=false.
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local player=Players.LocalPlayer
local connection,contactConnection
local alive=true
local generation=0
local function watch(character)
 generation=generation+1;local ticket=generation
 if connection then connection:Disconnect();connection=nil end
 if contactConnection then contactConnection:Disconnect();contactConnection=nil end
 task.spawn(function()
  local deadline=os.clock()+30
  local model,remote
  repeat
   if not alive or ticket~=generation or player.Character~=character then return end
   model=nil
   for _,candidate in ipairs(character:GetChildren()) do
    if candidate:IsA("Model") and candidate:GetAttribute("EvolutionStage") and candidate:FindFirstChild("KaijuJumpImpulse") then
     model=candidate;break
    end
   end
   remote=model and model:FindFirstChild("KaijuJumpImpulse")
   if not remote then task.wait(0.03) end
  until remote or os.clock()>deadline
  if not remote or not alive or ticket~=generation then return end
  local flight=false
  local tookOffAt,settleUntil=0,0
  contactConnection=game:GetService("RunService").Heartbeat:Connect(function()
   if not alive or player.Character~=character or not model.Parent then return end
   local h=character:FindFirstChildOfClass("Humanoid")
   local root=character:FindFirstChild("HumanoidRootPart")
   if not h or h.Health<=0 or not root or root.Anchored then return end
   if h:GetState()==Enum.HumanoidStateType.Swimming then flight=false;settleUntil=0;return end
   local now=os.clock()
   if flight and now-tookOffAt>0.1 and h.FloorMaterial~=Enum.Material.Air then
    flight=false;settleUntil=now+0.16
   end
   -- Remove only upward contact rebound. X/Z, falling, and a fresh authorized jump stay free.
   if now<settleUntil then
    local v=root.AssemblyLinearVelocity
    if v.Y>0 then root.AssemblyLinearVelocity=Vector3.new(v.X,0,v.Z) end
   end
  end)
  connection=remote.OnClientEvent:Connect(function(rise)
   if not alive or player.Character~=character or not model.Parent then return end
   local h=character:FindFirstChildOfClass("Humanoid")
   local root=character:FindFirstChild("HumanoidRootPart")
   if not h or h.Health<=0 or not root or root.Anchored or h:GetState()==Enum.HumanoidStateType.Swimming then return end
   if type(rise)~="number" or rise~=rise or rise<=0 or rise>500 then return end
   flight=true;tookOffAt=os.clock();settleUntil=0
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
 if contactConnection then contactConnection:Disconnect() end
end)
