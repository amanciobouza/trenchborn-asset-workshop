local Validator = {}

local SEVERITY_ORDER = { BLOCKER = 1, WARNING = 2, INFO = 3 }

local function corners(part)
	local half = part.Size * 0.5
	local result = {}
	for _, x in ipairs({-half.X, half.X}) do
		for _, y in ipairs({-half.Y, half.Y}) do
			for _, z in ipairs({-half.Z, half.Z}) do
				table.insert(result, part.CFrame:PointToWorldSpace(Vector3.new(x, y, z)))
			end
		end
	end
	return result
end

local function minimumY(part)
	local value = math.huge
	for _, point in ipairs(corners(part)) do
		value = math.min(value, point.Y)
	end
	return value
end

local function visibleParts(model)
	local parts = {}
	for _, item in ipairs(model:GetDescendants()) do
		if item:IsA("BasePart") and item.Transparency < 1 and not item:FindFirstAncestor("Hitboxes_GeometryReviewOnly") then
			table.insert(parts, item)
		end
	end
	return parts
end

local function connectedParts(model, root)
	local adjacency = {}
	for _, item in ipairs(model:GetDescendants()) do
		if item:IsA("BasePart") then
			adjacency[item] = adjacency[item] or {}
		elseif item:IsA("JointInstance") or item:IsA("WeldConstraint") then
			local part0, part1 = item.Part0, item.Part1
			if part0 and part1 and part0:IsDescendantOf(model) and part1:IsDescendantOf(model) then
				adjacency[part0] = adjacency[part0] or {}
				adjacency[part1] = adjacency[part1] or {}
				table.insert(adjacency[part0], part1)
				table.insert(adjacency[part1], part0)
			end
		end
	end

	local reached, queue = {}, {root}
	reached[root] = true
	local cursor = 1
	while cursor <= #queue do
		local current = queue[cursor]
		cursor += 1
		for _, neighbor in ipairs(adjacency[current] or {}) do
			if not reached[neighbor] then
				reached[neighbor] = true
				table.insert(queue, neighbor)
			end
		end
	end
	return reached
end

local function clearMarkers(model)
	local old = model:FindFirstChild("QualityGateBReviewMarkers")
	if old then old:Destroy() end
end

local function createMarkers(model, findings)
	clearMarkers(model)
	local folder = Instance.new("Folder")
	folder.Name = "QualityGateBReviewMarkers"
	folder.Archivable = false
	folder.Parent = model
	local marked = {}
	for _, finding in ipairs(findings) do
		local subject = finding.Subject
		if subject and subject:IsA("BasePart") and not marked[subject] then
			marked[subject] = true
			local highlight = Instance.new("Highlight")
			highlight.Name = finding.Severity .. "_" .. finding.Id:gsub("[^%w_]", "_")
			highlight.Adornee = subject
			highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			highlight.FillColor = finding.Severity == "BLOCKER" and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(255, 190, 50)
			highlight.FillTransparency = 0.55
			highlight.OutlineTransparency = 0
			highlight.Parent = folder
		end
	end
end

function Validator.Review(model, specification, profile, options)
	options = options or {}
	local findings = {}
	local function add(id, severity, message, subject)
		table.insert(findings, {Id = id, Severity = severity, Message = message, Subject = subject})
	end
	local function requireCondition(ok, id, message, subject)
		if not ok then add(id, "BLOCKER", message, subject) end
	end

	requireCondition(model.Name == profile.ModelName, "identity.model-name", "Model name does not match the review profile.", model.PrimaryPart)
	requireCondition(model:GetAttribute("AssetId") == profile.ExpectedAssetId, "identity.asset-id", "AssetId does not match the review profile.", model.PrimaryPart)
	requireCondition(model:GetAttribute("PipelinePhase") == profile.ExpectedPipelinePhase, "pipeline.phase", "The model is not in the expected pipeline phase.", model.PrimaryPart)
	requireCondition(model:GetAttribute("QualityGateB") ~= "Approved", "pipeline.gate-not-preapproved", "Quality Gate B must not be approved before this review.", model.PrimaryPart)
	requireCondition(model.PrimaryPart ~= nil, "rig.primary-part", "PrimaryPart is missing.", nil)

	for _, name in ipairs(profile.RequiredRootParts) do
		requireCondition(model:FindFirstChild(name) ~= nil, "rig.required-part", name .. " is missing.", nil)
	end

	local geometry = model:FindFirstChild("BodyGeometry")
	requireCondition(geometry ~= nil, "geometry.folder", "BodyGeometry is missing.", nil)
	local dorsalFolder = geometry and geometry:FindFirstChild("DorsalPlates")
	local expectedDorsals = specification.Anatomy.DorsalShieldCount
	local actualDorsals = dorsalFolder and #dorsalFolder:GetChildren() or 0
	requireCondition(actualDorsals == expectedDorsals, "anatomy.dorsal-count", string.format("Expected %d dorsal shields, found %d.", expectedDorsals, actualDorsals), nil)

	for _, side in ipairs({"Left", "Right"}) do
		local foot = geometry and geometry:FindFirstChild(side .. "FootGeometry")
		requireCondition(foot ~= nil, "anatomy.foot-geometry", side .. "FootGeometry is missing.", nil)
		if foot then
			for index = 1, specification.Anatomy.ForwardClawsPerFoot do
				requireCondition(foot:FindFirstChild("ForwardClaw_" .. index) ~= nil, "anatomy.forward-claw", side .. " forward claw " .. index .. " is missing.", nil)
			end
			requireCondition(foot:FindFirstChild("RearClaw") ~= nil, "anatomy.rear-claw", side .. " rear claw is missing.", nil)
		end
	end

	local visible = visibleParts(model)
	local hitboxCount, permanentEffects, perPartScripts = 0, 0, 0
	for _, item in ipairs(model:GetDescendants()) do
		if item:IsA("BasePart") and item:FindFirstAncestor("Hitboxes_GeometryReviewOnly") then hitboxCount += 1 end
		if item:IsA("Light") or item:IsA("ParticleEmitter") then permanentEffects += 1 end
		if (item:IsA("Script") or item:IsA("LocalScript") or item:IsA("ModuleScript")) and item.Parent and item.Parent:IsA("BasePart") then perPartScripts += 1 end
	end
	requireCondition(#visible <= specification.PerformanceBudget.MaxVisibleParts, "budget.visible-parts", string.format("Visible part budget exceeded: %d/%d.", #visible, specification.PerformanceBudget.MaxVisibleParts), nil)
	requireCondition(hitboxCount <= specification.PerformanceBudget.MaxGameplayHitboxes, "budget.hitboxes", string.format("Hitbox budget exceeded: %d/%d.", hitboxCount, specification.PerformanceBudget.MaxGameplayHitboxes), nil)
	requireCondition(permanentEffects == 0, "budget.permanent-effects", "Lights or particle emitters are present in the geometry-only model.", nil)
	requireCondition(perPartScripts == 0, "budget.per-part-scripts", "A script is parented to a model part.", nil)

	local modelMinY = math.huge
	for _, part in ipairs(visible) do modelMinY = math.min(modelMinY, minimumY(part)) end
	local expectedGroundY = model:GetPivot().Y - (model.PrimaryPart and model.PrimaryPart.Position.Y - modelMinY or 0)
	if options.GroundY ~= nil then expectedGroundY = options.GroundY end
	local groundDelta = math.abs(modelMinY - expectedGroundY)
	requireCondition(groundDelta <= profile.GroundToleranceStuds, "geometry.ground-contact", string.format("Lowest visible geometry is %.3f studs from expected ground.", groundDelta), nil)

	for _, side in ipairs({"Left", "Right"}) do
		local hand = model:FindFirstChild(side .. "Hand")
		if hand and hand:IsA("BasePart") then
			local clearance = minimumY(hand) - modelMinY
			requireCondition(clearance >= profile.MinimumHandGroundClearanceStuds, "anatomy.arm-clearance", string.format("%s hand has only %.2f studs ground clearance.", side, clearance), hand)
		end
	end

	local _, size = model:GetBoundingBox()
	local heightToDepth = size.Y / math.max(size.Z, 0.001)
	if heightToDepth < profile.MinimumHeightToDepthRatio then
		add("silhouette.upright-ratio", "WARNING", string.format("Height/depth ratio %.2f is below the %.2f upright-review threshold.", heightToDepth, profile.MinimumHeightToDepthRatio), model.PrimaryPart)
	end

	if model.PrimaryPart then
		local reached = connectedParts(model, model.PrimaryPart)
		for _, part in ipairs(visible) do
			if not reached[part] then add("rig.disconnected-part", "BLOCKER", part.Name .. " is not connected to the PrimaryPart.", part) end
		end
	end

	table.sort(findings, function(a, b)
		local orderA, orderB = SEVERITY_ORDER[a.Severity] or 99, SEVERITY_ORDER[b.Severity] or 99
		if orderA == orderB then return a.Id < b.Id end
		return orderA < orderB
	end)
	local blockers, warnings = 0, 0
	for _, finding in ipairs(findings) do
		if finding.Severity == "BLOCKER" then blockers += 1 elseif finding.Severity == "WARNING" then warnings += 1 end
	end

	local result = {
		ProfileId = profile.ProfileId,
		AssetId = specification.AssetId,
		ModelName = model.Name,
		Status = blockers > 0 and "FAIL" or (warnings > 0 and "PASS_WITH_WARNINGS" or "PASS_DETERMINISTIC"),
		BlockerCount = blockers,
		WarningCount = warnings,
		Findings = findings,
		Metrics = {visibleParts = #visible, hitboxes = hitboxCount, heightToDepthRatio = heightToDepth, minimumVisibleY = modelMinY},
		VisualReviewCriteria = profile.VisualReviewCriteria,
	}
	model:SetAttribute("QualityGateBReviewStatus", result.Status)
	model:SetAttribute("QualityGateBBlockers", blockers)
	model:SetAttribute("QualityGateBWarnings", warnings)
	if options.CreateMarkers ~= false then createMarkers(model, findings) end
	return result
end

function Validator.ClearMarkers(model)
	clearMarkers(model)
end

return Validator
