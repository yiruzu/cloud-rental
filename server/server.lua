local Config = require("shared.sh_config")
local DebugMode = Config.DebugMode

local CreateVehicleSV = function(_, vehModel, vehPos)
	if DebugMode then print("[SERVER] Creating Vehicle:", vehModel, "at position:", vehPos) end
	local veh = CreateVehicle(vehModel, vehPos.x, vehPos.y, vehPos.z, vehPos.w, true, true)
	local playerPed = GetPlayerPed(source)

	while not DoesEntityExist(veh) do
		Wait(10)
	end

	if Config.WarpPed then TaskWarpPedIntoVehicle(playerPed, veh, -1) end
	SetVehicleDoorsLocked(veh, 1)

	return NetworkGetNetworkIdFromEntity(veh)
end

lib.callback.register("cloud-rental:server:CreateVehicleSV", CreateVehicleSV)
