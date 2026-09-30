local specification = require(script.Parent:WaitForChild("LargeCityWaterfrontResortSpecification"))

local PoolFacade = {}
local COLORS = specification.Palette

local GLASS_DEPTH = 0.35
local STANDOFF = 0.22

local function part(parent, name, size, cf, color, material, transparency)
	local item = Instance.new("Part")
	item.Name = name
	item.Size = size
	item.CFrame = cf
	item.Color = color
	item.Material = material or Enum.Material.SmoothPlastic
	item.Transparency = transparency or 0
	item.Anchored = true
	item.CanCollide = false
	item.CastShadow = true
	item.TopSurface = Enum.SurfaceType.Smooth
	item.BottomSurface = Enum.SurfaceType.Smooth
	item.Parent = parent
	return item
end

local function block(parent, name, size, position, color, material, rotation)
	local cf = CFrame.new(position)
	if rotation then
		cf *= CFrame.Angles(math.rad(rotation.X), math.rad(rotation.Y), math.rad(rotation.Z))
	end
	return part(parent, name, size, cf, color, material)
end

local function glass(parent, name, size, position, rotation)
	local item = block(parent, name, size, position, COLORS.Glass, Enum.Material.Glass, rotation)
	item.Transparency = 0.18
	item.Reflectance = 0.04
	return item
end

local function localToWorld(center, yawDegrees, localPosition)
	return (CFrame.new(center) * CFrame.Angles(0, math.rad(yawDegrees), 0) * CFrame.new(localPosition)).Position
end

local function resetFolder(parent)
	local existing = parent:FindFirstChild("PoolsideFacade")
	if existing then
		existing:Destroy()
	end
	local folder = Instance.new("Folder")
	folder.Name = "PoolsideFacade"
	folder.Parent = parent
	return folder
end

local function addBands(parent, prefix, center, yaw, localRearZ, width, yLevels, height)
	for index, y in ipairs(yLevels) do
		local p = localToWorld(Vector3.new(center.X, y, center.Z), yaw, Vector3.new(0, 0, localRearZ + STANDOFF))
		glass(parent, prefix .. "GlassBand" .. index, Vector3.new(width, height, GLASS_DEPTH), p, Vector3.new(0, yaw, 0))

		-- A shallow ledge gives the pool elevation depth without adding full balconies.
		local ledge = localToWorld(Vector3.new(center.X, y - height * 0.5 - 0.28, center.Z), yaw, Vector3.new(0, 0, localRearZ + 0.62))
		block(parent, prefix .. "Ledge" .. index, Vector3.new(width + 1.0, 0.32, 1.15), ledge, COLORS.Limestone, Enum.Material.Concrete, Vector3.new(0, yaw, 0))
	end
end

local function addMullions(parent, prefix, center, yaw, localRearZ, width, yMin, yMax, count)
	for index = 0, count do
		local localX = -width / 2 + width * (index / count)
		local p = localToWorld(Vector3.new(center.X, (yMin + yMax) / 2, center.Z), yaw, Vector3.new(localX, 0, localRearZ + STANDOFF + 0.08))
		block(parent, prefix .. "Mullion" .. index, Vector3.new(0.30, yMax - yMin, 0.48), p, COLORS.Metal, Enum.Material.Metal, Vector3.new(0, yaw, 0))
	end
end

local function countGeometry(model)
	local visible = 0
	for _, item in ipairs(model:GetDescendants()) do
		if item:IsA("BasePart") and item.Transparency < 1 then
			visible += 1
		end
	end
	model:SetAttribute("VisiblePartCount", visible)
	if specification.GoldenMaster and specification.GoldenMaster.MaxVisibleParts then
		model:SetAttribute("VisiblePartBudget", specification.GoldenMaster.MaxVisibleParts)
		model:SetAttribute("VisiblePartBudgetPassed", visible <= specification.GoldenMaster.MaxVisibleParts)
	end
end

function PoolFacade.Apply(model)
	local groups = model:WaitForChild("DestructionGroups")
	local podium = resetFolder(groups:WaitForChild("D2_PodiumLobby"))
	local leftWing = resetFolder(groups:WaitForChild("D3_LeftGuestWing"))
	local rightWing = resetFolder(groups:WaitForChild("D4_RightGuestWing"))
	local lowerTower = resetFolder(groups:WaitForChild("D5_CentralTowerLower"))
	local upperTower = resetFolder(groups:WaitForChild("D6_CentralTowerUpper"))

	-- Pool-facing lobby at the rear of the podium (rear face is Z=28).
	glass(podium, "PoolLobbyGlass", Vector3.new(42, 6.0, GLASS_DEPTH), Vector3.new(0, 8.0, 28 + STANDOFF))
	for x = -18, 18, 6 do
		block(podium, "PoolLobbyMullion_" .. tostring(x), Vector3.new(0.32, 6.2, 0.48), Vector3.new(x, 8.0, 28 + STANDOFF + 0.08), COLORS.Metal, Enum.Material.Metal)
	end

	-- Central tower. Both rear faces end at world Z=19.
	addBands(lowerTower, "LowerPool_", Vector3.new(0, 0, 5), 0, 14.0, 29, {18.0, 22.4, 26.8, 31.2}, 2.5)
	addMullions(lowerTower, "LowerPool_", Vector3.new(0, 0, 5), 0, 14.0, 29, 16.5, 33.0, 6)
	addBands(upperTower, "UpperPool_", Vector3.new(0, 0, 6.5), 0, 12.5, 25, {39.5, 43.3, 47.1, 50.9, 54.7, 58.5}, 2.35)
	addMullions(upperTower, "UpperPool_", Vector3.new(0, 0, 6.5), 0, 12.5, 25, 38.0, 60.0, 5)

	local function wingFacade(parent, side)
		local sign = side == "Left" and -1 or 1
		local x = sign * 29
		local yaw = sign * -12
		addBands(parent, side .. "LowerPool_", Vector3.new(x, 0, 8), yaw, 12.0, 27, {10.5, 14.5, 18.5, 22.5}, 2.35)
		addMullions(parent, side .. "LowerPool_", Vector3.new(x, 0, 8), yaw, 12.0, 27, 9.0, 24.5, 5)
		addBands(parent, side .. "UpperPool_", Vector3.new(x - sign * 1.5, 0, 9), yaw, 10.5, 23, {30.5, 34.5}, 2.25)
		addMullions(parent, side .. "UpperPool_", Vector3.new(x - sign * 1.5, 0, 9), yaw, 10.5, 23, 29.0, 36.0, 4)
	end

	wingFacade(leftWing, "Left")
	wingFacade(rightWing, "Right")

	model:SetAttribute("PoolsideFacadeRevision", "PoolsideFacade-v1")
	countGeometry(model)
	return model
end

return PoolFacade
