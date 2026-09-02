local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local remote = ReplicatedStorage:WaitForChild(script:GetAttribute("RemoteName"))
local SOUND_ID = "rbxassetid://146785518"

local function beep(delaySeconds, speed)
	task.delay(delaySeconds, function()
		local sound = Instance.new("Sound")
		sound.Name = "AegisMissileLockLocal"
		sound.SoundId = SOUND_ID
		sound.Volume = 0.62
		sound.PlaybackSpeed = speed
		sound.Parent = SoundService
		sound:Play()
		game:GetService("Debris"):AddItem(sound, 3)
	end)
end

remote.OnClientEvent:Connect(function(message, duration)
	if message ~= "MissileLock" then return end
	local lockDuration = duration or 2
	beep(0, 0.92)
	beep(math.min(0.68, lockDuration * 0.34), 1.0)
	beep(math.min(1.36, lockDuration * 0.68), 1.1)
end)
