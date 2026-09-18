local RunService = game:GetService("RunService")

local Pong = {}

local WHITE = Color3.fromRGB(245, 248, 250)
local PITCH_CENTER_Z = 4
local LEFT_X = -45
local RIGHT_X = 45
local BALL_X_LIMIT = 42.5
local Z_LIMIT = 25
local BALL_SPEED_X = 24
local BALL_SPEED_Z = 15
local PADDLE_FOLLOW_SPEED = 7

local function makePart(parent, name, size, localPosition, rootCFrame)
	local item = Instance.new("Part")
	item.Name = name
	item.Size = size
	item.CFrame = rootCFrame * CFrame.new(localPosition)
	item.Color = WHITE
	item.Material = Enum.Material.Neon
	item.Anchored = true
	item.CanCollide = false
	item.CanQuery = false
	item.CanTouch = false
	item.CastShadow = false
	item.TopSurface = Enum.SurfaceType.Smooth
	item.BottomSurface = Enum.SurfaceType.Smooth
	item.Parent = parent
	return item
end

local function localToWorld(rootCFrame, x, y, z)
	return (rootCFrame * CFrame.new(x, y, z))
end

function Pong.Attach(model)
	local existing = model:FindFirstChild("PongEasterEgg")
	if existing then
		existing:Destroy()
	end

	if model:GetAttribute("PongEnabled") == nil then
		model:SetAttribute("PongEnabled", true)
	end

	local root = model.PrimaryPart
	assert(root, "Large City Stadium Pong requires model.PrimaryPart")

	local folder = Instance.new("Folder")
	folder.Name = "PongEasterEgg"
	folder.Parent = model

	local rootCFrame = root.CFrame
	local y = 1.35

	local leftPaddle = makePart(folder, "LeftPaddle", Vector3.new(1.25, 0.32, 12), Vector3.new(LEFT_X, y, PITCH_CENTER_Z), rootCFrame)
	local rightPaddle = makePart(folder, "RightPaddle", Vector3.new(1.25, 0.32, 12), Vector3.new(RIGHT_X, y, PITCH_CENTER_Z), rootCFrame)
	local ball = makePart(folder, "Ball", Vector3.new(2.2, 0.34, 2.2), Vector3.new(0, y + 0.02, PITCH_CENTER_Z), rootCFrame)

	local beep = Instance.new("Sound")
	beep.Name = "PongBeep"
	beep.SoundId = "rbxasset://sounds/electronicpingshort.wav"
	beep.Volume = 0.18
	beep.RollOffMaxDistance = 95
	beep.RollOffMinDistance = 8
	beep.RollOffMode = Enum.RollOffMode.Inverse
	beep.Parent = ball

	local stateX = 0
	local stateZ = PITCH_CENTER_Z
	local velocityX = BALL_SPEED_X
	local velocityZ = BALL_SPEED_Z
	local leftZ = PITCH_CENTER_Z
	local rightZ = PITCH_CENTER_Z
	local bounceCount = 0

	local function playBeep(pitch)
		beep.PlaybackSpeed = pitch
		beep.TimePosition = 0
		beep:Play()
	end

	local function updateVisibility()
		local enabled = model:GetAttribute("PongEnabled") ~= false
		local transparency = enabled and 0 or 1
		leftPaddle.Transparency = transparency
		rightPaddle.Transparency = transparency
		ball.Transparency = transparency
		if not enabled and beep.IsPlaying then
			beep:Stop()
		end
		return enabled
	end

	updateVisibility()

	local connection
	connection = RunService.Heartbeat:Connect(function(dt)
		if not model.Parent or not folder.Parent then
			connection:Disconnect()
			return
		end

		if not updateVisibility() then
			return
		end

		dt = math.min(dt, 1 / 20)
		stateX += velocityX * dt
		stateZ += velocityZ * dt

		local upperZ = PITCH_CENTER_Z + Z_LIMIT
		local lowerZ = PITCH_CENTER_Z - Z_LIMIT
		if stateZ >= upperZ then
			stateZ = upperZ
			velocityZ = -math.abs(velocityZ)
			bounceCount += 1
			playBeep(bounceCount % 2 == 0 and 1.06 or 0.96)
		elseif stateZ <= lowerZ then
			stateZ = lowerZ
			velocityZ = math.abs(velocityZ)
			bounceCount += 1
			playBeep(bounceCount % 2 == 0 and 1.06 or 0.96)
		end

		if stateX >= BALL_X_LIMIT then
			stateX = BALL_X_LIMIT
			velocityX = -math.abs(velocityX)
			velocityZ = math.clamp(velocityZ + math.sin(bounceCount * 1.7) * 3.2, -20, 20)
			bounceCount += 1
			playBeep(1.13)
		elseif stateX <= -BALL_X_LIMIT then
			stateX = -BALL_X_LIMIT
			velocityX = math.abs(velocityX)
			velocityZ = math.clamp(velocityZ + math.cos(bounceCount * 1.4) * 3.2, -20, 20)
			bounceCount += 1
			playBeep(1.0)
		end

		local targetLeft = math.clamp(stateZ + math.sin(bounceCount * 0.8) * 2.5, lowerZ + 6, upperZ - 6)
		local targetRight = math.clamp(stateZ + math.cos(bounceCount * 0.7) * 2.5, lowerZ + 6, upperZ - 6)
		local alpha = math.clamp(PADDLE_FOLLOW_SPEED * dt, 0, 1)
		leftZ += (targetLeft - leftZ) * alpha
		rightZ += (targetRight - rightZ) * alpha

		ball.CFrame = localToWorld(rootCFrame, stateX, y + 0.02, stateZ)
		leftPaddle.CFrame = localToWorld(rootCFrame, LEFT_X, y, leftZ)
		rightPaddle.CFrame = localToWorld(rootCFrame, RIGHT_X, y, rightZ)
	end)

	model:SetAttribute("PongRuntimeAttached", true)
	model:SetAttribute("PongSoundStyle", "electronicpingshort")
	folder:SetAttribute("DecorativeOnly", true)
	folder:SetAttribute("Runtime", "ServerPreview")
	return folder
end

return Pong
