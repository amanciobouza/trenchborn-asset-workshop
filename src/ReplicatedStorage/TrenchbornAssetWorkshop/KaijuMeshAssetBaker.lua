--!strict
-- Studio-only one-time baker for persistent Kaiju draft mesh assets.
-- Run from the Studio command bar:
-- require(game.ReplicatedStorage.TrenchbornAssetWorkshop.KaijuMeshAssetBaker).Bake()

local AssetService = game:GetService("AssetService")

local Baker = {}

local function addTriangle(mesh: EditableMesh, a: Vector3, b: Vector3, c: Vector3)
	mesh:AddTriangle(mesh:AddVertex(a), mesh:AddVertex(b), mesh:AddVertex(c))
end

local function doubleTriangle(mesh: EditableMesh, a: Vector3, b: Vector3, c: Vector3)
	addTriangle(mesh, a, b, c)
	addTriangle(mesh, a, c, b)
end

local function organic(): EditableMesh
	local mesh = AssetService:CreateEditableMesh()
	local rings, sides = 5, 10
	local vertices = {}
	local bottom = mesh:AddVertex(Vector3.new(0, -0.5, 0))
	for ring = 1, rings do
		local latitude = -math.pi * 0.5 + math.pi * ring / (rings + 1)
		vertices[ring] = {}
		for side = 1, sides do
			local longitude = math.pi * 2 * (side - 1) / sides
			local stagger = ((ring * 7 + side * 3) % 5 - 2) * 0.025
			local radius = math.cos(latitude) * (1 + stagger)
			vertices[ring][side] = mesh:AddVertex(Vector3.new(
				math.cos(longitude) * radius * 0.5,
				math.sin(latitude) * 0.5,
				math.sin(longitude) * radius * 0.5
			))
		end
	end
	local top = mesh:AddVertex(Vector3.new(0, 0.5, 0))
	for side = 1, sides do
		local nextSide = side % sides + 1
		mesh:AddTriangle(bottom, vertices[1][nextSide], vertices[1][side])
		for ring = 1, rings - 1 do
			local a, b = vertices[ring][side], vertices[ring][nextSide]
			local c, d = vertices[ring + 1][side], vertices[ring + 1][nextSide]
			mesh:AddTriangle(a, b, c)
			mesh:AddTriangle(b, d, c)
		end
		mesh:AddTriangle(vertices[rings][side], vertices[rings][nextSide], top)
	end
	return mesh
end

local function predatorHead(): EditableMesh
	local mesh = AssetService:CreateEditableMesh()
	local backTopL, backTopR = Vector3.new(-0.5, 0.42, 0.45), Vector3.new(0.5, 0.42, 0.45)
	local backLowL, backLowR = Vector3.new(-0.48, -0.4, 0.42), Vector3.new(0.48, -0.4, 0.42)
	local browL, browR = Vector3.new(-0.46, 0.28, -0.35), Vector3.new(0.46, 0.28, -0.35)
	local jawL, jawR = Vector3.new(-0.42, -0.38, -0.42), Vector3.new(0.42, -0.38, -0.42)
	local snoutTopL, snoutTopR = Vector3.new(-0.34, 0.08, -0.72), Vector3.new(0.34, 0.08, -0.72)
	local snoutLowL, snoutLowR = Vector3.new(-0.33, -0.3, -0.74), Vector3.new(0.33, -0.3, -0.74)
	doubleTriangle(mesh, backTopL, backTopR, browR); doubleTriangle(mesh, backTopL, browR, browL)
	doubleTriangle(mesh, browL, browR, snoutTopR); doubleTriangle(mesh, browL, snoutTopR, snoutTopL)
	doubleTriangle(mesh, snoutTopL, snoutTopR, snoutLowR); doubleTriangle(mesh, snoutTopL, snoutLowR, snoutLowL)
	doubleTriangle(mesh, backLowL, jawL, jawR); doubleTriangle(mesh, backLowL, jawR, backLowR)
	doubleTriangle(mesh, jawL, snoutLowL, snoutLowR); doubleTriangle(mesh, jawL, snoutLowR, jawR)
	doubleTriangle(mesh, backTopL, browL, jawL); doubleTriangle(mesh, backTopL, jawL, backLowL)
	doubleTriangle(mesh, backTopR, backLowR, jawR); doubleTriangle(mesh, backTopR, jawR, browR)
	doubleTriangle(mesh, browL, snoutTopL, snoutLowL); doubleTriangle(mesh, browL, snoutLowL, jawL)
	doubleTriangle(mesh, browR, jawR, snoutLowR); doubleTriangle(mesh, browR, snoutLowR, snoutTopR)
	return mesh
end

local function claw(): EditableMesh
	local mesh = AssetService:CreateEditableMesh()
	local sections = {
		{Vector3.new(-0.28, 0.28, 0.5), Vector3.new(0.28, 0.28, 0.5), Vector3.new(0, -0.25, 0.5)},
		{Vector3.new(-0.22, 0.2, 0.05), Vector3.new(0.22, 0.2, 0.05), Vector3.new(0, -0.28, 0.05)},
		{Vector3.new(-0.13, 0.02, -0.3), Vector3.new(0.13, 0.02, -0.3), Vector3.new(0, -0.35, -0.3)},
	}
	for index = 1, #sections - 1 do
		for edge = 1, 3 do
			local nextEdge = edge % 3 + 1
			doubleTriangle(mesh, sections[index][edge], sections[index][nextEdge], sections[index + 1][nextEdge])
			doubleTriangle(mesh, sections[index][edge], sections[index + 1][nextEdge], sections[index + 1][edge])
		end
	end
	local tip = Vector3.new(0, -0.48, -0.62)
	for edge = 1, 3 do
		doubleTriangle(mesh, sections[3][edge], sections[3][edge % 3 + 1], tip)
	end
	doubleTriangle(mesh, sections[1][1], sections[1][3], sections[1][2])
	return mesh
end

local function dorsalPlate(): EditableMesh
	local mesh = AssetService:CreateEditableMesh()
	local outline = {
		Vector2.new(-0.48, -0.5), Vector2.new(-0.42, 0.05), Vector2.new(-0.2, 0.32),
		Vector2.new(-0.05, 0.5), Vector2.new(0.12, 0.35), Vector2.new(0.32, 0.18),
		Vector2.new(0.48, -0.5),
	}
	local depth = 0.12
	for index = 1, #outline - 1 do
		local a, b = outline[index], outline[index + 1]
		doubleTriangle(mesh, Vector3.new(a.X, a.Y, -depth), Vector3.new(b.X, b.Y, -depth), Vector3.new(b.X, b.Y, depth))
		doubleTriangle(mesh, Vector3.new(a.X, a.Y, -depth), Vector3.new(b.X, b.Y, depth), Vector3.new(a.X, a.Y, depth))
	end
	for index = 2, #outline - 1 do
		doubleTriangle(mesh, Vector3.new(outline[1].X, outline[1].Y, -depth), Vector3.new(outline[index].X, outline[index].Y, -depth), Vector3.new(outline[index + 1].X, outline[index + 1].Y, -depth))
		doubleTriangle(mesh, Vector3.new(outline[1].X, outline[1].Y, depth), Vector3.new(outline[index + 1].X, outline[index + 1].Y, depth), Vector3.new(outline[index].X, outline[index].Y, depth))
	end
	return mesh
end

function Baker.Bake()
	assert(game.CreatorType == Enum.CreatorType.User, "This baker is configured for a personally owned experience.")
	local definitions = {
		OrganicMass = organic,
		PredatorHead = predatorHead,
		CurvedClaw = claw,
		DorsalPlate = dorsalPlate,
	}
	local ids = {}
	for name, factory in pairs(definitions) do
		local mesh = factory()
		local result, assetId = AssetService:CreateAssetAsync(mesh, Enum.AssetType.Mesh, {
			CreatorId = game.CreatorId,
			CreatorType = Enum.AssetCreatorType.User,
			Name = "Trenchborn Kaiju Draft " .. name,
			Description = "Phase 4 editable draft geometry for Trenchborn Kaiju",
		})
		mesh:Destroy()
		assert(result == Enum.CreateAssetResult.Success, string.format("Upload failed for %s: %s", name, tostring(assetId)))
		ids[name] = assetId
		print(string.format("[Kaiju Mesh Baker] %s = %s", name, tostring(assetId)))
	end
	print("[Kaiju Mesh Baker] Complete. Copy these IDs into KaijuMeshAssetManifest.lua:")
	for name, assetId in pairs(ids) do print(string.format("%s = %s", name, tostring(assetId))) end
	return ids
end

return Baker
