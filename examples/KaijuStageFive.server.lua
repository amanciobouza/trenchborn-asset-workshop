-- Optional Studio practice example for the final Stage 5 package. Disable the workshop preview before enabling.
local RunService=game:GetService("RunService")
if not RunService:IsStudio() then
 warn("[Stage 5 test] Practice bootstrap runs only in Studio")
 return
end
local Players=game:GetService("Players")
local package=game:GetService("ReplicatedStorage"):WaitForChild("TrenchbornKaijuStageFive")
local Installer=require(package:WaitForChild("KaijuStageFiveInstaller"))
local Combat=require(package:WaitForChild("KaijuStageOneCombat"))
local pending=setmetatable({}, {__mode="k"})
local rangeOwners={}
local equipped={}
local connections={}
local active=true
local function equip(player,character)
 if not active or pending[character] then return end
 pending[character]=true
 local humanoid=character:WaitForChild("Humanoid",15)
 local root=character:WaitForChild("HumanoidRootPart",15)
 local deadline=os.clock()+15
 while active and player.Character==character and not player:HasAppearanceLoaded() and os.clock()<deadline do task.wait(0.1) end
 if not active or player.Character~=character or not character.Parent or not humanoid or not root then return end
 if equipped[player] then equipped[player].Destroy();equipped[player]=nil end
 local ok,err=pcall(function()
  local model,api=Installer.Install(character,{
   Scale=1, -- Change before Play: 0.5 = half size; 2 = double.
   InstallInput=true,
   EnableTraversal=true,
   CombatFactory=function(kaiju,movementRoot,human,rootHeight)
    local ground=movementRoot.CFrame*CFrame.new(0,-rootHeight,0)
    -- Generation ownership prevents delayed old-character cleanup removing
    -- the next character's practice range.
    local token={};rangeOwners[player]=token
    local function removeRange()
     if rangeOwners[player]==token then
      rangeOwners[player]=nil;Combat.RemoveRange(player)
     end
    end
    local success,adapter=pcall(function()
     Combat.BuildRange(player,ground,character,{
      Knee=ground:PointToObjectSpace(kaiju.LeftKneeJoint.Position).Y,
      Torso=ground:PointToObjectSpace(kaiju.LowerRibcage.Position).Y,
     })
     return Combat.Attach(kaiju,movementRoot,human,rootHeight)
    end)
    if not success then removeRange();error(adapter,0) end
    adapter.Destroy=function()
     adapter.Cancel();removeRange()
    end
    return adapter
   end,
  })
  equipped[player]=api
  model:SetAttribute("PracticeRangeEnabled",true)
 end)
 if not ok then pending[character]=nil;warn("[Stage 5 test] "..tostring(err)) end
end
local function connect(player)
 table.insert(connections,player.CharacterAdded:Connect(function(character) task.spawn(equip,player,character) end))
 if player.Character then task.spawn(equip,player,player.Character) end
end
local function remove(player)
 if equipped[player] then equipped[player].Destroy();equipped[player]=nil end
 rangeOwners[player]=nil;Combat.RemoveRange(player)
end
table.insert(connections,Players.PlayerAdded:Connect(connect))
table.insert(connections,Players.PlayerRemoving:Connect(remove))
for _,player in ipairs(Players:GetPlayers()) do connect(player) end
script.Destroying:Connect(function()
 active=false
 for _,connection in ipairs(connections) do connection:Disconnect() end
 for player in pairs(equipped) do remove(player) end
end)
print("[Stage 5 test] Ready: 3 houses + 2 towers. F combo, Space jump, E focus, R area; Shift run.")
