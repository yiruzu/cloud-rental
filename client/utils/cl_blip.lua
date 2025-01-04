local CreateZoneBlip = function(coords, config, radius, size)
	local iconBlip = AddBlipForCoord(coords.x, coords.y, coords.z)
	SetBlipSprite(iconBlip, config.Sprite)
	SetBlipDisplay(iconBlip, 4)
	SetBlipScale(iconBlip, config.Scale)
	SetBlipColour(iconBlip, config.Color)
	SetBlipAsShortRange(iconBlip, true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString(config.Name)
	EndTextCommandSetBlipName(iconBlip)

	local radiusBlip = AddBlipForRadius(coords.x, coords.y, coords.z, size)
	SetBlipSprite(radiusBlip, radius.Sprite)
	SetBlipColour(radiusBlip, radius.Color)
	SetBlipAlpha(radiusBlip, radius.Alpha)
end

local CreateVehicleBlip = function(vehicle, config)
	local vehicleBlip = AddBlipForEntity(vehicle)
	SetBlipSprite(vehicleBlip, config.Sprite)
	SetBlipDisplay(vehicleBlip, 4)
	SetBlipScale(vehicleBlip, config.Scale)
	SetBlipColour(vehicleBlip, config.Color)
	SetBlipAsShortRange(vehicleBlip, true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString(config.Name)
	EndTextCommandSetBlipName(vehicleBlip)
end

return {
	Zone = CreateZoneBlip,
	Vehicle = CreateVehicleBlip,
}
