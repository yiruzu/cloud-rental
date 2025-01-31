-- Utils
local DebugPrint = require("shared.utils.sh_debug-print")
local ManageVehicle = require("client.utils.cl_manage-vehicle")

local function DoesRentalExist()
	for i = #VehiclesStore.RentedVehicles, 1, -1 do
		local rentedVeh = VehiclesStore.RentedVehicles[i].handle
		if DoesEntityExist(rentedVeh) then return true end

		DebugPrint("Rented vehicle no longer exists. Timer reset.", "info")
		ManageVehicle.EndRide()
		return false
	end
	return true
end

local UpdateRentalTimer = function()
	if not TimerState.Active then return end

	local currentTime = GetGameTimer()

	local countdownInterval = 1000
	if currentTime - TimerState.LastUpdate >= countdownInterval then
		TimerState.TimeLeft = TimerState.TimeLeft - 1
		TimerState.LastUpdate = GetGameTimer()

		if not DoesRentalExist() then return end

		if TimerState.TimeLeft <= 0 then
			DebugPrint("Time's up for the rental.", "info")
			ManageVehicle.EndRide()
		end
	end
end

return UpdateRentalTimer
