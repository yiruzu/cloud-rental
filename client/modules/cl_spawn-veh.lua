local Config = require("shared.sh_config")

local DebugMode = Config.DebugMode

local spawnedVehicles = {}

local SpawnPreviewVehicles = function(vehModel, vehPos)
	if not IsModelInCdimage(vehModel) or not IsModelAVehicle(vehModel) then
		if DebugMode then print("Vehicle hash is not valid, failed to spawn vehicle.") end
		return false
	end

	lib.requestModel(vehModel)
	local veh = CreateVehicle(vehModel, vehPos.x, vehPos.y, vehPos.z - 1, vehPos.w, false, false)
	while not DoesEntityExist(veh) do
		Wait(10)
	end

	if veh then
		SetVehicleOnGroundProperly(veh)
		FreezeEntityPosition(veh, true)
		SetEntityInvincible(veh, true)
		SetDisableVehicleWindowCollisions(veh, true)
		SetVehicleDoorsLocked(veh, 3)
		SetVehicleDirtLevel(veh, 0)
		if Config.VehicleColor.Enabled then
			SetVehicleCustomPrimaryColour(veh, Config.VehicleColor.Primary[1], Config.VehicleColor.Primary[2], Config.VehicleColor.Primary[3])
			SetVehicleCustomSecondaryColour(veh, Config.VehicleColor.Secondary[1], Config.VehicleColor.Secondary[2], Config.VehicleColor.Secondary[3])
		end
		SetModelAsNoLongerNeeded(veh)

		table.insert(spawnedVehicles, { handle = veh, plate = GetVehicleNumberPlateText(veh), ownerId = nil })
		return veh
	end
end

local SpawnVehicle = function(vehModel, vehPos)
	local veh

	if not IsModelInCdimage(vehModel) or not IsModelAVehicle(vehModel) then
		if DebugMode then print("Vehicle hash is not valid, failed to spawn vehicle.") end
		return false
	end

	local netId = lib.callback.await("cloud-rental:server:CreateVehicleSV", false, vehModel, vehPos)

	if DebugMode then print("NetId [1]:", netId) end

	veh = lib.waitFor(function()
		if DebugMode then print("Waiting for vehicle") end
		if NetworkDoesEntityExistWithNetworkId(netId) then return NetToVeh(netId) end
	end, "Could not load entity in time.", 1000)

	if DebugMode then print("NetId [2]:", netId) end

	if not netId or netId == 0 then
		if DebugMode then print("An error occurred while attempting to spawn the vehicles.") end
		return false
	end

	while not DoesEntityExist(veh) do
		Wait(10)
	end

	if veh then
		SetVehicleOnGroundProperly(veh)
		SetVehicleDirtLevel(veh, 0)
		if Config.VehicleColor.Enabled then
			SetVehicleCustomPrimaryColour(veh, Config.VehicleColor.Primary[1], Config.VehicleColor.Primary[2], Config.VehicleColor.Primary[3])
			SetVehicleCustomSecondaryColour(veh, Config.VehicleColor.Secondary[1], Config.VehicleColor.Secondary[2], Config.VehicleColor.Secondary[3])
		end
		VehFuel(veh)
		SetVehRadioStation(veh, "OFF")
		SetModelAsNoLongerNeeded(veh)
		return veh
	end
end

return { SpawnPreview = SpawnPreviewVehicles, Spawn = SpawnVehicle, GetSpawned = spawnedVehicles }
