-- Jump timing is server-owned. Cooldown starts with activation.
local Jump = {}
local function smooth(t) t=math.max(0,math.min(1,t));return t*t*(3-2*t) end
function Jump.new()
	local s={Phase="Idle",Started=0,ReadyAt=0,LeftGround=false}
	function s:Request(now,grounded)
		if self.Phase~="Idle" or not grounded or now<self.ReadyAt then return false end
		self.Phase,self.Started,self.ReadyAt="Windup",now,now+1.2
		self.LeftGround=false
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
			if grounded and verticalSpeed<=1 and ((self.LeftGround and t>0.1) or t>0.5) then
				self.Phase,self.Started="Landing",now;t=0
			elseif t>6 then self:Cancel();return nil,"Restore" end
		elseif self.Phase=="Landing" and t>=0.65 then
			self:Cancel();return nil,"Restore"
		end
		if self.Phase=="Windup" then
			local u=smooth(t/0.32)
			return {Crouch=3.2*u,Tuck=0,Pitch=-22*u,Arm=-25*u,Elbow=12*u,Head=7*u,Pulse=0},event
		elseif self.Phase=="Air" then
			local tuck=smooth(t/0.2)*(verticalSpeed>0 and 1 or 0.55)
			return {Crouch=0,Tuck=3*tuck,Pitch=-8,Arm=verticalSpeed>0 and 65 or 28,Elbow=18,Head=3,Pulse=0},event
		elseif self.Phase=="Landing" then
			local compression=t<0.12 and smooth(t/0.12) or 1-smooth((t-0.12)/0.53)
			return {Crouch=3.6*compression,Tuck=0,Pitch=-24*compression,
				Arm=-14*compression,Elbow=22*compression,Head=8*compression,Pulse=compression},event
		end
		return nil,event
	end
	return s
end
return Jump
