-- Configuration
local Config = require("config.cfg_main")

local IsVehicleMatching = function(tableName, vehicle)
	local vehTable = {}

	if tableName == "SpawnedVehicles" then
		vehTable = VehiclesStore.SpawnedVehicles
	elseif tableName == "RentedVehicles" then
		vehTable = VehiclesStore.RentedVehicles
	else
		return false
	end

	for _, vehData in pairs(vehTable) do
		if vehData.handle == vehicle then
			if vehData.plate == GetVehicleNumberPlateText(vehicle) then return true end
		end
	end

	return false
end

local IsVehicleOwner = function(vehicle, playerId)
	for i = 1, #VehiclesStore.RentedVehicles do
		if VehiclesStore.RentedVehicles[i].handle == vehicle then
			if VehiclesStore.RentedVehicles[i].ownerId == playerId then return true end
		end
	end
	return false
end

local GetVehicleConfig = function(vehicle)
	for _, location in pairs(Config.Locations) do
		for _, vehConfig in pairs(location.Vehicles) do
			if vehConfig.Model == GetEntityModel(vehicle) then return vehConfig end
		end
	end
	return nil
end

return {
	IsMatching = IsVehicleMatching,
	IsOwner = IsVehicleOwner,
	Config = GetVehicleConfig,
}
