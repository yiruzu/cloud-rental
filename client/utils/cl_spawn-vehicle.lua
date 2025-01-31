-- Configuration
local Config = require("config.cfg_main")

-- Utils
local DebugPrint = require("shared.utils.sh_debug-print")

local SpawnPreviewVehicles = function(vehModel, vehPos)
	if not IsModelInCdimage(vehModel) or not IsModelAVehicle(vehModel) then
		DebugPrint("Vehicle hash is not valid, failed to spawn vehicle.", "error")
		return nil
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

		table.insert(VehiclesStore.SpawnedVehicles, { handle = veh, plate = GetVehicleNumberPlateText(veh), ownerId = nil })
		return veh
	end
	return nil
end

local SpawnVehicle = function(vehHandle, vehModel, vehPos)
	local veh

	if not IsModelInCdimage(vehModel) or not IsModelAVehicle(vehModel) then
		DebugPrint("Vehicle hash is not valid, failed to spawn vehicle.", "error")
		return nil
	end

	local netId = lib.callback.await("cloud-rental:server:CreateVehicleSV", false, vehModel, GetVehicleType(vehHandle), vehPos)

	DebugPrint("NetId [1]:", netId, "info")

	veh = lib.waitFor(function()
		DebugPrint("Waiting for vehicle", "info")
		if NetworkDoesEntityExistWithNetworkId(netId) then return NetToVeh(netId) end
	end, "Could not load vehicle in time.", 3000)

	DebugPrint("NetId [2]:", netId, "info")

	if not netId or netId == 0 then
		DebugPrint("An error occurred while attempting to spawn the vehicles.", "error")
		return nil
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
	return nil
end

return { SpawnPreview = SpawnPreviewVehicles, Spawn = SpawnVehicle }
