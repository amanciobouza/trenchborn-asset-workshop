-- Phase 1-3 blockout specification for the Large City terrain and street layout.
-- The building masses are spatial placeholders, not approved building Golden Masters.

local function building(id, displayName, buildingType, district, x, z, width, depth, height, yaw, elevation)
	return {
		Id = id,
		DisplayName = displayName,
		BuildingType = buildingType,
		District = district,
		Position = Vector3.new(x, elevation, z),
		Footprint = Vector2.new(width, depth),
		Height = height,
		Yaw = yaw or 0,
	}
end

local Specification = {
	AssetId = "LargeCity_Layout_Blockout",
	DisplayName = "Large City Layout Blockout",
	City = "LargeCity",
	Phase = 3,
	QualityGate = "A-Pending",
	Style = "Singapore x Miami tropical luxury metropolis",
	CoordinateSystem = "Origin is the Central Hub; west is ocean; north-east exits to Mega City",

	Dimensions = {
		Playable = Vector2.new(1500, 1400),
		Terrain = Vector2.new(1900, 1700),
		CentralHubDiameter = 260,
	},

	ElevationBands = {
		Water = -4,
		Beach = 2,
		Resort = 6,
		Gateway = 8,
		Downtown = 12,
		Civic = 16,
		MedicalTechnology = 20,
		Uptown = 24,
		Foothills = 60,
		MountainRidge = 130,
		MountainPeaks = 220,
	},

	Districts = {
		{Id = "Resort", DisplayName = "RESORT COAST", Center = Vector3.new(-470, 6, 20), Color = Color3.fromRGB(52, 154, 172)},
		{Id = "Gateway", DisplayName = "SOUTH GATEWAY", Center = Vector3.new(0, 8, -545), Color = Color3.fromRGB(183, 137, 78)},
		{Id = "Financial", DisplayName = "FINANCIAL CORE", Center = Vector3.new(-60, 12, 40), Color = Color3.fromRGB(65, 121, 174)},
		{Id = "Civic", DisplayName = "CIVIC DISTRICT", Center = Vector3.new(335, 16, -80), Color = Color3.fromRGB(113, 104, 164)},
		{Id = "MedicalTech", DisplayName = "MEDICAL + TECHNOLOGY", Center = Vector3.new(570, 20, 170), Color = Color3.fromRGB(73, 151, 121)},
		{Id = "Uptown", DisplayName = "SPORTS + UPTOWN", Center = Vector3.new(20, 24, 535), Color = Color3.fromRGB(191, 102, 68)},
	},

	Roads = {
		{
			Name = "Grand Boulevard",
			Width = 68,
			Points = {
				Vector3.new(0, 8, -720), Vector3.new(0, 8, -390), Vector3.new(0, 12, -145),
				Vector3.new(0, 12, 145), Vector3.new(0, 24, 430),
			},
		},
		{
			Name = "Ocean Boulevard",
			Width = 54,
			Points = {
				Vector3.new(-650, 6, -430), Vector3.new(-570, 6, -190), Vector3.new(-380, 6, 15),
				Vector3.new(-245, 8, 55), Vector3.new(-125, 12, 45), Vector3.new(0, 12, 0),
			},
		},
		{
			Name = "Meridian Boulevard",
			Width = 58,
			Points = {
				Vector3.new(0, 12, 0), Vector3.new(170, 14, 90), Vector3.new(350, 16, 210),
				Vector3.new(520, 20, 370), Vector3.new(650, 30, 665),
			},
		},
		{
			Name = "Central Ring",
			Width = 38,
			Closed = true,
			Points = {
				Vector3.new(-175, 12, -175), Vector3.new(175, 12, -175), Vector3.new(175, 12, 175), Vector3.new(-175, 12, 175),
			},
		},
		{
			Name = "Coastal Road",
			Width = 36,
			Points = {
				Vector3.new(-650, 6, -610), Vector3.new(-650, 6, -200), Vector3.new(-650, 6, 210), Vector3.new(-610, 6, 570),
			},
		},
		{
			Name = "Uptown Loop",
			Width = 38,
			Closed = true,
			Points = {
				Vector3.new(-360, 24, 390), Vector3.new(390, 24, 390), Vector3.new(390, 24, 690), Vector3.new(-360, 24, 690),
			},
		},
		{
			Name = "Technology Avenue",
			Width = 40,
			Points = {
				Vector3.new(345, 18, -330), Vector3.new(500, 20, -160), Vector3.new(590, 20, 70), Vector3.new(610, 20, 360),
			},
		},
	},

	Buildings = {
		-- Resort Coast: 10
		building("LC-01", "Trenchborn Bay Resort", "Waterfront Resort", "Resort", -475, 70, 110, 90, 76, -90, 6),
		building("LC-02", "Ocean Crown Hotel", "Beachfront Hotel", "Resort", -520, -235, 72, 58, 62, 8, 6),
		building("LC-03", "Coral Arc Hotel", "Beachfront Hotel", "Resort", -515, 310, 78, 62, 70, -8, 6),
		building("LC-04", "Palm Vista Condos", "Luxury Apartment", "Resort", -365, -300, 64, 54, 78, -12, 6),
		building("LC-05", "Marina View Condos", "Luxury Apartment", "Resort", -350, 285, 66, 52, 82, 12, 6),
		building("LC-06", "Azure Residences", "Large Apartment", "Resort", -480, 470, 70, 58, 68, 5, 6),
		building("LC-07", "Ocean Galleria", "Shopping Mall", "Resort", -315, -105, 115, 76, 38, -7, 6),
		building("LC-08", "Coast Convention Centre", "Convention Center", "Resort", -335, 115, 125, 82, 46, 10, 6),
		building("LC-09", "Promenade Parking", "Parking Tower", "Resort", -520, -420, 64, 54, 48, 0, 6),
		building("LC-10", "Tideglass Suites", "Hotel", "Resort", -360, 465, 62, 48, 64, 9, 6),

		-- South Gateway / Transit: 8
		building("LC-11", "Large City Central Station", "Central Train Station", "Gateway", 0, -575, 190, 82, 42, 0, 8),
		building("LC-12", "Station Parking", "Parking Tower", "Gateway", -180, -570, 66, 56, 52, 0, 8),
		building("LC-13", "Gateway Offices", "Office Tower", "Gateway", 170, -560, 64, 58, 86, 4, 8),
		building("LC-14", "Southline Apartments A", "Large Apartment", "Gateway", -270, -420, 70, 58, 66, -5, 8),
		building("LC-15", "Southline Apartments B", "Large Apartment", "Gateway", 270, -420, 70, 58, 66, 5, 8),
		building("LC-16", "Grand Arrival Hotel", "Hotel", "Gateway", -145, -390, 76, 62, 72, -3, 8),
		building("LC-17", "Large City Fire HQ", "Fire Station HQ", "Gateway", 150, -395, 92, 68, 34, 3, 8),
		building("LC-18", "Gateway Beacon", "High-Rise", "Gateway", 300, -570, 62, 56, 105, 0, 8),

		-- Financial Core: 15
		building("LC-19", "Meridian Tower", "Office Tower", "Financial", -270, -235, 66, 62, 132, -8, 12),
		building("LC-20", "Equinox Tower", "Office Tower", "Financial", -150, -260, 62, 58, 116, 4, 12),
		building("LC-21", "Crown Financial", "High-Rise", "Financial", 135, -270, 68, 62, 148, -4, 12),
		building("LC-22", "Skyline Exchange", "Office Tower", "Financial", 265, -235, 72, 64, 126, 8, 12),
		building("LC-23", "Harbour Axis", "High-Rise", "Financial", -295, -60, 64, 58, 118, -10, 12),
		building("LC-24", "Glasshouse One", "Office Tower", "Financial", -275, 135, 62, 58, 138, 7, 12),
		building("LC-25", "Glasshouse Two", "Office Tower", "Financial", -225, 285, 66, 58, 122, -7, 12),
		building("LC-26", "Central Residences", "Luxury Apartment", "Financial", -90, 300, 70, 62, 96, 3, 12),
		building("LC-27", "Parkline Residences", "Large Apartment", "Financial", 95, 300, 72, 62, 92, -3, 12),
		building("LC-28", "North Exchange", "High-Rise", "Financial", 245, 285, 64, 58, 128, 8, 12),
		building("LC-29", "Central Parking West", "Parking Tower", "Financial", -315, 260, 62, 54, 54, 0, 12),
		building("LC-30", "Central Parking East", "Parking Tower", "Financial", 315, 255, 62, 54, 54, 0, 12),
		building("LC-31", "Boulevard Hotel", "Hotel", "Financial", 285, 65, 76, 62, 84, 8, 12),
		building("LC-32", "Axis Offices", "Office Tower", "Financial", 305, -85, 62, 58, 112, -5, 12),
		building("LC-33", "Hub View Tower", "High-Rise", "Financial", -145, 225, 60, 54, 105, 5, 12),

		-- Civic District: 8
		building("LC-34", "Large City Courthouse", "Courthouse", "Civic", 365, -255, 118, 82, 54, 0, 16),
		building("LC-35", "Large City Police HQ", "Police HQ", "Civic", 505, -255, 94, 72, 46, 0, 16),
		building("LC-36", "Civic Administration", "Office Tower", "Civic", 430, -105, 70, 62, 94, -6, 16),
		building("LC-37", "Justice Square Tower", "High-Rise", "Civic", 545, -80, 64, 58, 112, 6, 16),
		building("LC-38", "Civic Grand Hotel", "Hotel", "Civic", 350, 80, 74, 62, 78, -6, 16),
		building("LC-39", "Civic Residences", "Large Apartment", "Civic", 485, 90, 72, 60, 82, 6, 16),
		building("LC-40", "Civic Parking", "Parking Tower", "Civic", 360, 230, 62, 54, 52, 0, 16),
		building("LC-41", "Tropical Signal Tower", "Observation Tower", "Civic", 510, 245, 48, 48, 165, 0, 16),

		-- Medical + Technology: 8
		building("LC-42", "Large City Central Hospital", "Central Hospital", "MedicalTech", 625, -170, 142, 104, 62, 0, 20),
		building("LC-43", "Meridian Pharma", "Pharma Plant", "MedicalTech", 650, 40, 132, 92, 48, 4, 20),
		building("LC-44", "Large City Power Utility", "Power Utility", "MedicalTech", 665, 265, 152, 106, 56, -4, 20),
		building("LC-45", "Technology Fire Station", "Fire Station HQ", "MedicalTech", 475, 350, 88, 68, 34, 0, 20),
		building("LC-46", "Research Offices", "Office Tower", "MedicalTech", 455, 25, 66, 60, 96, -8, 20),
		building("LC-47", "Volt Spire", "High-Rise", "MedicalTech", 500, 210, 64, 58, 118, 8, 20),
		building("LC-48", "MedTech Residences", "Large Apartment", "MedicalTech", 625, 455, 74, 62, 84, 5, 20),
		building("LC-49", "Medical Parking", "Parking Tower", "MedicalTech", 455, -150, 66, 56, 52, 0, 20),

		-- Sports + Uptown: 6
		building("LC-50", "Large City Stadium", "Stadium", "Uptown", 0, 555, 250, 170, 72, 0, 24),
		building("LC-51", "Uptown Arena", "Arena", "Uptown", -220, 530, 150, 112, 58, -4, 24),
		building("LC-52", "Summit Tower", "High-Rise", "Uptown", 220, 500, 70, 64, 126, 4, 24),
		building("LC-53", "Uptown Residences", "Luxury Apartment", "Uptown", -225, 665, 78, 66, 92, 0, 24),
		building("LC-54", "Stadium Hotel", "Hotel", "Uptown", 215, 650, 78, 64, 82, 0, 24),
		building("LC-55", "Uptown Parking", "Parking Tower", "Uptown", 340, 555, 70, 60, 54, 0, 24),
	},
}

assert(#Specification.Buildings == 55, "Large City layout must contain exactly 55 building plots")

return Specification
