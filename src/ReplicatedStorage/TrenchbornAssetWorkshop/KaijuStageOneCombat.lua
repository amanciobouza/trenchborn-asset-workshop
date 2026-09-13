-- Workshop-only damage adapter. Registered practice buildings are the only
-- damageable objects; main-game building damage must use its own service.
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")
local Combat = {}
local targets, ranges = {}, {}
local DAMAGE = {40,40,55,85} -- Review values: one complete combo = 220 HP.
local LAND_DAMAGE=55 -- Provisional workshop value; no area damage or repeated ticks.
local FOCUS_DAMAGE=15 -- Workshop value per 0.25-second tick (150 per full beam).
local AREA_DAMAGE=80 -- Provisional workshop value; once per building per slam.
local AREA_RADIUS=26
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
local function chips(target, point, tear, destroyed, strikeIndex, right)
	for i=1,(destroyed and 14 or 5) do
		local p = part(target.Parent, "ImpactDebris", Vector3.new(0.6,0.5,0.7)*(destroyed and 2 or 1),
			CFrame.new(point), Color3.fromRGB(124,115,99))
		p.CanCollide, p.CanTouch, p.CanQuery = false, false, false
		local angle=i*2.4
		local offset = Vector3.new(math.cos(angle)*4,1.5+math.sin(i)*0.5,math.sin(angle)*4)
		if tear then offset=target:GetPivot().RightVector*(i%2==0 and 7 or -7)+Vector3.new(0,2,0)
		elseif strikeIndex==1 or strikeIndex==2 then
			offset=right*(strikeIndex==1 and 1 or -1)*(4+i%3)+offset*0.3
		elseif strikeIndex==3 then
			offset=Vector3.new(offset.X*1.4,-1-i%3*0.4,offset.Z*1.4)
		end
		TweenService:Create(p,TweenInfo.new(0.45),{CFrame=CFrame.new(point+offset)*CFrame.Angles(i,0,i),Transparency=1}):Play()
		Debris:AddItem(p,0.5)
	end
end
local function contactDust(target,point,index,right,scale)
	for i=1,4 do
		local dust=part(target.Parent,"ContactDust",Vector3.new(0.6,0.6,0.6)*scale,CFrame.new(point),Color3.fromRGB(145,138,121))
		dust.Shape=Enum.PartType.Ball;dust.Material=Enum.Material.SmoothPlastic
		dust.Transparency=0.5;dust.CanCollide=false;dust.CanTouch=false;dust.CanQuery=false;dust.CastShadow=false
		local angle=i*2.4
		local spread=Vector3.new(math.cos(angle),0.4,math.sin(angle))
		if index<=2 then spread=spread+right*(index==1 and 2 or -2)
		else spread=Vector3.new(spread.X*2,-0.3,spread.Z*2) end
		TweenService:Create(dust,TweenInfo.new(0.32),{Position=point+spread*scale,Size=Vector3.new(2,1.4,2)*scale,Transparency=1}):Play()
		Debris:AddItem(dust,0.35)
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
	local function meleePoint(target,index)
		local data=targets[target]
		if not data or data.Health<=0 or data.HeldBy or not target:IsDescendantOf(workspace) then return nil end
		local from=root.Position+Vector3.new(0,4*scale-rootHeight,0)
		local probes={from}
		local joints=kaiju:FindFirstChild("Articulation")
		local sides=index==1 and {"Left"} or index==2 and {"Right"} or {"Left","Right"}
		local preferred={}
		for _,side in ipairs(sides) do
			local hand=joints and joints:FindFirstChild(side.."Hand")
			local palm=kaiju:FindFirstChild(side.."PalmCoreZ")
			if hand then
				-- Project the broad fist down to small roofs, keeping the original reach.
				local localHand=root.CFrame:PointToObjectSpace(hand.Position)
				local width=palm and math.max(palm.Size.X,palm.Size.Z)/2 or 1.5*scale
				width=math.clamp(width,0.5*scale,2.5*scale)
				for _,offset in ipairs({0,-width,width}) do
					local probe=root.CFrame:PointToWorldSpace(Vector3.new(
						math.clamp(localHand.X+offset,-10*scale,10*scale),
						4*scale-rootHeight,math.clamp(localHand.Z,-13*scale,-1*scale)))
					table.insert(probes,probe)
					if offset==0 then table.insert(preferred,probe) end
				end
			end
		end
		local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances={kaiju.Parent}
		local best,bestScore=nil,math.huge
		for _,surface in ipairs({data.Body,data.Roof}) do
			for _,probe in ipairs(probes) do
				local p=surface.CFrame:PointToObjectSpace(probe)
				local half=surface.Size/2
				local point=surface.CFrame:PointToWorldSpace(Vector3.new(
					math.clamp(p.X,-half.X,half.X),math.clamp(p.Y,-half.Y,half.Y),math.clamp(p.Z,-half.Z,half.Z)))
				local relative=root.CFrame:PointToObjectSpace(point)
				local delta=point-from
				if relative.Z<0 and math.abs(relative.X)<=10*scale and delta.Magnitude<=13*scale then
					local hit=delta.Magnitude>0.05 and workspace:Raycast(from,delta.Unit*(delta.Magnitude+0.15),params)
					if delta.Magnitude<=0.05 or (hit and hit.Instance:IsDescendantOf(target)) then
						local contact=hit and hit.Position or point
						local handDistance=math.huge
						for _,center in ipairs(preferred) do handDistance=math.min(handDistance,(contact-center).Magnitude) end
						if #preferred==0 then handDistance=delta.Magnitude end
						local score=handDistance+delta.Magnitude*0.25
						if score<bestScore then best,bestScore=contact,score end
					end
				end
			end
		end
		return best,bestScore
	end
	local function selectTarget(index)
		local best,point,distance=nil,nil,math.huge
		for target in pairs(targets) do
			local p,d=meleePoint(target,index)
			if p and d<distance then best,point,distance=target,p,d end
		end
		return best,point
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
	local function landingTarget()
		local params=RaycastParams.new()
		params.FilterType=Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances={kaiju.Parent}
		-- Use the actual support surface, not the forward melee targeting cone.
		local hit=workspace:Raycast(root.Position,Vector3.new(0,-rootHeight-2,0),params)
		if not hit or hit.Normal.Y<0.5 then return nil end
		for target,data in pairs(targets) do
			if data.Health>0 and not data.HeldBy and hit.Instance:IsDescendantOf(target) then
				return target,hit.Position
			end
		end
		return nil
	end
	local function focusAim(target,from)
		local data=target and targets[target]
		if not data or data.Health<=0 or data.HeldBy or not target:IsDescendantOf(workspace) then return nil,false end
		local delta=data.Body.Position-from
		local flat=data.Body.Position-root.Position
		flat=Vector3.new(flat.X,0,flat.Z)
		if delta.Magnitude>70*scale or flat.Magnitude<0.01
			or flat.Unit:Dot(root.CFrame.LookVector)<0.5 then return nil,false end
		local params=RaycastParams.new()
		params.FilterType=Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances={kaiju.Parent}
		local hit=workspace:Raycast(from,delta,params)
		return hit and hit.Position or data.Body.Position,hit~=nil and hit.Instance:IsDescendantOf(target)
	end
	local function selectFocusTarget(from)
		local best,distance=nil,math.huge
		for target in pairs(targets) do
			local point,visible=focusAim(target,from)
			if visible and (point-from).Magnitude<distance then
				best,distance=target,(point-from).Magnitude
			end
		end
		return best
	end
	local function areaPoint(target,origin)
		local data=target and targets[target]
		if not data or data.Health<=0 or data.HeldBy or not target:IsDescendantOf(workspace) then return nil end
		local body=data.Body
		local p=body.CFrame:PointToObjectSpace(origin)
		local half=body.Size/2
		local point=body.CFrame:PointToWorldSpace(Vector3.new(math.clamp(p.X,-half.X,half.X),
			math.clamp(p.Y,-half.Y,half.Y),math.clamp(p.Z,-half.Z,half.Z)))
		return (point-origin).Magnitude<=AREA_RADIUS*scale and point or nil
	end
	local function handle(kind,index,finisherUntil,from)
		if humanoid.Health<=0 or not root:IsDescendantOf(workspace)
			or humanoid.FloorMaterial==Enum.Material.Air then cancel();return end
		if kind=="Grab" then
			-- Never switch to a different building during the finisher.
			if reserved and locked==reserved and reachable(reserved,true) then
				lift(reserved)
			else cancel() end
			return
		end
		local landing=kind=="Land"
		local focus=kind=="Focus"
		local area=kind=="Area"
		if not landing and not focus and not area and (kind~="Hit" or not DAMAGE[index]) then return end
		local damage=area and AREA_DAMAGE or focus and FOCUS_DAMAGE or landing and LAND_DAMAGE or DAMAGE[index]
		candidate=nil
		clearCue()
		local target,point
		if area then target=finisherUntil;point=areaPoint(target,from)
		elseif focus then
			target=finisherUntil
			local visible
			point,visible=focusAim(target,from)
			if not visible then point=nil end
		elseif landing then target,point=landingTarget()
		elseif index==4 then target=locked else target,point=selectTarget(index) end
		locked=nil
		local data=target and targets[target]
		local lifted=index==4 and held==target and data and data.HeldBy==holder
		if not landing and not focus and not area and index==4 then
			if lifted then point=data.Body.Position else point=target and reachable(target) end
		end
		if not point then cancel();kaiju:SetAttribute("LastAttackResult","Miss");return end
		data.Health=math.max(0,data.Health-damage)
		target:SetAttribute("Health",data.Health)
		target:SetAttribute("LastComboStep",index)
		target:SetAttribute("LastDamageType",area and "Area" or focus and "Focus" or landing and "Landing" or "Combo")
		kaiju:SetAttribute("LastAttackResult","Hit")
		data.Gui.Enabled=true
		data.Bar.Size=UDim2.fromScale(data.Health/220,1)
		flash(target)
		local strikeIndex=kind=="Hit" and index<=3 and index or nil
		chips(target,point,index==4,data.Health==0,strikeIndex,root.CFrame.RightVector)
		if strikeIndex then contactDust(target,point,strikeIndex,root.CFrame.RightVector,scale) end
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
		return true -- Explicit confirmation for arm resistance; misses never trigger it.
	end
	local function areaImpact(origin)
		if humanoid.Health<=0 or humanoid.FloorMaterial==Enum.Material.Air
			or not root:IsDescendantOf(workspace) or (origin-root.Position).Magnitude>20*scale then return end
		local victims={}
		for target in pairs(targets) do if areaPoint(target,origin) then table.insert(victims,target) end end
		for _,target in ipairs(victims) do handle("Area",0,target,origin) end
		kaiju:SetAttribute("AreaHitCount",#victims)
		local cyan=Color3.fromRGB(65,225,255)
		local radius=AREA_RADIUS*scale
		local diameter=radius*2
		-- The discharge starts visibly at the large dorsal plates, then hits the ground.
		for i=1,3 do
			local plate=kaiju:FindFirstChild(string.format("DorsalShield_%02d",i))
			if plate and plate:IsA("BasePart") then
				local spark=part(workspace,"DorsalDischarge",Vector3.new(1,1,1)*(radius*0.08),CFrame.new(plate.Position),cyan)
				spark.Shape=Enum.PartType.Ball;spark.Material=Enum.Material.Neon
				spark.Transparency=0.3
				spark.CanCollide=false;spark.CanTouch=false;spark.CanQuery=false;spark.CastShadow=false
				local light=Instance.new("PointLight")
				light.Color=cyan;light.Brightness=4;light.Range=math.min(60,radius*1.25);light.Parent=spark
				-- Each pressure sphere reaches the attack's full diameter. Center the
				-- expanded volume over the impact so its horizontal reach matches damage.
				local expansion=0.45+i*0.04
				TweenService:Create(spark,TweenInfo.new(expansion,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),
					{Size=Vector3.new(diameter,diameter,diameter),
						CFrame=CFrame.new(origin+Vector3.new(0,radius*0.2,0)),Transparency=0.65}):Play()
				task.delay(expansion,function()
					if not spark.Parent then return end
					TweenService:Create(spark,TweenInfo.new(0.25),{Transparency=1}):Play()
				end)
				TweenService:Create(light,TweenInfo.new(expansion+0.25),{Brightness=0}):Play()
				Debris:AddItem(spark,expansion+0.3)
			end
		end
		local burst=part(workspace,"AreaGroundFlash",Vector3.new(3,0.25,3)*scale,CFrame.new(origin),cyan)
		burst.Shape=Enum.PartType.Ball;burst.Material=Enum.Material.Neon
		burst.CanCollide=false;burst.CanTouch=false;burst.CanQuery=false;burst.CastShadow=false
		TweenService:Create(burst,TweenInfo.new(0.35),{Size=Vector3.new(diameter,0.3*scale,diameter),Transparency=1}):Play()
		Debris:AddItem(burst,0.4)
		for i=1,28 do
			local angle=i*2.39996
			local direction=Vector3.new(math.cos(angle),0,math.sin(angle))
			local start=origin+direction*(4+i%6)*scale
			local rock=part(workspace,"AreaDebris",Vector3.new(1.8+i%3*0.8,1.5+i%2*0.6,2.4)*scale,CFrame.new(start),Color3.fromRGB(90,95,102))
			rock.CanCollide=false;rock.CanTouch=false;rock.CanQuery=false
			local peak=start+(direction*(5+i%6)+Vector3.new(0,7+i%5,0))*scale
			TweenService:Create(rock,TweenInfo.new(0.3,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),
				{CFrame=CFrame.new(peak)*CFrame.Angles(i,0,i*0.4)}):Play()
			task.delay(0.3,function()
				if not rock.Parent then return end
				TweenService:Create(rock,TweenInfo.new(0.6,Enum.EasingStyle.Quad,Enum.EasingDirection.In),
					{CFrame=CFrame.new(peak+direction*4*scale-Vector3.new(0,11,0)*scale),Transparency=1}):Play()
			end)
			Debris:AddItem(rock,1)
		end
	end
	kaiju.Destroying:Once(cancel)
	return {Handle=handle,Cancel=cancel,PrepareFinisher=prepareFinisher,FocusAim=focusAim,SelectFocusTarget=selectFocusTarget,AreaImpact=areaImpact}
end
return Combat
