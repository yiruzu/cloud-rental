--? For support, join our Discord server: https://discord.gg/jAnEnyGBef

return {
	--[[ GENERAL SETTINGS ]]
	Framework = "esx", -- Supported: "esx", "qbcore" or "custom"
	DebugMode = false, -- Enable print statements for debugging

	--[[ DISTANCE SETTINGS ]]

	DisplayDistance = 3.75, -- Distance at which Help/Floating Text is shown
	InteractDistance = 3.75, -- Distance within which players can interact with the vehicle

	--[[ VEHICLE SETTINGS ]]

	MaxParkingTime = 300, -- Time (in seconds) before a vehicle is deleted

	VehicleBlip = {
		Name = "Rental Vehicle",
		Sprite = 811,
		Color = 0,
		Scale = 0.6,
	},

	VehicleColor = {
		Enabled = true, -- If false, a random color will be used for the vehicle
		Primary = { 255, 255, 255 }, -- r, g, b
		Secondary = { 255, 255, 255 }, -- r, g, b
	},

	WarpPed = true, -- Teleport the player into the vehicle after renting it
	VehicleKeys = false, -- Enable vehicle keys --! (requires configuration in functions.lua)
	FuelSystem = true, -- Enable fuel system --! (requires configuration in functions.lua)

	--[[ RENTAL LOCATIONS ]]

	Locations = {
		["Example Rental Zone (1)"] = {
			CenterPosition = vec3(412.5373, -634.4246, 28.5001), -- Center coordinates of the rental zone
			Radius = 35.0, -- Radius of the rental zone
			VehiclePositions = {
				vec4(416.2914, -646.6737, 28.5002, 94.2323),
				vec4(416.6673, -641.3223, 28.5002, 90.4353),
				vec4(416.6028, -636.0629, 28.5001, 90.9932),
				vec4(408.7512, -638.7046, 28.5001, 270.2635),
				vec4(408.2639, -644.0609, 28.5002, 272.9698),
				vec4(408.1920, -649.4117, 28.5003, 268.3243),
				-- Add more vehicle positions as needed
			},
			SpawnPositions = {
				vec4(425.4626, -655.6544, 28.5004, 180.5279),
				vec4(425.2303, -648.5248, 28.5003, 177.6650),
				vec4(424.9668, -641.7947, 28.5002, 181.5867),
				-- Add more spawn positions as needed
			},
			BlipIcon = {
				Name = "Rental",
				Sprite = 326,
				Color = 0,
				Scale = 0.6,
			},
			BlipRadius = {
				Sprite = 9,
				Color = 3,
				Alpha = 75,
			},
			Vehicles = {
				{
					DisplayName = "Itali RSX", -- Display name of the vehicle
					Model = `italirsx`, -- Vehicle model name
					PricePerMinute = 45, -- Rental cost per minute
					UnlockFee = 100, -- Fee to unlock the vehicle
					DamagePenalty = {
						Enabled = true, -- Enable damage penalties
						PenaltyPrice = 170, -- Penalty for vehicle damage
						DamagePercentForPenalty = 5, -- Percentage of damage to trigger penalty (1 = very sensitive, 100 = vehicle must be destroyed)
					},
				},
				{
					DisplayName = "Comet S2",
					Model = `comet6`,
					PricePerMinute = 40,
					UnlockFee = 90,
					DamagePenalty = {
						Enabled = true,
						PenaltyPrice = 150,
						DamagePercentForPenalty = 4.5,
					},
				},
				{
					DisplayName = "Asea",
					Model = `asea`,
					PricePerMinute = 15,
					UnlockFee = 30,
					DamagePenalty = {
						Enabled = true,
						PenaltyPrice = 40,
						DamagePercentForPenalty = 12.5,
					},
				},
				{
					DisplayName = "Baller",
					Model = `baller`,
					PricePerMinute = 20,
					UnlockFee = 40,
					DamagePenalty = {
						Enabled = true,
						PenaltyPrice = 50,
						DamagePercentForPenalty = 12.5,
					},
				},
				{
					DisplayName = "BMX",
					Model = `bmx`,
					PricePerMinute = 5,
					UnlockFee = 10,
					DamagePenalty = {
						Enabled = true,
						PenaltyPrice = 10,
						DamagePercentForPenalty = 12.5,
					},
				},
				{
					DisplayName = "Faggio Sport",
					Model = `faggio`,
					PricePerMinute = 10,
					UnlockFee = 15,
					DamagePenalty = {
						Enabled = true,
						PenaltyPrice = 15,
						DamagePercentForPenalty = 12.5,
					},
				},
				-- Add more vehicles as needed
			},
		},
	},
}
