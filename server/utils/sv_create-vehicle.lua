-- Configuration
local Config = require("configuration.config")

-- Utils
local DebugPrint = require("shared.utils.sh_debug-print")

local CreateVehicleSV = function(_, vehModel, vehType, vehPos)
	DebugPrint("Creating Vehicle:", vehModel, "at position:", vehPos, "info")
	local veh = CreateVehicleServerSetter(vehModel, vehType, vehPos.x, vehPos.y, vehPos.z, vehPos.w)
	local playerPed = GetPlayerPed(source)

	veh = lib.waitFor(function()
		DebugPrint("Waiting for vehicle creation", "info")
		if veh and veh ~= 0 and NetworkGetEntityOwner(veh) ~= -1 then return veh end
	end, "Could not create vehicle in time.", 3000)

	if not veh or veh == 0 then
		DebugPrint("Vehicle creation failed or timed out.", "error")
		return nil
	end

	SetEntityOrphanMode(veh, 2)
	if Config.WarpPed then TaskWarpPedIntoVehicle(playerPed, veh, -1) end
	SetVehicleDoorsLocked(veh, 1)

	return NetworkGetNetworkIdFromEntity(veh)
end
lib.callback.register("cloud-rental:server:CreateVehicleSV", CreateVehicleSV)
