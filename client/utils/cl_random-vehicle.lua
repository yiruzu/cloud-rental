local remainingVehicleTypes = {}

local function InitializeVehicleTypes(location)
	table.wipe(remainingVehicleTypes)
	for _, vehicle in pairs(location.Vehicles) do
		table.insert(remainingVehicleTypes, vehicle)
	end
end

local GetRandomVehicle = function(location)
	if #remainingVehicleTypes == 0 then InitializeVehicleTypes(location) end
	local index = math.random(#remainingVehicleTypes)
	return table.remove(remainingVehicleTypes, index)
end

return GetRandomVehicle
