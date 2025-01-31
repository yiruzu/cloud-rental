-- Utils
local DebugPrint = require("shared.utils.sh_debug-print")

local function RemoveVehicle()
	for i = #VehiclesStore.RentedVehicles, 1, -1 do
		local rentedVeh = VehiclesStore.RentedVehicles[i].handle
		if not DoesEntityExist(rentedVeh) then break end

		if IsPedInVehicle(cache.ped, rentedVeh, false) then
			TaskLeaveVehicle(cache.ped, rentedVeh, 0)
			Wait(1500)
		end

		NetworkFadeOutEntity(rentedVeh, false, false)
		Wait(1000)
		DeleteVehicle(rentedVeh)
		table.remove(VehiclesStore.RentedVehicles, i)
		break
	end
end

local RemoveAllVehicles = function()
	local vehTables = { VehiclesStore.SpawnedVehicles, VehiclesStore.RentedVehicles }
	for _, vehTable in pairs(vehTables) do
		for i = #vehTable, 1, -1 do
			local vehicle = vehTable[i].handle
			DeleteVehicle(vehicle)
		end
		table.wipe(vehTable)
	end
	DebugPrint("All vehicles have been deleted.", "info")
end

local SetVehicleOwner = function(vehicle, playerId)
	local vehData = {
		handle = vehicle,
		plate = GetVehicleNumberPlateText(vehicle),
		ownerId = playerId,
	}
	table.insert(VehiclesStore.RentedVehicles, vehData)
end

local EndRentalRide = function()
	PlayerState.isRentingVehicle = false
	TimerState.Active = false
	lib.callback.await("cloud-rental:server:HandleEndRental", false, TimerState.TotalPrice)
	lib.callback.await("cloud-rental:server:InRental", false, false)
	RemoveVehicle()
end

return {
	RemoveAll = RemoveAllVehicles,
	SetOwner = SetVehicleOwner,
	EndRide = EndRentalRide,
}
