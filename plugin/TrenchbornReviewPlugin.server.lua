local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Selection = game:GetService("Selection")
local Workspace = game:GetService("Workspace")

local BRIDGE = "http://127.0.0.1:43127"
local MODEL_NAME = "Kaiju_I_Bound_Chimera_GoldenMaster"

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
status.BackgroundTransparency = 1
status.TextColor3 = Color3.fromRGB(225, 235, 230)
status.TextXAlignment = Enum.TextXAlignment.Left
status.TextYAlignment = Enum.TextYAlignment.Top
status.TextWrapped = true
status.TextScaled = true
status.Font = Enum.Font.Code
status.Text = "Start the local review-only agent, then press Review Agent."
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

local function setStatus(text)
	status.Text = text
	scroll.CanvasPosition = Vector2.zero
	widget.Enabled = true
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
		table.insert(lines, "")
		table.insert(lines, string.format(
			"HANDOFF TO CHATGPT WORK\n%s\nCommit: %s",
			review.delivery.status or "UNKNOWN",
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

local function cameraViews(model, camera)
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
	local function addDetail(name, subjectName, offset, detailDistance, targetOffset)
		local subject = model:FindFirstChild(subjectName, true)
		if subject and subject:IsA("BasePart") then
			local detailTarget = subject.Position + (targetOffset or Vector3.zero)
			table.insert(views, {
				name = name,
				target = detailTarget,
				position = detailTarget + offset.Unit * detailDistance,
			})
		end
	end
	addDetail("face-front-close", "Head", Vector3.new(0, 0.05, -1), 13)
	addDetail("face-three-quarter-close", "Head", Vector3.new(-1, 0.15, -1), 14)
	addDetail("left-arm-close", "LeftUpperArm", Vector3.new(-1, 0.1, -0.65), 11)
	addDetail("right-arm-close", "RightUpperArm", Vector3.new(1, 0.1, -0.65), 11)
	-- Aim beyond the ankle toward the toe fan so all three front claws and the rear claw stay in frame.
	addDetail("left-foot-close", "LeftFoot", Vector3.new(-0.35, 0.45, -1), 13, Vector3.new(0, -1.25, -2.0))
	addDetail("right-foot-close", "RightFoot", Vector3.new(0.35, 0.45, -1), 13, Vector3.new(0, -1.25, -2.0))
	return views, target
end

local function captureAndReview(model)
	Selection:Set({model})
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
	local captured, captureError = pcall(function()
		camera.CameraType = Enum.CameraType.Scriptable
		camera.FieldOfView = 34
		local views, target = cameraViews(model, camera)
		for index, view in ipairs(views) do
			setStatus(string.format(
				"REVIEW ONLY\n\nCapturing %s (%d/%d)...",
				view.name,
				index,
				#views
			))
			camera.CFrame = CFrame.lookAt(view.position, view.target or target)
			task.wait(0.75)
			post("/session/capture", {sessionId = session.sessionId, view = view.name})
		end
	end)
	camera.CameraType, camera.CFrame, camera.FieldOfView = oldType, oldCF, oldFov
	if not captured then error(captureError) end

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

	local finished, _, technical = captureAndReview(model)
	local deterministicPass = technical.blockers == 0 and technical.warnings == 0
	if finished.status == "PASS" and deterministicPass then
		setStatus("READY FOR USER QUALITY GATE B\n\n" .. formatReview(finished))
		return
	end

	setStatus(string.format(
		"REVIEW COMPLETE — CORRECTION REQUIRED IN CHATGPT WORK\n\n%s\n\nThe Review Agent stopped after one assessment. It did not edit or retry the model. ChatGPT Work must read reviews/latest/ and implement any correction; then the user may start a new review.",
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
