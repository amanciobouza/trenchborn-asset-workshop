-- A single observer renders all streamed Kaijus, regardless of who controls them.
local CollectionService=game:GetService("CollectionService")
local RunService=game:GetService("RunService")
local HttpService=game:GetService("HttpService")
local Players=game:GetService("Players")
local player=Players.LocalPlayer
local TAG="TrenchbornKaijuPresentation"
local active,pending={},{}
local alive=true
local function remove(model)
 pending[model]=nil
 local entry=active[model];active[model]=nil
 if entry then entry.Connection:Disconnect();entry.View.Stop() end
end
local function track(model)
 if active[model] or pending[model] then return end
 local ticket={};pending[model]=ticket
 task.spawn(function()
  local warnAt=os.clock()+30
  local missing="model references"
  repeat
   if not alive or pending[model]~=ticket or not CollectionService:HasTag(model,TAG) then return end
   local renderer=model:FindFirstChild("KaijuRenderer")
   local skeleton=model:FindFirstChild("Articulation")
   local root=model:FindFirstChild("KaijuMovementRoot")
   local human=model:FindFirstChild("KaijuHumanoid")
   if model:IsDescendantOf(workspace) and renderer and renderer.Value and skeleton and root and human
    and (not model:GetAttribute("KaijuHasMovementRoot") or root.Value)
    and (not model:GetAttribute("KaijuHasHumanoid") or human.Value)
    and model:GetAttribute("KaijuPresentationState") then
    local implementation=require(renderer.Value)
    local ready
    ready,missing=implementation.IsReady(model,root.Value)
    if ready then
    local ok,view=pcall(function() return implementation.Attach(model,root.Value,human.Value) end)
    if not ok then
     warn("[Kaiju presentation] "..model.Name..": "..tostring(view))
     pending[model]=nil;return
    end
    if pending[model]~=ticket then view.Stop();return end
    local function sync()
     local raw=model:GetAttribute("KaijuPresentationState");if not raw then return end
     local decoded,state=pcall(HttpService.JSONDecode,HttpService,raw)
     if decoded and type(state)=="table" then view.Apply(state) end
    end
    local connection=model:GetAttributeChangedSignal("KaijuPresentationState"):Connect(sync)
    active[model]={View=view,Connection=connection,Root=root.Value};pending[model]=nil
    sync();return
    end
   end
   if os.clock()>=warnAt then
    warn("[Kaiju presentation] Waiting for "..model.Name..": "..tostring(missing))
    warnAt=os.clock()+30
   end
   task.wait(0.1)
  until not alive
 end)
end
local added=CollectionService:GetInstanceAddedSignal(TAG):Connect(track)
local removed=CollectionService:GetInstanceRemovedSignal(TAG):Connect(remove)
for _,model in ipairs(CollectionService:GetTagged(TAG)) do track(model) end
local elapsed=0
local quality=RunService.Heartbeat:Connect(function(dt)
 elapsed=elapsed+dt;if elapsed<0.5 then return end;elapsed=0
 local camera=workspace.CurrentCamera
 local origin=camera and camera.CFrame.Position
 for model,entry in pairs(active) do
  if not model:IsDescendantOf(workspace) then remove(model)
  else
   local own=player.Character and model:IsDescendantOf(player.Character)
   local position=entry.Root and entry.Root.Position or model:GetPivot().Position
   local distance=origin and (origin-position).Magnitude/model:GetScale() or 0
   local rate=own and 30 or distance<100 and 30 or distance<250 and 15 or 5
   entry.View.SetQuality(rate,own or distance<250)
  end
 end
end)
script.Destroying:Connect(function()
 alive=false;added:Disconnect();removed:Disconnect();quality:Disconnect()
 for model in pairs(active) do remove(model) end
 table.clear(pending)
end)
