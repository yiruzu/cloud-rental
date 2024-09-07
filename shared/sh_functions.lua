ClientNotify = function(text, locale)
	exports["cloud-hud"]:Notify(locale.title, text, locale.type, 5000)
end

ServerNotify = function(source, text, locale)
	TriggerClientEvent("cloud-hud:client:Notify", source, locale.title, text, locale.type, 5000)
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
