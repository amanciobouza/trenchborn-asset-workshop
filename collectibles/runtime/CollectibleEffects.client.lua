-- Client-only cosmetic controller. No rewards or gameplay state.
local RunService = game:GetService("RunService")
local active = {}
local pending = {}

local function register(model)
	if not model:IsA("Model") or model:GetAttribute("BuildStage") ~= "P5_Dressing" then return end
	local effects = model:FindFirstChild("Effects")
	if not effects then return end
	local state = active[model] or {entries = {}, known = {}}
	local entries = state.entries
	for _, object in effects:GetDescendants() do
		if state.known[object] then continue end
		state.known[object] = true
		if object:IsA("BasePart") then
			table.insert(entries, {object, "part", object.Transparency, object.Material, object.Color})
		elseif object:IsA("PointLight") then
			table.insert(entries, {object, "light", object.Brightness, object.Range})
		elseif object:IsA("ParticleEmitter") then
			table.insert(entries, {object, "particles", object.Enabled})
		end
	end
	state.enabled = nil
	active[model] = state
end

for _, object in workspace:GetDescendants() do register(object) end
workspace.DescendantAdded:Connect(function(object)
	-- Deferred scan allows Rojo / streaming to finish parenting the model.
	local candidate = object:IsA("Model") and object or object:FindFirstAncestorOfClass("Model")
	if not candidate or pending[candidate] then return end
	pending[candidate] = true
	task.defer(function()
		pending[candidate] = nil
		register(candidate)
	end)
end)

local elapsed = 0
RunService.Heartbeat:Connect(function(dt)
	elapsed += dt
	if elapsed < 0.05 then return end -- Cosmetic pulse at 20 Hz.
	elapsed = 0
	local pulse = 0.82 + 0.18 * math.sin(os.clock() * 1.8)
	for model, state in active do
		if not model:IsDescendantOf(workspace) then
			for _, entry in state.entries do
				local object = entry[1]
				if not object.Parent then continue end
				if entry[2] == "part" then
					object.Transparency, object.Material, object.Color = entry[3], entry[4], entry[5]
				elseif entry[2] == "light" then
					object.Brightness = entry[3]
					object.Enabled = true
				elseif entry[2] == "particles" then
					object.Enabled = entry[3]
				end
			end
			active[model] = nil
			continue
		end
		local enabled = model:GetAttribute("EffectsEnabled") ~= false
		local changed = enabled ~= state.enabled
		for _, entry in state.entries do
			local object, kind = entry[1], entry[2]
			if not object.Parent then continue end
			if kind == "light" then
				object.Enabled = enabled
				object.Brightness = enabled and entry[3] * pulse or 0
			elseif changed and kind == "particles" then
				object.Enabled = enabled and entry[3]
				if not enabled then object:Clear() end
			elseif changed and kind == "part" and entry[3] < 1 then
				-- Preserve the core shape when disabling its emissive material.
				object.Material = enabled and entry[4] or Enum.Material.SmoothPlastic
				object.Color = enabled and entry[5] or entry[5]:Lerp(Color3.new(0, 0, 0), 0.65)
			end
		end
		state.enabled = enabled
	end
end)
