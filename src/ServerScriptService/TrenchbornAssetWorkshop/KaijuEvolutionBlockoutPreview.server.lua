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
	local remote = Instance.new("RemoteEvent")
	remote.Name = "RequestAttack"
	remote.Parent = kaiju
	local lastAttackRequest = -math.huge
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

	humanoid.WalkSpeed = 5
	humanoid.AutoRotate = true
	humanoid.CameraOffset = Vector3.new(0, 12, 0)
	humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	-- Walking is the current review scope; jumping has no reviewed pose yet.
	humanoid.UseJumpPower, humanoid.JumpPower = true, 0
	humanoid.AutoJumpEnabled = false
	player.CameraMinZoomDistance = 42
	player.CameraMaxZoomDistance = 110
	if display and display.Parent then display:Destroy() end

	character.Destroying:Once(function()
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
