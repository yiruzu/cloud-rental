local ownedVehicles = {}

local VehicleMatching = function(tableName, vehicle, spawnedVehicles)
	local vehicleTables = {}

	if tableName == "spawnedVehicles" then
		vehicleTables = { spawnedVehicles }
	elseif tableName == "ownedVehicles" then
		vehicleTables = { ownedVehicles }
	else
		return false
	end

	for i = 1, #vehicleTables do
		for _, vehicleData in pairs(vehicleTables[i]) do
			if vehicleData.handle == vehicle then
				if vehicleData.plate == GetVehicleNumberPlateText(vehicle) then return true end
			end
		end
	end
	return false
end

local VehicleOwnerMatching = function(vehicle, playerId)
	for i = 1, #ownedVehicles do
		if ownedVehicles[i].handle == vehicle then
			if ownedVehicles[i].ownerId == playerId then return true end
		end
	end
	return false
end

local SetVehicleOwner = function(vehicle, playerId)
	local vehicleData = {
		handle = vehicle,
		plate = GetVehicleNumberPlateText(vehicle),
		ownerId = playerId,
	}
	table.insert(ownedVehicles, vehicleData)
end

return { Matching = VehicleMatching, OwnerMatching = VehicleOwnerMatching, SetOwner = SetVehicleOwner, GetOwned = ownedVehicles }
