local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local workshop = workspace:WaitForChild("TrenchbornAssetWorkshop")
local packageFolder = ReplicatedStorage:WaitForChild("TrenchbornAssetWorkshop")
local blockout = require(packageFolder:WaitForChild("KaijuEvolutionBlockout"))
local stageOneRig = require(packageFolder:WaitForChild("KaijuStageOneRig"))
local combatModule = require(packageFolder:WaitForChild("KaijuStageOneCombat"))

-- The retired bootstrap no longer creates Guardian models or controls.
for _, child in ipairs(workshop:GetChildren()) do child:Destroy() end
local origin = CFrame.new(0, 0, 145)
local preview = blockout.BuildStage(workshop, 1, origin)
local display = preview:FindFirstChild("Stage_1_Primal_Beast")
assert(display and display:IsA("Model"), "Stage 1 model missing")
-- Place the unrigged geometry by its soles once. Never adjust the live rig
-- against terrain while the humanoid is running or preparing a jump.
local soleBottom=math.huge
for _,side in ipairs({"Left","Right"}) do
	local sole=display:FindFirstChild(side.."ForefootCoreY")
	if sole and sole:IsA("BasePart") then
		local bottom=sole.CFrame:PointToWorldSpace(Vector3.new(0,-sole.Size.Y/2,0))
		soleBottom=math.min(soleBottom,bottom.Y)
	end
end
if soleBottom<math.huge then
	display:PivotTo(display:GetPivot()+Vector3.new(0,origin.Position.Y-soleBottom,0))
end
local template = display:Clone() -- Unrigged geometry for every respawn.
local pivotFromGround = origin:ToObjectSpace(template:GetPivot())
stageOneRig.Attach(display)
preview:SetAttribute("PipelinePhase", 6)
preview:SetAttribute("QualityGateC", "Pending")
preview:SetAttribute("Purpose", "Stage 1 player control review")

local function equip(player, character)
	local humanoid = character:WaitForChild("Humanoid", 15)
	local root = character:WaitForChild("HumanoidRootPart", 15)
	if not humanoid or not root or player.Character ~= character then return end
	if character:GetAttribute("KaijuStageOneEquipped") then return end
	character:SetAttribute("KaijuStageOneEquipped", true)
	-- Finish avatar scaling before calculating the ground-to-root offset.
	local deadline = os.clock() + 10
	while not player:HasAppearanceLoaded() and os.clock() < deadline do
		if player.Character ~= character or not character.Parent then return end
		task.wait(0.1)
	end
	if player.Character ~= character or not character.Parent then return end

	-- Retain Roblox's controller for keyboard, controller, touch, gravity and
	-- respawning. Only its visible avatar is replaced.
	local kaiju = template:Clone()
	kaiju.Name = "Stage_1_Primal_Beast"
	local function hideAvatar(item)
		if item:IsDescendantOf(kaiju) then return end
		if item:IsA("BasePart") then
			item.Transparency = 1
			item.CastShadow = false
		elseif item:IsA("Decal") then
			item.Transparency = 1
		elseif item:IsA("ParticleEmitter") or item:IsA("Trail") then
			item.Enabled = false
		elseif item:IsA("Script") or item:IsA("LocalScript") then
			if item.Name == "Animate" then item.Enabled = false end
		end
	end
	for _, item in ipairs(character:GetDescendants()) do hideAvatar(item) end
	local added = character.DescendantAdded:Connect(hideAvatar)
	local appearance = player.CharacterAppearanceLoaded:Connect(function(loaded)
		if loaded == character then
			for _, item in ipairs(character:GetDescendants()) do hideAvatar(item) end
		end
	end)

	local height = humanoid.HipHeight + root.Size.Y/2
	if humanoid.RigType == Enum.HumanoidRigType.R6 then
		local leg = character:FindFirstChild("Left Leg")
		if leg then height = height + leg.Size.Y end
	end
	local ground = root.CFrame * CFrame.new(0, -height, 0)
	kaiju:PivotTo(ground * pivotFromGround)
	kaiju.Parent = character
	combatModule.BuildRange(player, ground, character)
	local combat = combatModule.Attach(kaiju, root, humanoid, height)
	local rig = stageOneRig.Attach(kaiju, root, humanoid, combat)
	local reactionTestConnection
	if game:GetService("RunService"):IsStudio() then
		local testRemote=Instance.new("RemoteEvent");testRemote.Name="TestReaction";testRemote.Parent=kaiju
		local lastTest=-math.huge
		reactionTestConnection=testRemote.OnServerEvent:Connect(function(sender,command)
			if sender~=player or player.Character~=character or humanoid.Health<=0 or os.clock()-lastTest<0.3 then return end
			if command~="Hit" and command~="Heavy Hit" and command~="Defeat" and command~="Heal" then return end
			lastTest=os.clock()
			if command=="Heal" then humanoid.Health=humanoid.MaxHealth
			elseif command=="Defeat" then humanoid.Health=0
			else humanoid.Health=math.max(0,humanoid.Health-humanoid.MaxHealth*(command=="Hit" and 0.08 or 0.25)) end
		end)
	end
	local runRemote=Instance.new("RemoteEvent")
	runRemote.Name="SetRunning";runRemote.Parent=kaiju
	local runConnection=runRemote.OnServerEvent:Connect(function(sender,enabled)
		if sender~=player or player.Character~=character or type(enabled)~="boolean" then return end
		rig.SetRunning(enabled)
	end)
	local areaRemote=Instance.new("RemoteEvent")
	areaRemote.Name="RequestArea";areaRemote.Parent=kaiju
	local lastArea=-math.huge
	local areaConnection=areaRemote.OnServerEvent:Connect(function(sender)
		if sender~=player or player.Character~=character or os.clock()-lastArea<0.2 then return end
		lastArea=os.clock();rig.RequestArea()
	end)
	local focusRemote=Instance.new("RemoteEvent")
	focusRemote.Name="RequestFocus";focusRemote.Parent=kaiju
	local lastFocus=-math.huge
	local focusConnection=focusRemote.OnServerEvent:Connect(function(sender)
		if sender~=player or player.Character~=character or os.clock()-lastFocus<0.2 then return end
		lastFocus=os.clock();rig.RequestFocus()
	end)
	local remote = Instance.new("RemoteEvent")
	remote.Name = "RequestAttack"
	remote.Parent = kaiju
	local lastAttackRequest = -math.huge
	local jumpRemote=Instance.new("RemoteEvent")
	jumpRemote.Name="RequestJump"
	jumpRemote.Parent=kaiju
	local lastJumpRequest=-math.huge
	local function validDirection(direction)
		return typeof(direction)=="Vector3" and direction.X==direction.X and direction.Y==direction.Y
			and direction.Z==direction.Z and direction.Magnitude<=1.05 and math.abs(direction.Y)<=0.1
	end
	local jumpConnection=jumpRemote.OnServerEvent:Connect(function(sender,direction)
		if sender~=player or player.Character~=character then return end
		if direction~=nil and not validDirection(direction) then return end
		local now=os.clock()
		if now-lastJumpRequest<0.15 then return end
		lastJumpRequest=now
		rig.RequestJump(direction)
	end)
	local steerRemote=Instance.new("RemoteEvent")
	steerRemote.Name="SteerJump"
	steerRemote.Parent=kaiju
	local lastSteer=-math.huge
	local steerConnection=steerRemote.OnServerEvent:Connect(function(sender,direction)
		if sender~=player or player.Character~=character or not validDirection(direction) then return end
		local now=os.clock()
		if now-lastSteer<0.06 then return end
		lastSteer=now
		rig.SetAirDirection(direction)
	end)
	local attackConnection = remote.OnServerEvent:Connect(function(sender)
		if sender ~= player or player.Character ~= character then return end
		local now = os.clock()
		if now-lastAttackRequest < 0.12 then return end
		lastAttackRequest = now
		rig.RequestAttack()
	end)
	kaiju:SetAttribute("GeometryAmendmentReview", "ApprovedByUser")
	kaiju:SetAttribute("ControlledBy", player.UserId)

	-- Torso collision prevents the upper body passing through walls.
	-- Feet and tail remain visual until the combat hitbox pass.
	local collider = Instance.new("Part")
	collider.Name = "KaijuBodyCollider"
	collider.Size = Vector3.new(11, 20, 7) * kaiju:GetScale()
	collider.CFrame = ground * CFrame.new(0, collider.Size.Y/2 + 3, 0)
	collider.Transparency, collider.Massless = 1, true
	collider.CanCollide, collider.CanTouch = true, false
	collider.Parent = character
	local weld = Instance.new("WeldConstraint")
	weld.Part0, weld.Part1, weld.Parent = root, collider, collider

	humanoid.WalkSpeed = 10
	humanoid.AutoRotate = true
	humanoid.CameraOffset = Vector3.new(0, 12, 0)
	humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	-- The scripted jump owns takeoff timing; disable the default instant jump.
	humanoid.UseJumpPower, humanoid.JumpPower = true, 0
	humanoid.AutoJumpEnabled = false
	player.CameraMinZoomDistance = 42
	player.CameraMaxZoomDistance = 110
	if display and display.Parent then display:Destroy() end

	character.Destroying:Once(function()
		if reactionTestConnection then reactionTestConnection:Disconnect() end
		runConnection:Disconnect()
		areaConnection:Disconnect()
		focusConnection:Disconnect()
		steerConnection:Disconnect()
		jumpConnection:Disconnect()
		attackConnection:Disconnect()
		added:Disconnect()
		appearance:Disconnect()
		rig.Stop()
	end)
end

local function connectPlayer(player)
	-- Persist the input script through respawns in its own ScreenGui.
	task.spawn(function()
		local gui = player:WaitForChild("PlayerGui")
		if not gui:FindFirstChild("KaijuStageOneInput") then
			local container = Instance.new("ScreenGui")
			container.Name = "KaijuStageOneInput"
			container.ResetOnSpawn = false
			local controls = packageFolder:WaitForChild("KaijuStageOneControls"):Clone()
			controls.Parent = container
			container.Parent = gui
		end
	end)
	player.CharacterAdded:Connect(function(character) task.spawn(equip, player, character) end)
	if player.Character then task.spawn(equip, player, player.Character) end
end
Players.PlayerAdded:Connect(connectPlayer)
Players.PlayerRemoving:Connect(combatModule.RemoveRange)
for _, player in ipairs(Players:GetPlayers()) do connectPlayer(player) end
workshop:SetAttribute("CurrentAsset", "Kaiju Stage 1 - Primal Beast")
workshop:SetAttribute("CurrentPhase", 6)
workshop:SetAttribute("QualityStatus", "Phase6_Stage1PlayerControlReview")
print("[Kaiju] Play: control Stage 1 with Roblox movement. Guardian controls retired.")
