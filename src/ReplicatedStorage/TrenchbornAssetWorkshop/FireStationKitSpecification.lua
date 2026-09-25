local Specification = {
	KitId = "TBK_FS",
	DisplayName = "Fire Station Kit",
	Version = "1.0.0",
	GridSize = 16,
	NormalFloorHeight = 12,
	LargeGroundFloorHeight = 16,
	SourceFamily = "LargeCity_FireStation_Kit_v1",
	SourceReference = "LC-45 Technology Fire Station",

	Categories = {
		"Core",
		"Facades",
		"Entrances",
		"Roof",
		"Props",
		"Signage",
		"Exterior",
		"Examples",
		"Metadata",
	},

	Modules = {
		Core = {
			TBK_FS_Core_Bay_A = Vector3.new(16, 16, 32),
			TBK_FS_Core_BayDouble_A = Vector3.new(32, 16, 32),
			TBK_FS_Core_Office_A = Vector3.new(16, 16, 32),
			TBK_FS_Core_Stair_A = Vector3.new(16, 16, 16),
			TBK_FS_Core_TrainingTower_A = Vector3.new(16, 32, 16),
		},
		Facades = {
			TBK_FS_Facade_Garage_A = Vector3.new(16, 12, 1),
			TBK_FS_Facade_Garage_B = Vector3.new(16, 12, 1),
			TBK_FS_Facade_Window_A = Vector3.new(16, 12, 1),
			TBK_FS_Facade_Window_B = Vector3.new(16, 12, 1),
			TBK_FS_Facade_Window_C = Vector3.new(16, 12, 1),
			TBK_FS_Facade_Solid_A = Vector3.new(16, 12, 1),
			TBK_FS_Facade_Solid_B = Vector3.new(16, 12, 1),
		},
		Entrances = {
			TBK_FS_Entrance_Main_A = Vector3.new(16, 12, 8),
			TBK_FS_Entrance_Service_A = Vector3.new(16, 12, 4),
			TBK_FS_Entrance_Canopy_A = Vector3.new(16, 4, 8),
		},
		Roof = {
			TBK_FS_Roof_Flat_A = Vector3.new(16, 1, 16),
			TBK_FS_Roof_Parapet_A = Vector3.new(16, 2, 1),
			TBK_FS_Roof_Corner_A = Vector3.new(1, 2, 1),
			TBK_FS_Roof_HVAC_A = Vector3.new(8, 4, 8),
		},
		Props = {
			TBK_FS_Prop_Bollard_A = Vector3.new(1, 4, 1),
			TBK_FS_Prop_HoseRack_A = Vector3.new(6, 5, 2),
			TBK_FS_Prop_EquipmentBox_A = Vector3.new(4, 5, 2),
			TBK_FS_Prop_WallLight_A = Vector3.new(2, 1, 1),
			TBK_FS_Prop_RoofAntenna_A = Vector3.new(2, 8, 2),
			TBK_FS_Prop_Vent_A = Vector3.new(4, 3, 4),
			TBK_FS_Prop_AlarmLight_A = Vector3.new(1, 1, 1),
		},
		Signage = {
			TBK_FS_Sign_FireStation_A = Vector3.new(16, 4, 1),
			TBK_FS_Sign_Number_A = Vector3.new(6, 4, 1),
		},
		Exterior = {
			TBK_FS_Ext_Apron_A = Vector3.new(16, 1, 16),
			TBK_FS_Ext_Sidewalk_A = Vector3.new(16, 1, 8),
			TBK_FS_Ext_Curb_A = Vector3.new(16, 1, 2),
		},
	},

	Examples = {
		Small = {
			Name = "TBK_FS_Example_Small",
			Footprint = Vector2.new(32, 32),
			BayCount = 1,
		},
		Standard = {
			Name = "TBK_FS_Example_Standard",
			Footprint = Vector2.new(48, 32),
			BayCount = 2,
		},
		Large = {
			Name = "TBK_FS_Example_Large",
			Footprint = Vector2.new(64, 48),
			BayCount = 3,
		},
	},

	CompatibleKits = {
		"TBK_PT",
		"TBK_PS",
		"TBK_RT",
		"TBK_OT",
		"TBK_HT",
	},

	Rules = {
		"Structural modules snap to a 16-stud horizontal grid.",
		"Module pivots sit on the lower-left grid corner and modules build into +X/+Z.",
		"Core geometry remains separate from facades, entrances, signage and props.",
		"Rotations use 0/90/180/270 degrees.",
		"No coplanar decorative surfaces are intentionally layered.",
		"Examples are composed only from kit modules.",
		"Each module is independently cloneable and placeable.",
	},
}

return Specification
