local FleetRig = {}

local SEGMENTS = {
	{"HumanoidRootPart", "Root", Vector3.new(3, 3, 2)},
	{"LowerTorso", "Pelvis", Vector3.new(6, 4, 4)},
	{"UpperTorso", "TorsoUpper", Vector3.new(9, 7, 5)},
	{"Head", "SensorHead", Vector3.new(4, 2, 3)},
	{"LeftUpperArm", "LeftUpperArm", Vector3.new(3, 6, 3)},
	{"LeftLowerArm", "LeftForearm", Vector3.new(3, 6, 3)},
	{"LeftHand", "LeftHand/Palm", Vector3.new(3, 3, 3)},
	{"RightUpperArm", "RightUpperArm", Vector3.new(3, 6, 3)},
	{"RightLowerArm", "RightForearm", Vector3.new(3, 6, 3)},
	{"RightHand", "RightHand/Palm", Vector3.new(3, 3, 3)},
	{"LeftUpperLeg", "LeftUpperLeg", Vector3.new(4, 7, 4)},
	{"LeftLowerLeg", "LeftLowerLeg", Vector3.new(4, 7, 4)},
	{"LeftFoot", "LeftFootMain", Vector3.new(5, 2, 5)},
	{"RightUpperLeg", "RightUpperLeg", Vector3.new(4, 7, 4)},
	{"RightLowerLeg", "RightLowerLeg", Vector3.new(4, 7, 4)},
	{"RightFoot", "RightFootMain", Vector3.new(5, 2, 5)},
}

local JOINTS = {
	{"Root", "HumanoidRootPart", "LowerTorso"},
	{"Waist", "LowerTorso", "UpperTorso"},
	{"Neck", "UpperTorso", "Head"},
	{"LeftShoulder", "UpperTorso", "LeftUpperArm"},
	{"LeftElbow", "LeftUpperArm", "LeftLowerArm"},
	{"LeftWrist", "LeftLowerArm", "LeftHand"},
	{"RightShoulder", "UpperTorso", "RightUpperArm"},
	{"RightElbow", "RightUpperArm", "RightLowerArm"},
	{"RightWrist", "RightLowerArm", "RightHand"},
	{"LeftHip", "LowerTorso", "LeftUpperLeg"},
	{"LeftKnee", "LeftUpperLeg", "LeftLowerLeg"},
	{"LeftAnkle", "LeftLowerLeg", "LeftFoot"},
	{"RightHip", "LowerTorso", "RightUpperLeg"},
	{"RightKnee", "RightUpperLeg", "RightLowerLeg"},
	{"RightAnkle", "RightLowerLeg", "RightFoot"},
}

local function sourcePart(model, path)
	if string.find(path, "/", 1, true) then
		local folderName, partName = string.match(path, "^([^/]+)/(.+)$")
		local folder = model:FindFirstChild(folderName, true)
		return folder and folder:FindFirstChild(partName, true)
	end
	return model:FindFirstChild(path, true)
end

local function controlPart(model, name, cf, size)
	local item = Instance.new("Part")
	item.Name = name
	item.CFrame = CFrame.new(cf.Position)
	item.Size = size
	item.Transparency = 1
	item.Anchored = false
	item.CanCollide = false
	item.CanTouch = false
	item.CanQuery = false
	item.Massless = true
	item.Parent = model
	return item
end

local function motor(parent, name, part0, part1)
	local item = Instance.new("Motor6D")
	item.Name = name
	item.Part0 = part0
	item.Part1 = part1
	item.C0 = part0.CFrame:ToObjectSpace(part1.CFrame)
	item.C1 = CFrame.identity
	item.Parent = parent
	return item
end

local function starts(name, prefix)
	return string.sub(name, 1, #prefix) == prefix
end

local function bodySegment(item)
	local name = item.Name
	local shield = item:FindFirstAncestor("RiotShield")
	if shield then return "RiotShieldControl" end
	local cannon = item:FindFirstAncestor("PulseCannon")
	if cannon then return "PulseCannonControl" end
	local net = item:FindFirstAncestor("ContainmentNetLauncher")
	if net then return "NetLauncherControl" end
	if item:FindFirstAncestor("LeftHand") then return "LeftHand" end
	if item:FindFirstAncestor("RightHand") then return "RightHand" end
	if starts(name, "LeftShoulder") or starts(name, "LeftUpperArm") then return "LeftUpperArm" end
	if starts(name, "LeftElbow") or starts(name, "LeftForearm") then return "LeftLowerArm" end
	if starts(name, "RightShoulder") or starts(name, "RightUpperArm") then return "RightUpperArm" end
	if starts(name, "RightElbow") or starts(name, "RightForearm") then return "RightLowerArm" end
	if starts(name, "LeftHip") or starts(name, "LeftUpperLeg") or starts(name, "LeftThigh") then return "LeftUpperLeg" end
	if starts(name, "LeftKnee") or starts(name, "LeftLowerLeg") or starts(name, "LeftShin") then return "LeftLowerLeg" end
	if starts(name, "LeftAnkle") or starts(name, "LeftFoot") or starts(name, "LeftToe") then return "LeftFoot" end
	if starts(name, "RightHip") or starts(name, "RightUpperLeg") or starts(name, "RightThigh") then return "RightUpperLeg" end
	if starts(name, "RightKnee") or starts(name, "RightLowerLeg") or starts(name, "RightShin") then return "RightLowerLeg" end
	if starts(name, "RightAnkle") or starts(name, "RightFoot") or starts(name, "RightToe") then return "RightFoot" end
	if string.find(name, "Head", 1, true) or string.find(name, "Sensor", 1, true) or string.find(name, "Brow", 1, true) then return "Head" end
	if string.find(name, "Pelvis", 1, true) or string.find(name, "HipPlate", 1, true) or string.find(name, "TorsoLower", 1, true) then return "LowerTorso" end
	return "UpperTorso"
end

local function equipmentControl(model, name, source, size)
	if not source then return nil end
	return controlPart(model, name, source:GetPivot(), size)
end

function FleetRig.Apply(model, options)
	options = options or {}
	if model:GetAttribute("GuardianFleetRigVersion") then
		return model:FindFirstChildOfClass("Humanoid")
	end

	local originals = {}
	for _, item in ipairs(model:GetDescendants()) do
		if item:IsA("BasePart") then table.insert(originals, item) end
	end

	local sources = {}
	for _, definition in ipairs(SEGMENTS) do
		local found = sourcePart(model, definition[2])
		assert(found and found:IsA("BasePart"), "Missing fleet rig source: " .. definition[2])
		sources[definition[1]] = found
	end

	local controls = {}
	for _, definition in ipairs(SEGMENTS) do
		controls[definition[1]] = controlPart(model, definition[1], sources[definition[1]].CFrame, definition[3])
	end

	local shieldModel = model:FindFirstChild("RiotShield", true)
	local cannonModel = model:FindFirstChild("PulseCannon", true)
	local netModel = model:FindFirstChild("ContainmentNetLauncher", true)
	controls.RiotShieldControl = equipmentControl(model, "RiotShieldControl", shieldModel, Vector3.new(4, 6, 2))
	controls.PulseCannonControl = equipmentControl(model, "PulseCannonControl", cannonModel, Vector3.new(4, 6, 4))
	controls.NetLauncherControl = equipmentControl(model, "NetLauncherControl", netModel, Vector3.new(5, 5, 3))

	for _, definition in ipairs(JOINTS) do
		motor(controls[definition[2]], definition[1], controls[definition[2]], controls[definition[3]])
	end
	if controls.RiotShieldControl then motor(controls.LeftLowerArm, "LeftShieldMount", controls.LeftLowerArm, controls.RiotShieldControl) end
	if controls.PulseCannonControl then motor(controls.RightLowerArm, "RightCannonMount", controls.RightLowerArm, controls.PulseCannonControl) end
	if controls.NetLauncherControl then motor(controls.UpperTorso, "NetLauncherMount", controls.UpperTorso, controls.NetLauncherControl) end

	local assigned = 0
	for _, item in ipairs(originals) do
		local segmentName = bodySegment(item)
		local segment = controls[segmentName]
		if segment then
			item.Anchored = false
			item.CanCollide = false
			item.Massless = true
			local weld = Instance.new("WeldConstraint")
			weld.Name = "FleetGeometryWeld"
			weld.Part0 = segment
			weld.Part1 = item
			weld.Parent = item
			assigned += 1
		end
	end

	local humanoid = Instance.new("Humanoid")
	humanoid.Name = "Humanoid"
	humanoid.AutoRotate = false
	humanoid.BreakJointsOnDeath = false
	humanoid.RequiresNeck = false
	humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	humanoid.Parent = model
	local animator = Instance.new("Animator")
	animator.Parent = humanoid

	controls.HumanoidRootPart.Anchored = options.AnchorRoot ~= false
	model.PrimaryPart = controls.HumanoidRootPart
	model:SetAttribute("GuardianFleetRigVersion", "1.0")
	model:SetAttribute("GuardianRigControlPartCount", 16)
	model:SetAttribute("GuardianRigMotorCount", 15 + (controls.RiotShieldControl and 1 or 0) + (controls.PulseCannonControl and 1 or 0) + (controls.NetLauncherControl and 1 or 0))
	model:SetAttribute("GuardianRigAssignedGeometryCount", assigned)
	model:SetAttribute("GuardianRigAxisForward", "-Z")
	model:SetAttribute("GuardianRigValidated", assigned == #originals)
	return humanoid
end

return FleetRig
