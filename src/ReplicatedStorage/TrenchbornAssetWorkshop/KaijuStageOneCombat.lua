-- Workshop-only damage adapter. Registered practice buildings are the only
-- damageable objects; main-game building damage must use its own service.
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")
local Combat = {}
local targets, ranges = {}, {}
local DAMAGE = {40,40,55,85} -- Review values: one complete combo = 220 HP.
local function reserveLethal(data, holder, damage)
	if not data or data.HeldBy or data.Health<=0 or data.Health>damage then return false end
	data.HeldBy=holder
	return true
end
local function releaseReservation(data, holder)
	if not data or data.HeldBy~=holder then return false end
	data.HeldBy=nil
	return true
end

local function part(parent, name, size, cf, color)
	local p = Instance.new("Part")
	p.Name, p.Size, p.CFrame = name, size, cf
	p.Anchored = true
	p.Material = Enum.Material.Concrete
	p.Color = color
	p.Parent = parent
	return p
end
local function chips(target, point, tear, destroyed)
	for i=1,(destroyed and 14 or 5) do
		local p = part(target.Parent, "ImpactDebris", Vector3.new(0.6,0.5,0.7)*(destroyed and 2 or 1),
			CFrame.new(point), Color3.fromRGB(124,115,99))
		p.CanCollide, p.CanTouch, p.CanQuery = false, false, false
		local angle=i*2.4
		local offset = Vector3.new(math.cos(angle)*4,1.5+math.sin(i)*0.5,math.sin(angle)*4)
		if tear then offset=target:GetPivot().RightVector*(i%2==0 and 7 or -7)+Vector3.new(0,2,0) end
		TweenService:Create(p,TweenInfo.new(0.45),{CFrame=CFrame.new(point+offset)*CFrame.Angles(i,0,i),Transparency=1}):Play()
		Debris:AddItem(p,0.5)
	end
end
local function flash(model)
	local h=Instance.new("Highlight")
	h.FillColor=Color3.fromRGB(255,176,80)
	h.FillTransparency, h.OutlineTransparency = 0.2,1
	h.DepthMode=Enum.HighlightDepthMode.Occluded
	h.Adornee, h.Parent = model,model
	TweenService:Create(h,TweenInfo.new(0.22),{FillTransparency=1}):Play()
	Debris:AddItem(h,0.25)
end
local function splitBuilding(target, data, right)
	-- Two recognizable building halves, each retaining its piece of the roof.
	for _, sign in ipairs({-1,1}) do
		local pivot=data.Body.CFrame*CFrame.new(sign*data.Body.Size.X/4,0,0)
		local shift=right*(sign*8)+Vector3.new(0,3,0)
		local transform=CFrame.new(shift)*pivot*CFrame.Angles(0,0,-sign*0.35)*pivot:Inverse()
		for _, source in ipairs({data.Body,data.Roof}) do
			local p=part(target.Parent,"TornBuildingHalf",Vector3.new(source.Size.X/2,source.Size.Y,source.Size.Z),
				source.CFrame*CFrame.new(sign*source.Size.X/4,0,0),source.Color)
			p.CanCollide,p.CanTouch,p.CanQuery=false,false,false
			local destination=transform*p.CFrame
			TweenService:Create(p,TweenInfo.new(0.38,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{CFrame=destination}):Play()
			task.delay(0.45,function()
				if not p.Parent then return end
				TweenService:Create(p,TweenInfo.new(0.7,Enum.EasingStyle.Quad,Enum.EasingDirection.In),
					{CFrame=CFrame.new(0,-9,0)*destination,Transparency=1}):Play()
			end)
			Debris:AddItem(p,1.2)
		end
	end
end
function Combat.RemoveRange(player)
	local range=ranges[player]
	if not range then return end
	for target in pairs(targets) do
		if target:IsDescendantOf(range) then targets[target]=nil end
	end
	range:Destroy()
	ranges[player]=nil
end
function Combat.BuildRange(player, ground, character)
	Combat.RemoveRange(player)
	local range=Instance.new("Folder")
	range.Name="KaijuCombatPractice_"..player.UserId
	range.Parent=workspace
	ranges[player]=range
	for i=1,3 do
		local cf=ground*CFrame.new((i-2)*20,0,-22)
		local params=RaycastParams.new()
		params.FilterType=Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances={character,range}
		local floor=workspace:Raycast(cf.Position+Vector3.new(0,40,0),Vector3.new(0,-100,0),params)
		if floor then cf=CFrame.new(cf.Position.X,floor.Position.Y,cf.Position.Z)*ground.Rotation end
		local model=Instance.new("Model")
		model.Name="PracticeBuilding_"..i
		model.Parent=range
		local height=5+i*2
		local body=part(model,"Building",Vector3.new(8,height,7),cf*CFrame.new(0,height/2,0),Color3.fromRGB(159,146,120))
		local roof=part(model,"Roof",Vector3.new(9,1.2,8),cf*CFrame.new(0,height+0.6,0),Color3.fromRGB(75,84,98))
		model.PrimaryPart=body
		model:SetAttribute("MaxHealth",220)
		model:SetAttribute("Health",220)
		model:SetAttribute("Destroyed",false)
		model:SetAttribute("Purpose","Combo practice; provisional damage values")
		local gui=Instance.new("BillboardGui")
		gui.Name="HitFeedback"
		gui.Adornee=roof
		gui.Size=UDim2.fromOffset(130,30)
		gui.StudsOffset=Vector3.new(0,2,0)
		gui.MaxDistance=100
		gui.Enabled=false
		gui.Parent=model
		local title=Instance.new("TextLabel")
		title.Size=UDim2.fromScale(1,0.65)
		title.BackgroundTransparency=1
		title.Text="Practice Building"
		title.TextScaled=true
		title.TextColor3=Color3.new(1,1,1)
		title.Parent=gui
		local back=Instance.new("Frame")
		back.Size=UDim2.fromScale(1,0.25)
		back.Position=UDim2.fromScale(0,0.75)
		back.BackgroundColor3=Color3.fromRGB(40,40,40)
		back.BorderSizePixel=0
		back.Parent=gui
		local bar=Instance.new("Frame")
		bar.Size=UDim2.fromScale(1,1)
		bar.BackgroundColor3=Color3.fromRGB(221,172,64)
		bar.BorderSizePixel=0
		bar.Parent=back
		targets[model]={Body=body,Roof=roof,Gui=gui,Bar=bar,Health=220,Generation=0,HomePivot=model:GetPivot()}
	end
end

function Combat.Attach(kaiju, root, humanoid, rootHeight)
	local locked
	local holder={} -- Unique server-side ownership token for this character.
	local held, reserved, liftConnection
	local candidate, candidateExpires, cue = nil,0,nil
	local function clearCue()
		if cue then cue:Destroy();cue=nil end
		kaiju:SetAttribute("FinisherAvailable",false)
	end
	local scale=kaiju:GetScale()
	local function release(restore)
		if liftConnection then liftConnection:Disconnect();liftConnection=nil end
		local target=held or reserved
		held,reserved=nil,nil
		local data=target and targets[target]
		if releaseReservation(data,holder) then
			if target.Parent then
				target:SetAttribute("Lifted",false)
				if restore and data.Health>0 then
					target:PivotTo(data.HomePivot)
					for _,p in ipairs({data.Body,data.Roof}) do p.CanCollide=true;p.CanQuery=true end
				end
			end
		end
	end
	local function cancel()
		release(true)
		locked=nil
		candidate=nil
		clearCue()
	end
	local function lift(target)
		local data=targets[target]
		if not data then return end
		local joints=kaiju:FindFirstChild("Articulation")
		local left=joints and joints:FindFirstChild("LeftHand")
		local right=joints and joints:FindFirstChild("RightHand")
		if not left or not right then return end
		if data.HeldBy~=holder or reserved~=target then return end
		held=target
		target:SetAttribute("Lifted",true)
		for _,p in ipairs({data.Body,data.Roof}) do p.CanCollide=false;p.CanQuery=false end
		local started=os.clock()
		local startRoot=root.Position
		local initial=target:GetPivot()
		liftConnection=RunService.Heartbeat:Connect(function()
			if not target.Parent or targets[target]~=data or humanoid.Health<=0
				or not kaiju:IsDescendantOf(workspace) or humanoid.FloorMaterial==Enum.Material.Air
				or os.clock()-started>2 or (root.Position-startRoot).Magnitude>6*scale then cancel();return end
			local u=math.clamp((os.clock()-started)/0.3,0,1)
			u=u*u*(3-2*u)
			local grip=(left.Position+right.Position)/2
			local destination=CFrame.new(grip)*root.CFrame.Rotation
			target:PivotTo(initial:Lerp(destination,u))
		end)
	end
	local function reachable(target, allowReserved)
		local data=targets[target]
		if not data or data.Health<=0 or not target:IsDescendantOf(workspace) then return nil end
		if data.HeldBy and not (allowReserved and data.HeldBy==holder and not held) then return nil end
		local body=data.Body
		local localCenter=root.CFrame:PointToObjectSpace(body.Position)
		if localCenter.Z>=0 then return nil end
		local from=root.Position+Vector3.new(0,4*scale-rootHeight,0)
		local p=body.CFrame:PointToObjectSpace(from)
		local half=body.Size/2
		local point=body.CFrame:PointToWorldSpace(Vector3.new(
			math.clamp(p.X,-half.X,half.X),math.clamp(p.Y,-half.Y,half.Y),math.clamp(p.Z,-half.Z,half.Z)))
		local relative=root.CFrame:PointToObjectSpace(point)
		if math.abs(relative.X)>10*scale then return nil end
		local delta=point-from
		if delta.Magnitude>13*scale then return nil end
		local params=RaycastParams.new()
		params.FilterType=Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances={kaiju.Parent}
		if delta.Magnitude>0.05 then
			local hit=workspace:Raycast(from,delta.Unit*(delta.Magnitude+0.15),params)
			if not hit or not hit.Instance:IsDescendantOf(target) then return nil end
		end
		return point,delta.Magnitude
	end
	local function selectTarget()
		local best,distance=nil,math.huge
		for target in pairs(targets) do
			local _,d=reachable(target)
			if d and d<distance then best,distance=target,d end
		end
		return best
	end
	local function prepareFinisher()
		if not candidate or os.clock()>candidateExpires or humanoid.Health<=0
			or humanoid.FloorMaterial==Enum.Material.Air or not reachable(candidate) then return false end
		local target=candidate
		if not reserveLethal(targets[target],holder,DAMAGE[4]) then return false end
		reserved,locked=target,target
		candidate=nil
		clearCue()
		return true
	end
	local function handle(kind,index,finisherUntil)
		if humanoid.Health<=0 or not root:IsDescendantOf(workspace)
			or humanoid.FloorMaterial==Enum.Material.Air then cancel();return end
		if kind=="Grab" then
			-- Never switch to a different building during the finisher.
			if reserved and locked==reserved and reachable(reserved,true) then
				lift(reserved)
			else cancel() end
			return
		end
		if kind~="Hit" or not DAMAGE[index] then return end
		candidate=nil
		clearCue()
		local target
		if index==4 then target=locked else target=selectTarget() end
		locked=nil
		local data=target and targets[target]
		local lifted=index==4 and held==target and data and data.HeldBy==holder
		local point
		if lifted then point=data.Body.Position else point=target and reachable(target) end
		if not point then cancel();kaiju:SetAttribute("LastAttackResult","Miss");return end
		data.Health=math.max(0,data.Health-DAMAGE[index])
		target:SetAttribute("Health",data.Health)
		target:SetAttribute("LastComboStep",index)
		kaiju:SetAttribute("LastAttackResult","Hit")
		data.Gui.Enabled=true
		data.Bar.Size=UDim2.fromScale(data.Health/220,1)
		flash(target)
		chips(target,point,index==4,data.Health==0)
		if index==3 and data.Health>0 and data.Health<=DAMAGE[4]
			and type(finisherUntil)=="number" and finisherUntil>os.clock() then
			-- Use the animation's deadline, rather than starting a second timer.
			candidate,candidateExpires=target,finisherUntil
			local h=Instance.new("Highlight")
			h.FillColor=Color3.fromRGB(255,225,60)
			h.FillTransparency,h.OutlineTransparency=0.4,0
			h.OutlineColor=Color3.fromRGB(255,235,100)
			h.DepthMode=Enum.HighlightDepthMode.Occluded
			h.Adornee,h.Parent=target,target
			cue=h
			kaiju:SetAttribute("FinisherAvailable",true)
			task.delay(math.max(0,finisherUntil-os.clock()),function()
				if cue==h then clearCue();candidate=nil end
			end)
		end
		if data.Health==0 then
			if lifted then splitBuilding(target,data,root.CFrame.RightVector) end
			release(false)
			target:SetAttribute("Destroyed",true)
			data.Gui.Enabled=false
			for _,p in ipairs({data.Body,data.Roof}) do p.Transparency=1;p.CanCollide=false;p.CanQuery=false end
			data.Generation=data.Generation+1
			local generation=data.Generation
			task.delay(12,function()
				if targets[target]~=data or data.Generation~=generation or not target.Parent then return end
				data.Health=220
				target:PivotTo(data.HomePivot)
				target:SetAttribute("Health",220)
				target:SetAttribute("Destroyed",false)
				data.Bar.Size=UDim2.fromScale(1,1)
				for _,p in ipairs({data.Body,data.Roof}) do p.Transparency=0;p.CanCollide=true;p.CanQuery=true end
			end)
		end
	end
	kaiju.Destroying:Once(cancel)
	return {Handle=handle,Cancel=cancel,PrepareFinisher=prepareFinisher}
end
return Combat
