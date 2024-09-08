ClientNotify = function(text, locale)
	lib.notify({
		title = locale.title,
		description = text,
		duration = 5000,
		position = "top",
		type = locale.type,
	})
end

ServerNotify = function(source, text, locale)
	TriggerClientEvent("ox_lib:notify", source, {
		title = locale.title,
		description = text,
		duration = 5000,
		position = "top",
		type = locale.type,
	})
end

VehFuel = function(vehicle)
	--SetVehicleFuelLevel(vehicle, 100)
	Entity(vehicle).state.fuel = 100
	-- Replace with your custom fuel system if needed
end

VehKeys = function(vehicle)
	local vehiclePlate = GetVehicleNumberPlateText(vehicle)
	-- Replace with your vehicle keys system if needed
end
