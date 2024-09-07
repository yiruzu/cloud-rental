local Config = require("shared.sh_config")

local DebugMode = Config.DebugMode

local countdownInterval = 1000
local rentalTimer = {
	timeLeft = Config.MaxParkingTime,
	lastUpdate = GetGameTimer(),
	isActive = false,
	totalPrice = 0,
}

local InitializeRentalTimer = function()
	rentalTimer.timeLeft = Config.MaxParkingTime
	rentalTimer.lastUpdate = GetGameTimer()
	rentalTimer.isActive = true
	rentalTimer.totalPrice = 0
end

local UpdateRentalTimer = function(ownedVehicles)
	if not rentalTimer.isActive then return end

	local currentTime = GetGameTimer()

	if currentTime - rentalTimer.lastUpdate >= countdownInterval then
		rentalTimer.timeLeft = rentalTimer.timeLeft - 1
		rentalTimer.lastUpdate = currentTime

		if rentalTimer.timeLeft <= 0 then
			rentalTimer.isActive = false
			if DebugMode then print("Time's up for the rental.") end

			lib.callback.await("cloud-rental:server:HandleEndRental", false, rentalTimer.totalPrice)
			lib.callback.await("cloud-rental:server:InRental", false, false)

			for i = #ownedVehicles, 1, -1 do
				local ownedVeh = ownedVehicles[i].handle
				NetworkFadeOutEntity(ownedVeh, false, false)
				Wait(1000)
				DeleteVehicle(ownedVeh)
				table.remove(ownedVehicles, i)
				if DebugMode then print("[Timer] Vehicle Deleted") end
			end
			TriggerEvent("cloud-rental:client:ResetRental")
		end
	end
end

return { Update = UpdateRentalTimer, Initialize = InitializeRentalTimer, Data = rentalTimer }
