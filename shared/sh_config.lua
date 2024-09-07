return {
	Framework = "esx", -- Supported frameworks: "esx", "qbcore", or "custom"

	DisplayDistance = 3.5, -- Distance at which Help/Floating Text is displayed
	InteractDistance = 3.5, -- Distance at which players can interact with the vehicle

	--[[ Vehicle Settings ]]

	MaxParkingTime = 15, -- Time (in seconds) until the vehicle gets deleted

	VehicleBlip = {
		Name = "Rental Vehicle",
		Sprite = 811,
		Color = 0,
		Scale = 0.6,
	},

	VehicleColor = {
		Enabled = true,
		Primary = { 255, 255, 255 }, -- r, g, b
		Secondary = { 255, 255, 255 }, -- r, g, b
	},

	WarpPed = true,
	VehicleKeys = false,
	FuelSystem = true,

	--[[ Rental Locations ]]

	Locations = {
		["Example Rental Zone (1)"] = {
			CenterPosition = vec3(412.5373, -634.4246, 28.5001), -- Center coordinates of the rental zone
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
			Radius = 35.0, -- Radius of the rental zone
		},
	},

	-- [[ Vehicle Options ]]

	Vehicles = {
		{
			DisplayName = "Itali RSX", -- The vehicle display name
			Model = `italirsx`, -- Vehicle model name
			PricePerMinute = 45, -- Rental cost per minute for using this vehicle
			UnlockFee = 100, -- Initial fee to unlock and start using the vehicle
			DamagePenalty = {
				Enabled = true, -- Enable or disable penalties for vehicle damage
				PenaltyPrice = 170, -- Amount charged when the vehicle is damaged
				DamagePercentForPenalty = 5, -- Percentage of damage required to trigger the penalty (1 = very sensitive, 100 = vehicle must be destroyed)
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

	DebugMode = false, -- Adds print statements for debugging purposes
}
