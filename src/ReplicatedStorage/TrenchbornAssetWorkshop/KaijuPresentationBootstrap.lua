-- One presentation observer per player, including spectators and future joins.
-- Deliberately independent of owner controls and InstallInput/EnableRemotes.
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local Bootstrap={}
local started=false
local NAME="TrenchbornKaijuPresentation"
local function install(player)
 task.spawn(function()
  local gui=player:WaitForChild("PlayerGui",30)
  local template=script.Parent:WaitForChild("KaijuPresentationClient")
  if not gui or not player.Parent or gui:FindFirstChild(NAME) then return end
  local container=Instance.new("ScreenGui")
  container.Name=NAME;container.ResetOnSpawn=false
  local client=template:Clone()
  client.Enabled=true;client.Parent=container
  container.Parent=gui
 end)
end
function Bootstrap.Ensure()
 assert(RunService:IsServer(),"Presentation bootstrap is server-only")
 if started then return end
 started=true
 Players.PlayerAdded:Connect(install)
 for _,player in ipairs(Players:GetPlayers()) do install(player) end
end
return Bootstrap
