-- Three-hit combo with a server-authorized, optional lethal finisher.
local Combo = {}
local function hook(side, sign)
	local other = side == "Left" and "Right" or "Left"
	local function pose(pitch, yaw, arm, elbow, cross)
		return {Torso={pitch,yaw,sign*3}, Head={-pitch*0.2,-yaw*0.5,0},
			[side.."UpperArm"]={arm,sign*cross,-sign*12},
			[side.."Forearm"]={elbow,0,0}, [side.."Hand"]={0,sign*12,0},
			[other.."UpperArm"]={22,0,0}, [other.."Forearm"]={30,0,0}}
	end
	-- Raise the striking arm, then sweep diagonally down toward a low roof.
	return {{0,{},0}, {0.28,pose(-10,-sign*18,65,40,-22),0.8},
		{0.44,pose(-32,sign*20,42,4,28),2.3},
		{0.53,pose(-35,sign*23,34,2,34),2.5}, {0.95,{},0}}
end
local function both(pitch, arm, elbow, spread)
	return {Torso={pitch,0,0}, Head={-pitch*0.2,0,0}, Jaw={-5,0,0},
		LeftUpperArm={arm,-spread,10}, RightUpperArm={arm,spread,-10},
		LeftForearm={elbow,0,0}, RightForearm={elbow,0,0},
		LeftHand={0,-18,0}, RightHand={0,18,0}}
end
local function tear(pitch, arm, elbow, spread, head, jaw, flare)
	local p = both(pitch, arm, elbow, spread)
	p.Head = {head,0,0}
	p.Jaw = {jaw,0,0}
	p.LeftUpperArm[3], p.RightUpperArm[3] = -flare, flare
	return p
end
local attacks = {
	{Name="Left Hook", Frames=hook("Left",-1)},
	{Name="Right Hook", Frames=hook("Right",1)},
	{Name="Double Slam", Frames={{0,{},0},{0.34,both(-5,125,20,-8),0.4},
		{0.54,both(-36,48,2,16),2.8},{0.65,both(-38,40,0,18),3.0},{1.2,{},0}}},
	{Name="Rip Apart", Frames={
		{0,{},0},
		-- Reach low, close the grip and visibly load against resistance.
		{0.38,tear(-34,48,12,40,4,-4,0),2.6},
		{0.62,tear(-38,44,16,44,2,-7,0),3.0},
		-- Lift the closed grip in front of the chest/eyes before tearing.
		{0.92,tear(-5,100,30,70,5,-9,-20),0.5},
		{1.08,tear(-5,100,30,70,5,-11,-20),0.5},
		-- Shoulder roll lifts the arms to the sides. Yaw alone left them low.
		{1.34,tear(-5,10,15,-10,8,-18,85),0.3},
		{1.46,tear(-3,0,12,-8,10,-20,95),0.2},
		-- Hold both hands above the shoulders in a broad, raised finishing pose.
		{1.64,tear(-5,15,18,-10,7,-14,85),0.4},
		{1.90,tear(-5,15,18,-10,7,-14,85),0.4},
		{2.45,{},0},
	}},
}
local impactTimes = {0.44, 0.44, 0.54, 1.34}
function Combo.new(prepareFinisher)
	local state = {Index=0, Started=0, Ended=-math.huge, Active=false, Queued=false, Events={}}
	local function start(index, now)
		state.Index=index
		state.Started, state.Active, state.Queued = now, true, false
		state.HitSent, state.GrabSent = false, false
		state.FinisherUntil=nil
	end
	function state:Request(now)
		-- Keep the offer through the third strike's recovery AND 0.4s after it.
		-- It must also work after Sample has marked the third animation complete.
		if self.Index==3 and self.HitSent and self.FinisherUntil
			and now<=self.FinisherUntil and prepareFinisher and prepareFinisher() then
			start(4,now)
			return true
		end
		if self.Active then
			if self.Index==3 then
				local sinceHit=now-self.Started-impactTimes[3]
				if sinceHit<0 or not self.HitSent then return false end
				-- Failed/late finisher input becomes a normal left strike after recovery.
				if not self.Queued then self.Queued=true;return true end
				return false
			end
			local frames = attacks[self.Index].Frames
			local remaining = self.Started + frames[#frames][1] - now
			if remaining <= 0.35 and remaining >= 0 and not self.Queued then
				self.Queued = true
				return true
			end
			return false
		end
		local nextIndex = (self.Index==1 or self.Index==2) and self.Index+1 or 1
		start(now-self.Ended > 1.1 and 1 or nextIndex, now)
		return true
	end
	function state:Cancel()
		self.Index, self.Active, self.Queued, self.Ended = 0, false, false, -math.huge
		self.Events = {}
		self.FinisherUntil=nil
	end
	function state:DrainEvents()
		local events = self.Events
		self.Events = {}
		return events
	end
	function state:Sample(now)
		if not self.Active then return nil end
		local attack = attacks[self.Index]
		local frames = attack.Frames
		local t = now-self.Started
		local duration = frames[#frames][1]
		-- Crossing markers (not equality checks) survives skipped animation frames.
		if self.Index == 4 and t >= 0.62 and not self.GrabSent then
			self.GrabSent = true
			table.insert(self.Events, {Kind="Grab", Index=4})
		end
		if t >= impactTimes[self.Index] and not self.HitSent then
			self.HitSent = true
			if self.Index==3 then self.FinisherUntil=self.Started+duration+0.4 end
			table.insert(self.Events, {Kind="Hit", Index=self.Index, FinisherUntil=self.FinisherUntil})
		end
		if t >= duration then
			self.Ended, self.Active = self.Started+duration, false
			if self.Queued then
				-- A buffered normal strike is never retroactively promoted to a finisher.
				local nextIndex=(self.Index==1 or self.Index==2) and self.Index+1 or 1
				start(nextIndex,now)
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
		local crouch=(a[3] or 0)+((b[3] or 0)-(a[3] or 0))*u
		return result, weight, attack.Name, self.Index, crouch
	end
	return state
end
return Combo
