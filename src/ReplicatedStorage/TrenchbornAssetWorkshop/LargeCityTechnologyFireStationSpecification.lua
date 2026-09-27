-- Issue #3 supersedes the old three-bay / 34-stud family concept.
return {
 AssetId = "LargeCity_EmberlineResponseHQ_P4",
 DisplayName = "Emberline Response HQ",
 LayoutId = "LC-45",
 City = "LargeCity",
 District = "MedicalTech",
 Phase = 4,
 QualityGate = "B-Pending",
 QualityGateA = "Approved",
 TechnicalBreakdown = "Approved",
 SingleBuilding = true,
 InstanceCount = 1,
 Issue = "https://github.com/amanciobouza/trenchborn-asset-workshop/issues/3",
 VisualTarget = "https://raw.githubusercontent.com/amanciobouza/trenchborn-asset-workshop/c022617aa7ea928ccc15c967a2e6c9acc521ee8b/docs/assets/large-city/fire-station/emberline-approved-target-2026-09-26.jpg",
 Dimensions = {
  Plot = Vector2.new(176, 112),
  Hall = Vector3.new(96, 40, 64),
  Administration = Vector3.new(48, 40, 64),
  Tower = Vector3.new(24, 96, 32),
  Apron = Vector2.new(176, 40),
 },
 DoorBays = 4,
 TrainingLevels = 6,
 CoordinateSystem = {Front = "-Z", Pivot = "plot ground centre", GroundY = 0},
 CityPlanReference = {Version = "v2.1", PlanX = 1440, PlanZ = 470, Entrance = "East"},
 -- Plan Z points north; do not treat these numbers as ready-made Roblox CFrames.
 -- City lies north of Large City; Mega City lies south.
 Gameplay = {Status = "P6 pending", MaxHealthApproved = false, EnergyTypeApproved = false},
 Export = {File = "dist/LargeCityEmberlineResponseHQ_P4.rbxmx", StudioImportVerified = false},
}
