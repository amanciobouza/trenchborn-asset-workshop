local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Selection = game:GetService("Selection")
local Workspace = game:GetService("Workspace")

local BRIDGE = "http://127.0.0.1:43127"
local MODEL_NAME = "Kaiju_I_Bound_Chimera_GoldenMaster"
local MAX_CAPTURE_ATTEMPTS = 2

local toolbar = plugin:CreateToolbar("Trenchborn")
local reviewButton = toolbar:CreateButton("Review Agent", "Run one review-only assessment against the approved target", "")
local widgetInfo = DockWidgetPluginGuiInfo.new(
	Enum.InitialDockState.Right,
	false,
	false,
	420,
	360,
	300,
	220
)
local widget = plugin:CreateDockWidgetPluginGui("TrenchbornReviewAgent", widgetInfo)
widget.Title = "Trenchborn Review Only"

local scroll = Instance.new("ScrollingFrame")
scroll.Name = "ReviewScroll"
scroll.Size = UDim2.fromScale(1, 1)
scroll.BackgroundColor3 = Color3.fromRGB(22, 27, 31)
scroll.BorderSizePixel = 0
scroll.CanvasSize = UDim2.new(0, 0, 0, 1600)
scroll.ScrollBarThickness = 8
scroll.Parent = widget

local status = Instance.new("TextLabel")
status.Name = "Status"
status.Size = UDim2.new(1, -8, 0, 1600)
status.BackgroundColor3 = Color3.fromRGB(22, 27, 31)
status.BackgroundTransparency = 0
status.TextColor3 = Color3.fromRGB(225, 235, 230)
status.TextXAlignment = Enum.TextXAlignment.Left
status.TextYAlignment = Enum.TextYAlignment.Top
status.TextWrapped = true
status.TextScaled = true
status.Font = Enum.Font.Code
status.Text = "REVIEW AGENT 1.2 READY\n\nStart the local review-only agent, then press Review Agent."
status.Parent = scroll

local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 12)
padding.PaddingBottom = UDim.new(0, 12)
padding.PaddingLeft = UDim.new(0, 12)
padding.PaddingRight = UDim.new(0, 12)
padding.Parent = status

local sizeConstraint = Instance.new("UITextSizeConstraint")
sizeConstraint.MinTextSize = 11
sizeConstraint.MaxTextSize = 17
sizeConstraint.Parent = status

local function setStatus(text, showWidget)
	status.Text = text
	scroll.CanvasPosition = Vector2.zero
	widget.Enabled = showWidget ~= false
end

local function formatReview(review)
	local lines = {
		review.status or "REVIEW COMPLETE",
		"",
		review.summary or "Review saved.",
	}

	if review.criteria and #review.criteria > 0 then
		table.insert(lines, "")
		table.insert(lines, "VISUAL CRITERIA")
		for _, criterion in ipairs(review.criteria) do
			table.insert(lines, string.format(
				"[%s] %s\n%s",
				criterion.result or "UNKNOWN",
				criterion.id or "unnamed criterion",
				criterion.reason or "No reason supplied."
			))
		end
	end

	if review.findings and #review.findings > 0 then
		table.insert(lines, "")
		table.insert(lines, "REQUIRED ACTIONS")
		for _, finding in ipairs(review.findings) do
			table.insert(lines, string.format(
				"[%s] %s\n%s\nAction: %s",
				finding.severity or "INFO",
				finding.id or "unnamed finding",
				finding.message or "No message supplied.",
				finding.recommendation or "No recommendation supplied."
			))
		end
	end

	if review.delivery then
		local chatgptStatus = review.delivery.chatgpt and review.delivery.chatgpt.status or "NOT TRIGGERED"
		table.insert(lines, "")
		table.insert(lines, string.format(
			"HANDOFF TO CHATGPT WORK\n%s / %s\nCommit: %s",
			review.delivery.status or "UNKNOWN",
			chatgptStatus,
			review.delivery.commit or "not available"
		))
	end

	return table.concat(lines, "\n")
end

local function post(path, payload)
	local response = HttpService:RequestAsync({
		Url = BRIDGE .. path,
		Method = "POST",
		Headers = { ["Content-Type"] = "application/json" },
		Body = HttpService:JSONEncode(payload),
	})
	if not response.Success then
		error(string.format("Review bridge returned HTTP %d: %s", response.StatusCode, response.Body))
	end
	return HttpService:JSONDecode(response.Body)
end

local function findReviewModel()
	local selected = Selection:Get()
	if #selected == 1 and selected[1]:IsA("Model") then
		return selected[1]
	end
	return Workspace:FindFirstChild(MODEL_NAME, true)
end

local function runTechnicalReview(model)
	local packageFolder = ReplicatedStorage:FindFirstChild("TrenchbornAssetWorkshop")
	if not packageFolder then error("ReplicatedStorage.TrenchbornAssetWorkshop is missing") end
	local validator = require(packageFolder:WaitForChild("AssetValidator"))
	local report = require(packageFolder:WaitForChild("AssetReviewReport"))
	local specification = require(packageFolder:WaitForChild("KaijuAwakenedSpecification"))
	local profile = require(packageFolder:WaitForChild("KaijuAwakenedReviewProfile"))
	local result = validator.Review(model, specification, profile, {GroundY = 0, CreateMarkers = true})
	return report.ToSerializable(result)
end

local function cameraViews(model, camera, captureAttempt)
	local boxCF, size = model:GetBoundingBox()
	local center = boxCF.Position
	local target = center

	-- Fit the complete bounding sphere inside both the vertical and horizontal
	-- field of view. Studio panels can make the 3D viewport much narrower than
	-- the full application window, so a fixed multiple of the largest dimension
	-- is not reliable.
	local viewport = camera.ViewportSize
	local aspect = math.max(viewport.X, 1) / math.max(viewport.Y, 1)
	local verticalHalfAngle = math.rad(camera.FieldOfView * 0.5)
	local horizontalHalfAngle = math.atan(math.tan(verticalHalfAngle) * aspect)
	local limitingHalfAngle = math.min(verticalHalfAngle, horizontalHalfAngle)
	local boundingRadius = size.Magnitude * 0.5
	local distance = (boundingRadius / math.sin(limitingHalfAngle)) * 1.2
	local views = {
		{name = "front", position = target + Vector3.new(0, 0, -distance)},
		{name = "left", position = target + Vector3.new(-distance, 0, 0)},
		{name = "right", position = target + Vector3.new(distance, 0, 0)},
		{name = "rear", position = target + Vector3.new(0, 0, distance)},
		{name = "three-quarter", position = target + Vector3.new(-1, 0.16, -1).Unit * distance},
	}
	local detailPadding = captureAttempt == 1 and 1.25 or 1.6
	local function addDetail(name, subjectNames, offset)
		local subjects = {}
		for _, subjectName in ipairs(subjectNames) do
			local subject = model:FindFirstChild(subjectName, true)
			if subject then
				if subject:IsA("BasePart") then table.insert(subjects, subject) end
				for _, descendant in ipairs(subject:GetDescendants()) do
					if descendant:IsA("BasePart") then table.insert(subjects, descendant) end
				end
			end
		end
		if #subjects == 0 then return end

		local minimum = Vector3.new(math.huge, math.huge, math.huge)
		local maximum = Vector3.new(-math.huge, -math.huge, -math.huge)
		for _, subject in ipairs(subjects) do
			local radius = subject.Size.Magnitude * 0.5
			local extent = Vector3.new(radius, radius, radius)
			minimum = minimum:Min(subject.Position - extent)
			maximum = maximum:Max(subject.Position + extent)
		end
		local detailTarget = (minimum + maximum) * 0.5
		local detailRadius = (maximum - minimum).Magnitude * 0.5
		local detailDistance = (detailRadius / math.sin(limitingHalfAngle)) * detailPadding
		table.insert(views, {
			name = name,
			target = detailTarget,
			position = detailTarget + offset.Unit * detailDistance,
		})
	end
	addDetail("face-front-close", {"Head", "Jaw", "HeadGeometry"}, Vector3.new(0, 0.05, -1))
	addDetail("face-three-quarter-close", {"Head", "Jaw", "HeadGeometry"}, Vector3.new(-1, 0.15, -1))
	addDetail("left-arm-close", {"LeftUpperArm", "LeftLowerArm", "LeftHand", "LeftHandGeometry"}, Vector3.new(-1, 0.1, -0.65))
	addDetail("right-arm-close", {"RightUpperArm", "RightLowerArm", "RightHand", "RightHandGeometry"}, Vector3.new(1, 0.1, -0.65))
	addDetail("left-foot-close", {"LeftFoot", "LeftFootGeometry"}, Vector3.new(-0.45, 0.35, -1))
	addDetail("right-foot-close", {"RightFoot", "RightFootGeometry"}, Vector3.new(0.45, 0.35, -1))
	return views, target
end

local function captureAndReview(model, captureAttempt)
	local previousSelection = Selection:Get()
	setStatus("REVIEW ONLY\n\nRunning deterministic checks...")
	local technical = runTechnicalReview(model)
	local session = post("/session/start", {
		assetId = technical.assetId,
		modelName = model.Name,
		technicalReport = technical,
	})

	local camera = Workspace.CurrentCamera
	if not camera then error("Workspace.CurrentCamera is missing") end
	local oldType, oldCF, oldFov = camera.CameraType, camera.CFrame, camera.FieldOfView
	-- Screenshots must contain model evidence only: no selection outlines and no dock widget occlusion.
	Selection:Set({})
	local captured, captureError = pcall(function()
		camera.CameraType = Enum.CameraType.Scriptable
		camera.FieldOfView = 34
		local views, target = cameraViews(model, camera, captureAttempt)
		for index, view in ipairs(views) do
			setStatus(string.format("REVIEW ONLY\n\nPreparing %s (%d/%d)...", view.name, index, #views))
			camera.CFrame = CFrame.lookAt(view.position, view.target or target)
			task.wait(0.75)
			-- Hide only for the actual ImageGrab request. Keeping the widget disabled
			-- for the complete sequence leaves an empty white dock in Studio.
			widget.Enabled = false
			task.wait(0.15)
			post("/session/capture", {sessionId = session.sessionId, view = view.name})
			setStatus(string.format("REVIEW ONLY\n\nCaptured %s (%d/%d).", view.name, index, #views))
			task.wait(0.15)
		end
	end)
	camera.CameraType, camera.CFrame, camera.FieldOfView = oldType, oldCF, oldFov
	Selection:Set(previousSelection)
	widget.Enabled = true
	if not captured then
		widget.Enabled = true
		error(captureError)
	end

	setStatus("REVIEW ONLY\n\nAI is comparing the model with the approved target...")
	local finished = post("/session/finish", {sessionId = session.sessionId})
	model:SetAttribute("QualityGateBVisualReviewStatus", finished.status or "UNKNOWN")
	model:SetAttribute("QualityGateBVisualReviewJSON", HttpService:JSONEncode(finished))
	return finished, session, technical
end

local function runReview()
	local model = findReviewModel()
	if not model then
		setStatus("FAIL\nSelect the Bound Chimera model or start Play so the Golden Master exists.")
		return
	end

	local finished, technical
	for captureAttempt = 1, MAX_CAPTURE_ATTEMPTS do
		finished, _, technical = captureAndReview(model, captureAttempt)
		if finished.status ~= "CAPTURE_INVALID" then break end
		setStatus(string.format(
			"CAPTURE INVALID\n\nRetaking the screenshots with wider framing (%d/%d). The model remains unchanged.",
			captureAttempt + 1,
			MAX_CAPTURE_ATTEMPTS
		))
	end
	if finished.status == "CAPTURE_INVALID" then
		setStatus("CAPTURE INVALID\n\nEvidence remains incomplete after the camera-only retake. The agent stopped without changing the model.")
		return
	end

	local deterministicPass = technical.blockers == 0 and technical.warnings == 0
	if finished.status == "PASS" and deterministicPass then
		setStatus("READY FOR USER QUALITY GATE B\n\n" .. formatReview(finished))
		return
	end
	setStatus(string.format(
		"REVIEW COMPLETE — CORRECTION REQUIRED IN CHATGPT WORK\n\n%s\n\nThe Review Agent stopped after one assessment. It did not edit or retry the model.",
		formatReview(finished)
	))
end
reviewButton.Click:Connect(function()
	widget.Enabled = true
	task.spawn(function()
		local ok, message = pcall(runReview)
		if not ok then setStatus("REVIEW FAILED\n\n" .. tostring(message)) end
	end)
end)
