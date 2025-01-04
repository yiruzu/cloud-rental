-- Stores
local PlayerState = require("client.stores.cl_player")
local VehiclesStore = require("client.stores.cl_vehicles")
local TimerState = require("client.stores.cl_timer")

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
	if not TimerState.GetState().isActive then return end

	local currentTime = GetGameTimer()

	local countdownInterval = 1000
	if currentTime - TimerState.GetState().lastUpdate >= countdownInterval then
		TimerState.GetState().timeLeft = TimerState.GetState().timeLeft - 1
		TimerState.UpdateLastTime()

		if not DoesRentalExist() then return end

		if TimerState.GetState().timeLeft <= 0 then
			DebugPrint("Time's up for the rental.", "info")
			ManageVehicle.EndRide()
		end
	end
end

return UpdateRentalTimer
