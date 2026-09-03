local FleetRig = {}

local SEGMENTS = {
	{"HumanoidRootPart", "Root", Vector3.new(3, 3, 2)},
	{"LowerTorso", "Pelvis", Vector3.new(6, 4, 4)},
	{"UpperTorso", "TorsoUpper", Vector3.new(9, 7, 5)},
	{"Head", "SensorHead", Vector3.new(4, 2, 3)},
	{"LeftUpperArm", "LeftShoulderBearingDrum", Vector3.new(3, 6, 3)},
	{"LeftLowerArm", "LeftElbowBearing", Vector3.new(3, 6, 3)},
	{"LeftHand", "LeftHand/Palm", Vector3.new(3, 3, 3)},
	{"RightUpperArm", "RightShoulderBearingDrum", Vector3.new(3, 6, 3)},
	{"RightLowerArm", "RightElbowBearing", Vector3.new(3, 6, 3)},
	{"RightHand", "RightHand/Palm", Vector3.new(3, 3, 3)},
	{"LeftUpperLeg", "LeftHipBearing", Vector3.new(4, 7, 4)},
	{"LeftLowerLeg", "LeftKneeBearing", Vector3.new(4, 7, 4)},
	{"LeftFoot", "LeftAnkle", Vector3.new(5, 2, 5)},
	{"RightUpperLeg", "RightHipBearing", Vector3.new(4, 7, 4)},
	{"RightLowerLeg", "RightKneeBearing", Vector3.new(4, 7, 4)},
	{"RightFoot", "RightAnkle", Vector3.new(5, 2, 5)},
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
	local baton = item:FindFirstAncestor("ShockBaton")
	if baton then return "LeftHand" end
	local leftIon = item:FindFirstAncestor("LeftIonCannon")
	if leftIon then return "LeftLowerArm" end
	local rightIon = item:FindFirstAncestor("RightIonCannon")
	if rightIon then return "RightLowerArm" end
	local missilePod = item:FindFirstAncestor("ShoulderMissilePod")
	if missilePod then return "UpperTorso" end
	local directionalAegis = item:FindFirstAncestor("DirectionalAegis")
	if directionalAegis then return "UpperTorso" end
	local railCannon = item:FindFirstAncestor("HeavyRailCannon")
	if railCannon then return "HeavyRailCannonControl" end
	local shieldTower = item:FindFirstAncestor("DistrictShieldTower")
	if shieldTower then return "UpperTorso" end
	local districtProjector = item:FindFirstAncestor("DistrictShieldProjectors")
	if districtProjector then return "UpperTorso" end
	local leftSiegeFist = item:FindFirstAncestor("LeftSiegeFist")
	if leftSiegeFist then return "LeftHand" end
	local rightSiegeFist = item:FindFirstAncestor("RightSiegeFist")
	if rightSiegeFist then return "RightHand" end
	local apexLance = item:FindFirstAncestor("ApexLance")
	if apexLance then return "ApexLanceControl" end
	for _, side in ipairs({"Left", "Right"}) do
		for _, position in ipairs({"Inner", "Outer", "Lower"}) do
			local droneName = side .. "Drone" .. position
			if item:FindFirstAncestor(droneName) then return droneName .. "Control" end
		end
		if item:FindFirstAncestor(side .. "DroneWing") then return side .. "DroneWingRootControl" end
	end
	if item:FindFirstAncestor("LeftHand") then return "LeftHand" end
	if item:FindFirstAncestor("RightHand") then return "RightHand" end
	if name == "ForearmHardpointLeft" then return "LeftLowerArm" end
	if name == "ForearmHardpointRight" then return "RightLowerArm" end
	if starts(name, "LeftShoulder") or starts(name, "LeftUpperArm") then return "LeftUpperArm" end
	if starts(name, "LeftElbow") or starts(name, "LeftForearm") then return "LeftLowerArm" end
	if starts(name, "RightShoulder") or starts(name, "RightUpperArm") then return "RightUpperArm" end
	if starts(name, "RightElbow") or starts(name, "RightForearm") then return "RightLowerArm" end
	if starts(name, "LeftHip") or starts(name, "LeftUpperLeg") or starts(name, "LeftThigh") then return "LeftUpperLeg" end
	if starts(name, "LeftKnee") or starts(name, "LeftLowerLeg") or starts(name, "LeftShin") or starts(name, "LeftRearHydraulic") then return "LeftLowerLeg" end
	if starts(name, "LeftAnkle") or starts(name, "LeftFoot") or starts(name, "LeftToe") then return "LeftFoot" end
	if starts(name, "RightHip") or starts(name, "RightUpperLeg") or starts(name, "RightThigh") then return "RightUpperLeg" end
	if starts(name, "RightKnee") or starts(name, "RightLowerLeg") or starts(name, "RightShin") or starts(name, "RightRearHydraulic") then return "RightLowerLeg" end
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
	local railCannonModel = model:FindFirstChild("HeavyRailCannon", true)
	local apexLanceModel = model:FindFirstChild("ApexLance", true)
	local droneWings = model:FindFirstChild("HunterDroneWings", true)
	controls.RiotShieldControl = equipmentControl(model, "RiotShieldControl", shieldModel, Vector3.new(4, 6, 2))
	controls.PulseCannonControl = equipmentControl(model, "PulseCannonControl", cannonModel, Vector3.new(4, 6, 4))
	controls.NetLauncherControl = equipmentControl(model, "NetLauncherControl", netModel, Vector3.new(5, 5, 3))
	controls.HeavyRailCannonInertiaControl = equipmentControl(model, "HeavyRailCannonInertiaControl", railCannonModel, Vector3.new(6, 6, 8))
	controls.HeavyRailCannonControl = equipmentControl(model, "HeavyRailCannonControl", railCannonModel, Vector3.new(6, 6, 8))
	controls.ApexLanceControl = equipmentControl(model, "ApexLanceControl", apexLanceModel, Vector3.new(5, 9, 5))
	for _, side in ipairs({"Left", "Right"}) do
		local wing = droneWings and droneWings:FindFirstChild(side .. "DroneWing")
		controls[side .. "DroneWingRootControl"] = equipmentControl(
			model,
			side .. "DroneWingRootControl",
			wing,
			Vector3.new(4, 5, 4)
		)
		for _, position in ipairs({"Inner", "Outer", "Lower"}) do
			local drone = wing and wing:FindFirstChild(side .. "Drone" .. position)
			controls[side .. "Drone" .. position .. "Control"] = equipmentControl(
				model,
				side .. "Drone" .. position .. "Control",
				drone,
				Vector3.new(5, 4, 6)
			)
		end
	end

	for _, definition in ipairs(JOINTS) do
		motor(controls[definition[2]], definition[1], controls[definition[2]], controls[definition[3]])
	end
	if controls.RiotShieldControl then motor(controls.LeftLowerArm, "LeftShieldMount", controls.LeftLowerArm, controls.RiotShieldControl) end
	if controls.PulseCannonControl then motor(controls.RightLowerArm, "RightCannonMount", controls.RightLowerArm, controls.PulseCannonControl) end
	if controls.NetLauncherControl then motor(controls.UpperTorso, "NetLauncherMount", controls.UpperTorso, controls.NetLauncherControl) end
	if controls.HeavyRailCannonControl then
		motor(controls.UpperTorso, "HeavyRailCannonInertia", controls.UpperTorso, controls.HeavyRailCannonInertiaControl)
		motor(controls.HeavyRailCannonInertiaControl, "HeavyRailCannonMount", controls.HeavyRailCannonInertiaControl, controls.HeavyRailCannonControl)
	end
	if controls.ApexLanceControl then
		motor(controls.LeftLowerArm, "ApexLanceMount", controls.LeftLowerArm, controls.ApexLanceControl)
	end
	for _, side in ipairs({"Left", "Right"}) do
		local wingControl = controls[side .. "DroneWingRootControl"]
		if wingControl then
			motor(controls.UpperTorso, side .. "DroneWingRootMount", controls.UpperTorso, wingControl)
			for _, position in ipairs({"Inner", "Outer", "Lower"}) do
				local droneControl = controls[side .. "Drone" .. position .. "Control"]
				if droneControl then
					motor(wingControl, side .. "Drone" .. position .. "Mount", wingControl, droneControl)
				end
			end
		end
	end

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
	local controlPartCount = 0
	for _, control in pairs(controls) do
		if control then controlPartCount += 1 end
	end
	model:SetAttribute("GuardianRigControlPartCount", controlPartCount)
	local sovereignMotorCount = (controls.ApexLanceControl and 1 or 0)
	for _, side in ipairs({"Left", "Right"}) do
		if controls[side .. "DroneWingRootControl"] then sovereignMotorCount += 1 end
		for _, position in ipairs({"Inner", "Outer", "Lower"}) do
			if controls[side .. "Drone" .. position .. "Control"] then sovereignMotorCount += 1 end
		end
	end
	model:SetAttribute("GuardianRigMotorCount", 15 + (controls.RiotShieldControl and 1 or 0) + (controls.PulseCannonControl and 1 or 0) + (controls.NetLauncherControl and 1 or 0) + (controls.HeavyRailCannonControl and 2 or 0) + sovereignMotorCount)
	model:SetAttribute("GuardianRigAssignedGeometryCount", assigned)
	model:SetAttribute("GuardianRigAxisForward", "-Z")
	model:SetAttribute("GuardianRigValidated", assigned == #originals)
	return humanoid
end

return FleetRig
