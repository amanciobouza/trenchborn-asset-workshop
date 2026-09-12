-- Workshop-only damage adapter. Registered practice buildings are the only
-- damageable objects; main-game building damage must use its own service.
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Combat = {}
local targets, ranges = {}, {}
local DAMAGE = {40,40,55,85} -- Review values: one complete combo = 220 HP.

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
		model.Name="Testgebaeude_"..i
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
		title.Text="Testgebäude"
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
		targets[model]={Body=body,Roof=roof,Gui=gui,Bar=bar,Health=220,Generation=0}
	end
end

function Combat.Attach(kaiju, root, humanoid, rootHeight)
	local locked
	local scale=kaiju:GetScale()
	local function reachable(target)
		local data=targets[target]
		if not data or data.Health<=0 or not target:IsDescendantOf(workspace) then return nil end
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
	local function handle(kind,index)
		if humanoid.Health<=0 or not root:IsDescendantOf(workspace)
			or humanoid.FloorMaterial==Enum.Material.Air then locked=nil;return end
		if kind=="Grab" then locked=selectTarget(); return end
		if kind~="Hit" or not DAMAGE[index] then return end
		local target
		if index==4 then target=locked else target=selectTarget() end
		locked=nil
		local point=target and reachable(target)
		if not point then kaiju:SetAttribute("LastAttackResult","Miss");return end
		local data=targets[target]
		data.Health=math.max(0,data.Health-DAMAGE[index])
		target:SetAttribute("Health",data.Health)
		target:SetAttribute("LastComboStep",index)
		kaiju:SetAttribute("LastAttackResult","Hit")
		data.Gui.Enabled=true
		data.Bar.Size=UDim2.fromScale(data.Health/220,1)
		flash(target)
		chips(target,point,index==4,data.Health==0)
		if data.Health==0 then
			target:SetAttribute("Destroyed",true)
			data.Gui.Enabled=false
			for _,p in ipairs({data.Body,data.Roof}) do p.Transparency=1;p.CanCollide=false;p.CanQuery=false end
			data.Generation=data.Generation+1
			local generation=data.Generation
			task.delay(12,function()
				if targets[target]~=data or data.Generation~=generation or not target.Parent then return end
				data.Health=220
				target:SetAttribute("Health",220)
				target:SetAttribute("Destroyed",false)
				data.Bar.Size=UDim2.fromScale(1,1)
				for _,p in ipairs({data.Body,data.Roof}) do p.Transparency=0;p.CanCollide=true;p.CanQuery=true end
			end)
		end
	end
	return {Handle=handle}
end
return Combat
