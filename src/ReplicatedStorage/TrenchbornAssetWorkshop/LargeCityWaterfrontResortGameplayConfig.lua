local Config = {
	AssetId = "LargeCity_LuxuryWaterfrontResort_L3",
	BuildingType = "Hotel",
	CityTier = 4,
	MaxHealth = 64000,
	EnergyType = "Thermal",
	DestructionReward = 4828,
	RewardFormula = "floor(MaxHealth ^ 0.75 * 1.2)",
	RuinFolderName = "RuinState",
	ReviewDamageStep = 8000,

	DamageStateThresholds = {
		Light = 0.75,
		Heavy = 0.50,
		Critical = 0.25,
	},

	DestructionOrder = {
		"D1_EntranceCanopy",
		"D7_RooftopSkyBar",
		"D2_PodiumLobby",
		"D3_LeftGuestWing",
		"D4_RightGuestWing",
		"D6_CentralTowerUpper",
		"D5_CentralTowerLower",
	},

	Groups = {
		D1_EntranceCanopy = {MaxHealth = 5000, RubbleCount = 3},
		D2_PodiumLobby = {MaxHealth = 8000, RubbleCount = 4},
		D3_LeftGuestWing = {MaxHealth = 11000, RubbleCount = 5},
		D4_RightGuestWing = {MaxHealth = 11000, RubbleCount = 5},
		D5_CentralTowerLower = {MaxHealth = 12000, RubbleCount = 6},
		D6_CentralTowerUpper = {MaxHealth = 11000, RubbleCount = 5},
		D7_RooftopSkyBar = {MaxHealth = 6000, RubbleCount = 4},
	},
}

return Config
