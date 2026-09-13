-- Phase 7: approved Stage 1 asset. Call from the server, after avatar appearance loads.
local RunService=game:GetService("RunService")
local Players=game:GetService("Players")
local Builder=require(script.Parent:WaitForChild("KaijuEvolutionBlockout"))
local Rig=require(script.Parent:WaitForChild("KaijuStageOneRig"))
local Installer={Version="1.0.0",ApprovedRevision="e2e669b53806f19f62b76d68c8b4ac6065f71015"}
local installations=setmetatable({}, {__mode="k"})
local NAME="Stage_1_Primal_Beast"
local function stamp(model)
 model:SetAttribute("PipelinePhase",7)
 model:SetAttribute("QualityGateB","ApprovedByUser")
 model:SetAttribute("QualityGateC","ApprovedByUser")
 model:SetAttribute("FinalInstallerVersion",Installer.Version)
 model:SetAttribute("ApprovedRevision",Installer.ApprovedRevision)
 model:SetAttribute("WorkshopOnly",false)
end
local function build(parent,ground)
 -- Isolate the legacy builder, which replaces collections inside its target.
 local staging=Instance.new("Folder")
 staging.Name="KaijuStageOneBuild";staging.Parent=parent
 local model
 local ok,err=pcall(function()
  local collection=Builder.BuildStage(staging,1,CFrame.identity)
  model=assert(collection:FindFirstChild(NAME),"Missing Stage 1 geometry")
  local bottom=math.huge
  for _,side in ipairs({"Left","Right"}) do
   local sole=assert(model:FindFirstChild(side.."ForefootCoreY"),"Missing sole")
   bottom=math.min(bottom,sole.CFrame:PointToWorldSpace(Vector3.new(0,-sole.Size.Y/2,0)).Y)
  end
  local pivot=model:GetPivot()+Vector3.new(0,-bottom,0)
  model:PivotTo(ground*pivot)
  model.Parent=parent
 end)
 staging:Destroy()
 if not ok then if model then model:Destroy() end;error(err,0) end
 return model
end
function Installer.Install(character,options)
 assert(RunService:IsServer(),"Install must run on the server")
 options=options or {}
 assert(typeof(character)=="Instance" and character:IsA("Model") and character:IsDescendantOf(workspace),"Expected live character Model")
 assert(not installations[character] and not character:FindFirstChild(NAME),"Stage 1 already installed; uninstall first")
 local humanoid=assert(character:FindFirstChildOfClass("Humanoid"),"Missing Humanoid")
 local root=assert(character:FindFirstChild("HumanoidRootPart"),"Missing HumanoidRootPart")
 assert(humanoid.Health>0,"Cannot equip a defeated character")
 assert(type(options.CombatFactory)=="function","CombatFactory is required: connect the game's building damage service")
 local player=Players:GetPlayerFromCharacter(character)
 local height=humanoid.HipHeight+root.Size.Y/2
 if humanoid.RigType==Enum.HumanoidRigType.R6 then
  local leg=character:FindFirstChild("Left Leg");if leg then height=height+leg.Size.Y end
 end
 local ground=root.CFrame*CFrame.new(0,-height,0)
 local model,rig,combat,collider
 local connections,saved={},{}
 local settings={}
 for _,key in ipairs({"WalkSpeed","AutoRotate","UseJumpPower","JumpPower","AutoJumpEnabled","BreakJointsOnDeath"}) do settings[key]=humanoid[key] end
 local anchored=root.Anchored
 local api={}
 local removed=false
 local function remember(item,key,value)
  saved[item]=saved[item] or {};if saved[item][key]==nil then saved[item][key]=item[key] end
  item[key]=value
 end
 local function hide(item)
  if model and item:IsDescendantOf(model) or item==collider then return end
  if item:IsA("BasePart") then remember(item,"Transparency",1);remember(item,"CastShadow",false)
  elseif item:IsA("Decal") then remember(item,"Transparency",1)
  elseif item:IsA("ParticleEmitter") or item:IsA("Trail") then remember(item,"Enabled",false)
  elseif (item:IsA("Script") or item:IsA("LocalScript")) and item.Name=="Animate" then remember(item,"Enabled",false) end
 end
 function api.Destroy()
  if removed then return end;removed=true
  for _,c in ipairs(connections) do c:Disconnect() end
  if rig then rig.Stop() end
  if combat and combat.Destroy then combat.Destroy() end
  if collider then collider:Destroy() end
  if model then model:Destroy() end
  for item,properties in pairs(saved) do
   if item.Parent then for key,value in pairs(properties) do item[key]=value end end
  end
  if humanoid.Parent then for key,value in pairs(settings) do humanoid[key]=value end end
  if root.Parent then root.Anchored=anchored end
  installations[character]=nil
 end
 local ok,err=pcall(function()
  model=build(character,ground)
  combat=options.CombatFactory(model,root,humanoid,height)
  assert(type(combat)=="table","CombatFactory must return an adapter")
  for _,name in ipairs({"Handle","Cancel","PrepareFinisher","FocusAim","SelectFocusTarget","AreaImpact"}) do
   assert(type(combat[name])=="function","Missing combat method: "..name)
  end
  for _,item in ipairs(character:GetDescendants()) do hide(item) end
  table.insert(connections,character.DescendantAdded:Connect(hide))
  collider=Instance.new("Part");collider.Name="KaijuBodyCollider"
  collider.Size=Vector3.new(11,20,7)*model:GetScale()
  collider.CFrame=ground*CFrame.new(0,collider.Size.Y/2+3,0)
  collider.Transparency=1;collider.Massless=true;collider.CanCollide=true;collider.CanTouch=false
  collider.Parent=character
  local weld=Instance.new("WeldConstraint");weld.Part0=root;weld.Part1=collider;weld.Parent=collider
  humanoid.WalkSpeed=10;humanoid.AutoRotate=true
  humanoid.UseJumpPower=true;humanoid.JumpPower=0;humanoid.AutoJumpEnabled=false
  rig=Rig.Attach(model,root,humanoid,combat)
  for _,name in ipairs({"RequestAttack","RequestJump","SetAirDirection","RequestFocus","RequestArea","SetRunning"}) do
   api[name]=function(...) if removed then return false end;return rig[name](...) end
  end
  if player and options.EnableRemotes~=false then
   local function direction(value)
    return typeof(value)=="Vector3" and value.X==value.X and value.Y==value.Y and value.Z==value.Z
     and value.Magnitude<=1.05 and math.abs(value.Y)<=0.1
   end
   local definitions={
    RequestAttack={"RequestAttack",0.12},RequestJump={"RequestJump",0.15,"jump"},
    SteerJump={"SetAirDirection",0.06,"direction"},SetRunning={"SetRunning",0,"boolean"},
    RequestFocus={"RequestFocus",0.2},RequestArea={"RequestArea",0.2},
   }
   for name,definition in pairs(definitions) do
    local remote=Instance.new("RemoteEvent");remote.Name=name;remote.Parent=model
    local last=-math.huge
    table.insert(connections,remote.OnServerEvent:Connect(function(sender,value)
     if removed or sender~=player or player.Character~=character or humanoid.Health<=0 then return end
     local validation=definition[3]
     if validation=="boolean" and type(value)~="boolean" then return end
     if validation=="direction" and not direction(value) then return end
     if validation=="jump" and value~=nil and not direction(value) then return end
     local now=os.clock();if now-last<definition[2] then return end;last=now
     api[definition[1]](value)
    end))
   end
  end
  stamp(model)
  if player then model:SetAttribute("ControlledBy",player.UserId) end
  table.insert(connections,character.Destroying:Connect(api.Destroy))
  table.insert(connections,model.Destroying:Connect(api.Destroy))
  api.Model=model
  installations[character]=api
 end)
 if not ok then api.Destroy();error(err,0) end
 return model,api
end
function Installer.Uninstall(character)
 local api=installations[character];if not api then return false end
 api.Destroy();return true
end
return Installer
