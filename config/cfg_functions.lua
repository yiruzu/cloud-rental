--- Sends a notification to a specific player on the client.
---@param msg string -- Notification message
---@param type string -- Notification type (e.g., "success", "error", "info")
function ClientNotify(msg, type)
	lib.notify({
		title = "Rental",
		description = msg,
		type = type,
		position = "top-center",
		duration = 5000,
	})
end

--- Sends a notification to a specific player on the server.
---@param source number -- Player's source ID
---@param msg string -- Notification message
---@param type string -- Notification type (e.g., "success", "error", "info")
function ServerNotify(source, msg, type)
	TriggerClientEvent("ox_lib:notify", source, {
		title = "Rental",
		description = msg,
		type = type,
		position = "top-center",
		duration = 5000,
	})
end

--- Adds the specified amount of fuel to the vehicle.
--- @param vehicle integer -- The entity ID of the vehicle.
function VehFuel(vehicle)
	--SetVehicleFuelLevel(vehicle, 100)
	Entity(vehicle).state.fuel = 100
	-- Replace with your custom fuel system if needed
end

--- Gives the player keys to the specified vehicle.
--- @param vehicle integer -- The entity ID of the vehicle.
function VehKeys(vehicle)
	local vehiclePlate = GetVehicleNumberPlateText(vehicle)
	-- Replace with your vehicle keys system if needed
end
