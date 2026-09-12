-- Jump timing is server-owned. Cooldown starts with activation.
local Jump = {}
local function smooth(t) t=math.max(0,math.min(1,t));return t*t*(3-2*t) end
function Jump.new()
	local s={Phase="Idle",Started=0,ReadyAt=0,LeftGround=false,Lead="Right"}
	function s:Request(now,grounded)
		if self.Phase~="Idle" or not grounded or now<self.ReadyAt then return false end
		self.Phase,self.Started,self.ReadyAt="Windup",now,now+1.2
		self.LeftGround=false
		self.Lead=self.Lead=="Left" and "Right" or "Left"
		return true
	end
	function s:Cancel() self.Phase="Idle";self.LeftGround=false end
	function s:Update(now,grounded,verticalSpeed)
		local t=now-self.Started
		local event
		if self.Phase=="Windup" then
			if not grounded then self:Cancel();return nil,"Restore" end
			if t>=0.32 then
				self.Phase,self.Started="Air",now
				event="Takeoff";t=0
			end
		elseif self.Phase=="Air" then
			if not grounded then self.LeftGround=true end
			if grounded and ((self.LeftGround and t>0.1) or (not self.LeftGround and t>0.5 and verticalSpeed<=1)) then
				-- Only a real airborne-to-ground transition can deal landing damage.
				if self.LeftGround then event="Land" end
				self.Phase,self.Started="Landing",now;t=0
			elseif t>6 then self:Cancel();return nil,"Restore" end
		elseif self.Phase=="Landing" and t>=0.85 then
			self:Cancel();return nil,"Restore"
		end
		if self.Phase=="Windup" then
			local u=smooth(t/0.32)
			-- One foot stays planted while the opposite knee drives up and forward.
			return {Crouch=2.6*u,Tuck=0,LeadLift=2*u,TrailLift=0,
				LeadForward=-1.4*u,TrailForward=0,Asymmetry=u,
				Pitch=-18*u,Arm=-12*u,Elbow=12*u,Head=7*u,Pulse=0},event
		elseif self.Phase=="Air" then
			-- Bring both feet down during descent, before contact rather than after it.
			local ready=smooth(-verticalSpeed/18)
			local asymmetry=1-ready
			local tuck=smooth(t/0.2)*asymmetry
			return {Crouch=0.7*ready,Tuck=0,LeadLift=(1.2+4.2*smooth(t/0.2))*asymmetry,TrailLift=0.7*tuck,
				LeadForward=-2.2*tuck,TrailForward=1.3*tuck,Asymmetry=asymmetry,
				Pitch=-8,Arm=verticalSpeed>0 and 30 or 18,Elbow=18,Head=3,Pulse=0},event
		elseif self.Phase=="Landing" then
			-- Compress once, hold the weight, then rise slowly without an overshoot.
			local crouch
			if t<0.12 then crouch=0.7+2.9*smooth(t/0.12)
			elseif t<0.24 then crouch=3.6
			else crouch=3.6*(1-smooth((t-0.24)/0.61)) end
			local compression=crouch/3.6
			return {Crouch=crouch,Tuck=0,Pitch=-24*compression,
				Arm=-14*compression,Elbow=22*compression,Head=8*compression,Pulse=compression},event
		end
		return nil,event
	end
	return s
end
return Jump
