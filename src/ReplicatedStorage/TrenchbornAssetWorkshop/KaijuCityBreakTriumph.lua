-- Shared procedural sampler for the City Broken triumph animation.
-- Pure math only: server may use Duration, while clients consume Sample().
local Triumph = {}

Triumph.Duration = 5.1
Triumph.RoarAt = 1.65
Triumph.ShockwaveAt = 1.82

local function smooth(value)
	local t = math.clamp(value, 0, 1)
	return t * t * (3 - 2 * t)
end

function Triumph.Sample(time)
	local t = math.max(0, time)

	local settleIn = smooth(t / 0.40)
	local settleOut = smooth((t - 0.34) / 0.58)
	local settle = settleIn * (1 - settleOut)

	local rise = smooth((t - 0.34) / 0.86)
	local tension = smooth((t - 1.08) / 0.54)

	local roarIn = smooth((t - 1.56) / 0.16)
	local roarOut = smooth((t - 3.02) / 0.40)
	local roar = roarIn * (1 - roarOut)

	local holdIn = smooth((t - 2.82) / 0.34)
	local holdOut = smooth((t - 4.52) / 0.58)
	local hold = holdIn * (1 - holdOut)

	local recovery = smooth((t - 4.52) / 0.58)
	local dominance = math.clamp(math.max(rise * 0.82, roar, hold) * (1 - recovery), 0, 1)
	local tremor = math.sin(t * 46) * roar
	local breath = math.sin((t - 1.55) * 8.5) * roar
	local asymmetry = smooth((t - 2.35) / 0.55) * (1 - recovery)

	local poses = {
		Torso = {-6 * settle + 8 * rise + 3 * roar + 0.7 * tremor, 0, 1.4 * breath},
		-- Positive local X raises the head on this rig. v1 used the opposite
		-- sign and made the Kaiju stare at the ground during the roar.
		Head = {-4 * settle + 24 * tension + 8 * roar, 5 * asymmetry, -2 * asymmetry},
		Jaw = {-42 * roar - 12 * hold * (1 - recovery), 0, 0},
		TailBase = {5 * dominance, 0, 0},
	}

	for _, side in ipairs({"Left", "Right"}) do
		local sign = side == "Left" and -1 or 1
		poses[side .. "UpperArm"] = {
			-5 * rise - 13 * roar - (side == "Left" and 4 or 0) * asymmetry,
			-sign * (7 * rise + 11 * roar),
			sign * (28 * rise + 24 * roar + 7 * asymmetry),
		}
		poses[side .. "Forearm"] = {
			-8 * rise - (side == "Left" and 16 or 10) * roar,
			-sign * 4 * roar,
			-sign * (side == "Left" and 5 or 8) * asymmetry,
		}
		poses[side .. "Hand"] = {
			-5 * rise - 9 * roar,
			-sign * (5 * dominance + 4 * roar),
			sign * 3 * roar,
		}
	end

	return {
		Bob = -1.15 * settle,
		Poses = poses,
		Roar = roar,
		Dominance = dominance,
		Energy = smooth((t - 1.10) / 0.48) * (1 - smooth((t - 3.42) / 1.05)),
		TailMotion = dominance * (1 - 0.55 * recovery),
		Finished = t >= Triumph.Duration,
	}
end

return Triumph
