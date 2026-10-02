-- ServerScriptService in the target project. Wait for appearance before equipping.
local Players=game:GetService("Players")
local package=game:GetService("ReplicatedStorage"):WaitForChild("TrenchbornKaijuStageThree")
local Installer=require(package:WaitForChild("KaijuStageThreeInstaller"))
local pending=setmetatable({}, {__mode="k"})
local function equip(player,character)
 if pending[character] then return end
 pending[character]=true
 local humanoid=character:WaitForChild("Humanoid",15)
 local root=character:WaitForChild("HumanoidRootPart",15)
 local deadline=os.clock()+15
 while player.Character==character and not player:HasAppearanceLoaded() and os.clock()<deadline do task.wait(0.1) end
 if player.Character~=character or not character.Parent or not humanoid or not root then return end
 local ok,err=pcall(function()
  Installer.Install(character,{
   Scale=1, -- 0.5 = half size; 2 = double. Set before equipping.
   PreviewOnly=true, -- Movement preview; no building damage or focus target.
   InstallInput=true, -- Omit if your game already supplies input.
   -- For combat, remove PreviewOnly and supply your existing building adapter:
   -- CombatFactory=function(model,root,humanoid,rootHeight)
   --  return YourBuildingCombatService.Attach(model,root,humanoid,rootHeight)
   -- end,
  })
 end)
 if not ok then pending[character]=nil;warn("[Rift Stalker] "..tostring(err)) end
end
local function connect(player)
 player.CharacterAdded:Connect(function(character) task.spawn(equip,player,character) end)
 if player.Character then task.spawn(equip,player,player.Character) end
end
Players.PlayerAdded:Connect(connect)
for _,player in ipairs(Players:GetPlayers()) do connect(player) end
