local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Workspace = game:GetService("Workspace")

local workshop = Workspace:WaitForChild("TrenchbornAssetWorkshop")
local packageFolder = ReplicatedStorage:WaitForChild("TrenchbornAssetWorkshop")

local guardianBuilder = require(packageFolder:WaitForChild("WardenShepherdGoldenMaster"))
local guardianDressing = require(packageFolder:WaitForChild("WardenShepherdDressing"))
local guardianGameplay = require(packageFolder:WaitForChild("WardenShepherdGameplay"))
local guardianConfig = require(packageFolder:WaitForChild("WardenShepherdGameplayConfig"))
local guardianRuntime = require(packageFolder:WaitForChild("WardenShepherdRuntimeController"))

local hospital = workshop:WaitForChild("LargeCity_CentralHospital_L3_GoldenMaster", 30)
if not hospital then
	warn("[Guardian Demo] Central Hospital did not appear; demo not started")
	return
end

-- The Hospital preview parents the model before all refinement/placement work is
-- complete. Wait for the review target marker so snapshots and spawn placement are
-- taken from the final Phase-4 geometry rather than the temporary origin state.
local readyDeadline = os.clock() + 15
repeat
	task.wait(0.05)
until (
	hospital.PrimaryPart
	and hospital:FindFirstChild("DestructionGroups")
	and workshop:GetAttribute("GoldenMasterReviewTarget") == hospital.Name
) or os.clock() >= readyDeadline

if not hospital.PrimaryPart then
	warn("[Guardian Demo] Hospital never reached a stable preview state")
	return
end

local existingRuntime = packageFolder:FindFirstChild("CentralHospitalGuardianDemo")
if existingRuntime then
	existingRuntime:Destroy()
end

local runtime = Instance.new("Folder")
runtime.Name = "CentralHospitalGuardianDemo"
runtime.Parent = packageFolder

local inputEvent = Instance.new("RemoteEvent")
inputEvent.Name = "Input"
inputEvent.Parent = runtime

local attackEvent = Instance.new("RemoteEvent")
attackEvent.Name = "Attack"
attackEvent.Parent = runtime

local resetEvent = Instance.new("RemoteEvent")
resetEvent.Name = "Reset"
resetEvent.Parent = runtime

local oldGuardian = workshop:FindFirstChild("PlayerGuardian_WardenI")
if oldGuardian then
	oldGuardian:Destroy()
end

local guardian = guardianBuilder.Build(workshop)
guardian.Name = "PlayerGuardian_WardenI"
guardianDressing.Apply(guardian)
guardian:SetAttribute("DemoControlled", true)
guardian:SetAttribute("DemoRole", "PlayerGuardian")

local gameplayApi = guardianGameplay.Attach(guardian, guardianConfig)
local animationApi = guardianRuntime.Attach(guardian, gameplayApi)

local hospitalPivot = hospital:GetPivot()
local guardianGroundY = hospitalPivot.Position.Y + 21
local guardianSpawnPosition = (hospitalPivot * CFrame.new(0, 0, -105)).Position
local guardianSpawnCFrame = CFrame.lookAt(
	Vector3.new(guardianSpawnPosition.X, guardianGroundY, guardianSpawnPosition.Z),
	Vector3.new(hospitalPivot.Position.X, guardianGroundY, hospitalPivot.Position.Z)
)
guardian:PivotTo(guardianSpawnCFrame)

-- WorkshopBootstrap can create a second static Warden. Remove it after bootstrap
-- settles so the player-controlled machine is the only Warden in this scene.
task.delay(2, function()
	local staticWarden = workshop:FindFirstChild("Warden_I_Shepherd_GoldenMaster")
	if staticWarden and staticWarden ~= guardian then
		staticWarden:Destroy()
	end
end)

local groupHealth = {
	D1_EmergencyCanopy = 5000,
	D2_DiagnosticPodium = 11000,
	D3_EmergencyWing = 8000,
	D4_SecondaryWing = 9000,
	D5_MainTowerLower = 12000,
	D6_MainTowerUpper = 11000,
	D7_HelipadRoofPlant = 8000,
}

local destructionGroups = hospital:WaitForChild("DestructionGroups")
local groupState = {}
local snapshots = {}
local totalMaxHealth = 0

local function snapshotPart(part)
	snapshots[part] = {
		CFrame = part.CFrame,
		Anchored = part.Anchored,
		CanCollide = part.CanCollide,
		CanTouch = part.CanTouch,
		CanQuery = part.CanQuery,
		Transparency = part.Transparency,
		Color = part.Color,
		Material = part.Material,
	}
end

for groupName, maxHealth in pairs(groupHealth) do
	local group = destructionGroups:FindFirstChild(groupName)
	if group then
		local parts = {}
		for _, descendant in ipairs(group:GetDescendants()) do
			if descendant:IsA("BasePart") then
				table.insert(parts, descendant)
				snapshotPart(descendant)
			end
		end
		groupState[groupName] = {
			Folder = group,
			Parts = parts,
			Health = maxHealth,
			MaxHealth = maxHealth,
			Destroyed = false,
		}
		group:SetAttribute("Health", maxHealth)
		group:SetAttribute("MaxHealth", maxHealth)
		group:SetAttribute("Destroyed", false)
		totalMaxHealth += maxHealth
	end
end

local function hospitalHealth()
	local total = 0
	for _, state in pairs(groupState) do
		total += state.Health
	end
	return total
end

local function updateRuntime(message, groupName)
	local health = hospitalHealth()
	hospital:SetAttribute("Health", health)
	hospital:SetAttribute("MaxHealth", totalMaxHealth)
	hospital:SetAttribute("Destroyed", health <= 0)
	runtime:SetAttribute("HospitalHealth", health)
	runtime:SetAttribute("HospitalMaxHealth", totalMaxHealth)
	runtime:SetAttribute("LastMessage", message or "")
	runtime:SetAttribute("LastHitGroup", groupName or "")
	runtime:SetAttribute("LastUpdate", (runtime:GetAttribute("LastUpdate") or 0) + 1)
end

local function planarDistance(a, b)
	local delta = a - b
	return Vector3.new(delta.X, 0, delta.Z).Magnitude
end

local function nearestTarget()
	local origin = guardian:GetPivot().Position
	local bestGroupName = nil
	local bestPart = nil
	local bestDistance = math.huge
	for groupName, state in pairs(groupState) do
		if not state.Destroyed then
			for _, part in ipairs(state.Parts) do
				if part.Parent and part.Transparency < 1 then
					local distance = planarDistance(part.Position, origin)
					if distance < bestDistance then
						bestDistance = distance
						bestGroupName = groupName
						bestPart = part
					end
				end
			end
		end
	end
	return bestGroupName, bestPart, bestDistance
end

local function impactFlash(position, heavy)
	local flash = Instance.new("Part")
	flash.Name = heavy and "GuardianSlamImpact" or "GuardianBatonImpact"
	flash.Shape = Enum.PartType.Ball
	flash.Size = heavy and Vector3.new(10, 10, 10) or Vector3.new(5, 5, 5)
	flash.CFrame = CFrame.new(position)
	flash.Anchored = true
	flash.CanCollide = false
	flash.CanTouch = false
	flash.CanQuery = false
	flash.CastShadow = false
	flash.Material = Enum.Material.Neon
	flash.Color = heavy and Color3.fromRGB(255, 197, 82) or Color3.fromRGB(92, 231, 151)
	flash.Transparency = 0.15
	flash.Parent = workshop
	TweenService:Create(
		flash,
		TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{Size = flash.Size * 2.2, Transparency = 1}
	):Play()
	Debris:AddItem(flash, 0.4)
end

local function breakGroup(groupName)
	local state = groupState[groupName]
	if not state or state.Destroyed then
		return
	end
	state.Destroyed = true
	state.Health = 0
	state.Folder:SetAttribute("Health", 0)
	state.Folder:SetAttribute("Destroyed", true)

	local guardianPosition = guardian:GetPivot().Position
	for index, part in ipairs(state.Parts) do
		if part.Parent then
			part.Anchored = false
			part.CanCollide = part.Material ~= Enum.Material.Glass
			local away = Vector3.new(part.Position.X - guardianPosition.X, 0, part.Position.Z - guardianPosition.Z)
			if away.Magnitude < 0.1 then
				away = guardian:GetPivot().LookVector
			else
				away = away.Unit
			end
			part.AssemblyLinearVelocity = away * (10 + (index % 6) * 2) + Vector3.new(0, 6 + (index % 5) * 1.5, 0)
			part.AssemblyAngularVelocity = Vector3.new(
				((index % 5) - 2) * 0.35,
				((index % 7) - 3) * 0.28,
				((index % 3) - 1) * 0.45
			)
		end
	end
end

local function damageGroup(groupName, amount, hitPart, heavy)
	local state = groupState[groupName]
	if not state or state.Destroyed then
		return false
	end
	state.Health = math.max(0, state.Health - amount)
	state.Folder:SetAttribute("Health", state.Health)
	local hitPosition = hitPart and hitPart.Position or hospital:GetPivot().Position
	impactFlash(hitPosition, heavy)

	if state.Health <= 0 then
		breakGroup(groupName)
		updateRuntime("SEKTOR ZERSTÖRT: " .. groupName, groupName)
	else
		updateRuntime(string.format("TREFFER %s  |  %d HP", groupName, state.Health), groupName)
	end
	return true
end

local function resetHospital()
	for _, state in pairs(groupState) do
		state.Health = state.MaxHealth
		state.Destroyed = false
		state.Folder:SetAttribute("Health", state.MaxHealth)
		state.Folder:SetAttribute("Destroyed", false)
		for _, part in ipairs(state.Parts) do
			local snapshot = snapshots[part]
			if snapshot and part.Parent then
				part.Anchored = true
				part.AssemblyLinearVelocity = Vector3.zero
				part.AssemblyAngularVelocity = Vector3.zero
				part.CFrame = snapshot.CFrame
				part.Transparency = snapshot.Transparency
				part.Color = snapshot.Color
				part.Material = snapshot.Material
				part.CanCollide = snapshot.CanCollide
				part.CanTouch = snapshot.CanTouch
				part.CanQuery = snapshot.CanQuery
				part.Anchored = snapshot.Anchored
			end
		end
	end
	guardian:PivotTo(guardianSpawnCFrame)
	animationApi.PlayAnimation("Idle")
	updateRuntime("SPITAL ZURÜCKGESETZT", "")
end

local controllerPlayer = nil
local inputState = {Forward = 0, Strafe = 0, Turn = 0, Sprint = false}
local lastAttack = {Baton = 0, Slam = 0}
local animationLockUntil = 0
local locomotionAnimation = "Idle"

local function playLocomotion(name)
	if os.clock() < animationLockUntil or name == locomotionAnimation then
		return
	end
	locomotionAnimation = name
	animationApi.PlayAnimation(name)
end

local function hideCharacter(character)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		humanoid.WalkSpeed = 0
		humanoid.JumpPower = 0
		humanoid.AutoRotate = false
	end
	local root = character:FindFirstChild("HumanoidRootPart")
	if root then root.Anchored = true end
	for _, descendant in ipairs(character:GetDescendants()) do
		if descendant:IsA("BasePart") then
			descendant.Transparency = 1
			descendant.CanCollide = false
		elseif descendant:IsA("Decal") then
			descendant.Transparency = 1
		end
	end
end

local function setController(player)
	if controllerPlayer then return end
	controllerPlayer = player
	runtime:SetAttribute("ControllerUserId", player.UserId)
	if player.Character then hideCharacter(player.Character) end
	player.CharacterAdded:Connect(hideCharacter)
end

for _, player in ipairs(Players:GetPlayers()) do
	setController(player)
	if controllerPlayer then break end
end
Players.PlayerAdded:Connect(setController)

inputEvent.OnServerEvent:Connect(function(player, payload)
	if player ~= controllerPlayer or typeof(payload) ~= "table" then return end
	inputState.Forward = math.clamp(tonumber(payload.Forward) or 0, -1, 1)
	inputState.Strafe = math.clamp(tonumber(payload.Strafe) or 0, -1, 1)
	inputState.Turn = math.clamp(tonumber(payload.Turn) or 0, -1, 1)
	inputState.Sprint = payload.Sprint == true
end)

attackEvent.OnServerEvent:Connect(function(player, attackName)
	if player ~= controllerPlayer then return end
	local now = os.clock()
	local config
	if attackName == "Slam" then
		config = {Damage = 12000, Range = 52, Cooldown = 2.4, Heavy = true, Animation = "GroundSlam", Lock = 1.35}
	else
		attackName = "Baton"
		config = {Damage = 7000, Range = 38, Cooldown = 0.65, Heavy = false, Animation = "ShockBaton", Lock = 0.9}
	end
	if now - (lastAttack[attackName] or 0) < config.Cooldown then return end
	lastAttack[attackName] = now
	animationLockUntil = now + config.Lock
	locomotionAnimation = ""
	animationApi.PlayAnimation(config.Animation)

	local groupName, hitPart, distance = nearestTarget()
	if not groupName or not hitPart then
		updateRuntime("SPITAL BEREITS ZERSTÖRT", "")
		return
	end
	if distance > config.Range then
		updateRuntime(string.format("ZU WEIT WEG  |  %.0f / %.0f", distance, config.Range), groupName)
		return
	end
	damageGroup(groupName, config.Damage, hitPart, config.Heavy)
end)

resetEvent.OnServerEvent:Connect(function(player)
	if player == controllerPlayer then resetHospital() end
end)

RunService.Heartbeat:Connect(function(dt)
	if not guardian.Parent then return end
	local pivot = guardian:GetPivot()
	local turn = inputState.Turn
	if math.abs(turn) > 0.01 then
		pivot *= CFrame.Angles(0, math.rad(-turn * 82 * dt), 0)
	end

	local move = pivot.LookVector * inputState.Forward + pivot.RightVector * inputState.Strafe
	if move.Magnitude > 1 then move = move.Unit end
	if move.Magnitude > 0.01 then
		local speed = inputState.Sprint and 38 or 24
		pivot += move * speed * dt
	end

	local fixedPosition = Vector3.new(pivot.Position.X, guardianGroundY, pivot.Position.Z)
	guardian:PivotTo(CFrame.fromMatrix(fixedPosition, pivot.XVector, pivot.YVector, pivot.ZVector))

	if os.clock() >= animationLockUntil then
		if inputState.Forward < -0.1 then
			playLocomotion("WalkBackward")
		elseif move.Magnitude > 0.1 then
			playLocomotion(inputState.Sprint and "Run" or "Walk")
		elseif turn > 0.1 then
			playLocomotion("TurnRight")
		elseif turn < -0.1 then
			playLocomotion("TurnLeft")
		else
			playLocomotion("Idle")
		end
	end
end)

runtime:SetAttribute("GuardianName", "WARDEN-I")
runtime:SetAttribute("Controls", "W/S move | A/D turn | Q/E strafe | Shift sprint | Left Click/F baton | Space slam | R reset")
workshop:SetAttribute("GuardianDemoMode", true)
workshop:SetAttribute("QualityStatus", "Phase4_GuardianDestructionSandbox")
workshop:SetAttribute("ReviewScene", "CentralHospital_PlayerGuardianDemolition")
updateRuntime("WARDEN-I BEREIT", "")
animationApi.PlayAnimation("Idle")

print("[Trenchborn Asset Workshop] WARDEN-I playable demolition sandbox ready")
