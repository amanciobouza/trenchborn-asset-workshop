-- Server-owned four-hit animation sequence. No client-supplied step or timing.
local Combo = {}
local function hook(side, sign)
	local other = side == "Left" and "Right" or "Left"
	local function pose(pitch, yaw, arm, elbow, cross)
		return {Torso={pitch,yaw,sign*3}, Head={-pitch*0.4,-yaw*0.5,0},
			[side.."UpperArm"]={arm,sign*cross,-sign*12},
			[side.."Forearm"]={elbow,0,0}, [side.."Hand"]={0,sign*12,0},
			[other.."UpperArm"]={22,0,0}, [other.."Forearm"]={30,0,0}}
	end
	return {{0,{}}, {0.28,pose(-3,-sign*18,12,48,-22)},
		{0.44,pose(-13,sign*20,70,8,35)},
		{0.53,pose(-14,sign*23,74,6,40)}, {0.95,{}}}
end
local function both(pitch, arm, elbow, spread)
	return {Torso={pitch,0,0}, Head={-pitch*0.4,0,0}, Jaw={-5,0,0},
		LeftUpperArm={arm,-spread,10}, RightUpperArm={arm,spread,-10},
		LeftForearm={elbow,0,0}, RightForearm={elbow,0,0},
		LeftHand={0,-18,0}, RightHand={0,18,0}}
end
local attacks = {
	{Name="Links", Frames=hook("Left",-1)},
	{Name="Rechts", Frames=hook("Right",1)},
	{Name="Beide", Frames={{0,{}},{0.34,both(2,15,48,-12)},
		{0.54,both(-17,76,6,16)},{0.65,both(-18,80,5,18)},{1.2,{}}}},
	{Name="Zerreissen", Frames={{0,{}},{0.38,both(-13,72,20,40)},
		{0.54,both(-14,76,18,42)},{0.78,both(3,52,32,-48)},
		{0.92,both(4,48,36,-52)},{1.45,{}}}},
}
function Combo.new()
	local state = {Index=0, Started=0, Ended=-math.huge, Active=false, Queued=false}
	function state:Request(now)
		if self.Active then
			local frames = attacks[self.Index].Frames
			local remaining = self.Started + frames[#frames][1] - now
			if remaining <= 0.35 and remaining >= 0 and not self.Queued then
				self.Queued = true
				return true
			end
			return false
		end
		self.Index = now-self.Ended > 1.1 and 1 or self.Index%4+1
		self.Started, self.Active, self.Queued = now, true, false
		return true
	end
	function state:Cancel()
		self.Index, self.Active, self.Queued, self.Ended = 0, false, false, -math.huge
	end
	function state:Sample(now)
		if not self.Active then return nil end
		local attack = attacks[self.Index]
		local frames = attack.Frames
		local t = now-self.Started
		local duration = frames[#frames][1]
		if t >= duration then
			self.Ended, self.Active = self.Started+duration, false
			if self.Queued then
				self:Request(now)
				return self:Sample(now)
			end
			return nil
		end
		local a, b = frames[1], frames[2]
		for i=2,#frames do
			if t <= frames[i][1] then a,b=frames[i-1],frames[i]; break end
		end
		local u = math.max(0,math.min(1,(t-a[1])/(b[1]-a[1])))
		u = u*u*(3-2*u)
		local result, names = {}, {}
		for name in pairs(a[2]) do names[name]=true end
		for name in pairs(b[2]) do names[name]=true end
		for name in pairs(names) do
			local p,q = a[2][name] or {0,0,0}, b[2][name] or {0,0,0}
			result[name]={p[1]+(q[1]-p[1])*u,p[2]+(q[2]-p[2])*u,p[3]+(q[3]-p[3])*u}
		end
		local weight=math.max(0,math.min(1,t/0.12,(duration-t)/0.25))
		return result, weight, attack.Name, self.Index
	end
	return state
end
return Combo
