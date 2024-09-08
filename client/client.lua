--[[ LOAD FILES ]]

local Config = require("shared.sh_config")
local Locales = require("shared.sh_locales")

local VEH_STATE = require("client.modules.cl_veh-state")
local SPAWN_VEH = require("client.modules.cl_spawn-veh")
local VEHICLE_TIMER = require("client.modules.cl_veh-timer")
local FORMATTED_TEXT = require("client.modules.cl_formatted-text")

--[[ VARIABLES ]]

local DebugMode = Config.DebugMode
local inRental, isInZone = false, false
local lastVehicle = 0
local blipVehicle

--[[ TABLES ]]

local spawnedVehicles = SPAWN_VEH.GetSpawned
local ownedVehicles = VEH_STATE.GetOwned
local remainingVehicleTypes = {}

--[[ VEHICLE UTILITY FUNCTIONS ]]

local InitializeVehicleTypes = function(location)
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

local DeleteAllVehicles = function()
	local vehicleLists = { spawnedVehicles, ownedVehicles }
	for _, vehicleList in pairs(vehicleLists) do
		for i = #vehicleList, 1, -1 do
			DeleteVehicle(vehicleList[i].handle)
		end
		table.wipe(vehicleList)
	end
	if DebugMode then print("All vehicles have been deleted.") end
end

local RemoveVehicle = function(vehicle)
	for i = #ownedVehicles, 1, -1 do
		local ownedVeh = ownedVehicles[i].handle
		if ownedVeh == vehicle then
			if IsPedInVehicle(cache.ped, vehicle, false) then
				TaskLeaveVehicle(cache.ped, ownedVeh, 0)
				Wait(1500)
			end
			NetworkFadeOutEntity(ownedVeh, false, false)
			Wait(1000)
			DeleteVehicle(ownedVeh)
			table.remove(ownedVehicles, i)
			break
		end
	end
end

local GetVehicleData = function(vehicle)
	for _, vehicleData in pairs(Config.Vehicles) do
		if vehicleData.Model == GetEntityModel(vehicle) then return vehicleData end
	end
	return nil
end

-- [[ VISUAL UTILITY FUNCTIONS ]]

local CreateBlips = function(pos, blipIcon, blipRadius, size)
	local blipIconHandle = AddBlipForCoord(pos.x, pos.y, pos.z)
	SetBlipSprite(blipIconHandle, blipIcon.Sprite)
	SetBlipDisplay(blipIconHandle, 4)
	SetBlipScale(blipIconHandle, blipIcon.Scale)
	SetBlipColour(blipIconHandle, blipIcon.Color)
	SetBlipAsShortRange(blipIconHandle, true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString(blipIcon.Name)
	EndTextCommandSetBlipName(blipIconHandle)

	local blipRadiusHandle = AddBlipForRadius(pos.x, pos.y, pos.z, size)
	SetBlipSprite(blipRadiusHandle, blipRadius.Sprite)
	SetBlipColour(blipRadiusHandle, blipRadius.Color)
	SetBlipAlpha(blipRadiusHandle, blipRadius.Alpha)
end

local CreateVehicleBlip = function(entity, blipIcon)
	blipVehicle = AddBlipForEntity(entity)
	SetBlipSprite(blipVehicle, blipIcon.Sprite)
	SetBlipDisplay(blipVehicle, 4)
	SetBlipScale(blipVehicle, blipIcon.Scale)
	SetBlipColour(blipVehicle, blipIcon.Color)
	SetBlipAsShortRange(blipVehicle, true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString(blipIcon.Name)
	EndTextCommandSetBlipName(blipVehicle)
end

local FloatingHelpText = function(msg, vehicle)
	local vehCoords = GetEntityCoords(vehicle)
	local _, maxZ = GetModelDimensions(GetEntityModel(vehicle))
	local helpTextPosition = vector3(vehCoords.x, vehCoords.y, vehCoords.z + maxZ)

	AddTextEntry("FloatingHelpText", msg)
	-- SetFloatingHelpTextToEntity(1, vehicle, 0.0, 0.0)
	SetFloatingHelpTextWorldPosition(1, helpTextPosition.x, helpTextPosition.y, helpTextPosition.z)
	SetFloatingHelpTextStyle(1, 1, 2, -1, 3, 0)
	BeginTextCommandDisplayHelp("FloatingHelpText")
	EndTextCommandDisplayHelp(2, false, false, -1)
end

local FormatTime = function(rawSeconds)
	local minutes = math.floor(rawSeconds / 60)
	local seconds = rawSeconds % 60
	return string.format("%dm %ds", minutes, seconds)
end

--[[ MAIN LOGIC ]]

lib.onCache("vehicle", function(vehicle)
	if not vehicle or vehicle == 0 then return end
	local priceInterval, lastPriceInterval, lastHealth = 60000, GetGameTimer(), 0
	CreateThread(function()
		while IsPedInVehicle(cache.ped, vehicle, false) do
			if VEH_STATE.Matching("ownedVehicles", vehicle, spawnedVehicles) and VEH_STATE.OwnerMatching(vehicle, cache.serverId) then
				if not VEHICLE_TIMER.Data.isActive then VEHICLE_TIMER.Initialize() end

				local vehData = GetVehicleData(vehicle)
				if vehData then
					local timerData = VEHICLE_TIMER.Data
					local currentTime = GetGameTimer()
					timerData.timeLeft = Config.MaxParkingTime
					timerData.lastUpdate = currentTime

					if vehData.DamagePenalty.Enabled then
						-- local currentHealth = GetVehicleEngineHealth(vehicle)
						local currentHealth = GetVehicleBodyHealth(vehicle)
						if lastHealth == 0 then lastHealth = currentHealth end

						if currentHealth < lastHealth - (1000 * (vehData.DamagePenalty.DamagePercentForPenalty / 100)) then
							lib.callback.await("cloud-rental:server:HandlePenalty", false, GetEntityModel(vehicle))
							lastHealth = currentHealth
						end
					end

					if currentTime - lastPriceInterval >= priceInterval then
						lastPriceInterval = currentTime
						timerData.totalPrice = timerData.totalPrice + vehData.PricePerMinute
						if DebugMode then print("Total price for vehicle " .. vehicle .. ": " .. timerData.totalPrice) end

						local moneyAvailable = lib.callback.await("cloud-rental:server:GetPlayerMoney", false)
						local amount = vehData.DamagePenalty.PenaltyPrice
						local hasEnoughMoney = moneyAvailable.wallet >= amount or moneyAvailable.bank >= amount

						if not hasEnoughMoney then
							ClientNotify(Locales.Notification.NoMoney.text, Locales.Notification.NoMoney)
							lib.callback.await("cloud-rental:server:HandleEndRental", false, timerData.totalPrice)
							lib.callback.await("cloud-rental:server:InRental", false, false)
							RemoveVehicle(vehicle)
							inRental = false
							timerData.isActive = false
							return
						end
					end
				end
			end
			Wait(1000)
		end
	end)
end)

local InRentalThread = function()
	ClearAllHelpMessages()
	local playerName = lib.callback.await("cloud-rental:server:GetPlayerName", false)

	while inRental do
		local waitTime = 1000
		local playerCoords = GetEntityCoords(cache.ped)
		local nearbyVehicles = lib.getNearbyVehicles(playerCoords, Config.DisplayDistance + 0.1, false)

		VEHICLE_TIMER.Update(ownedVehicles)

		for i = 1, #nearbyVehicles do
			local vehicle = nearbyVehicles[i].vehicle
			local distance = #(playerCoords - nearbyVehicles[i].coords)
			if distance < Config.DisplayDistance then
				if VEH_STATE.Matching("ownedVehicles", vehicle, spawnedVehicles) and VEH_STATE.OwnerMatching(vehicle, cache.serverId) then
					local vehData = GetVehicleData(vehicle)

					if vehData then
						local timerData = VEHICLE_TIMER.Data

						FloatingHelpText(FORMATTED_TEXT.Vehicle.Owned(vehData, timerData.totalPrice, playerName), vehicle)
						AddTextEntry("TimerInfo", Locales.TimeLeft:format(FormatTime(timerData.timeLeft)))
						BeginTextCommandDisplayHelp("TimerInfo")
						EndTextCommandDisplayHelp(0, false, false, -1)

						if distance < Config.InteractDistance then
							if IsControlJustReleased(0, 38) and not (IsPedDeadOrDying(cache.ped, true) or IsPedFatallyInjured(cache.ped)) then
								local endRideDialog = lib.alertDialog({
									header = FORMATTED_TEXT.Dialog.EndRental(vehData),
									centered = true,
									cancel = true,
									size = "xs",
								})
								if endRideDialog == "confirm" then
									lib.callback.await("cloud-rental:server:HandleEndRental", false, timerData.totalPrice)
									lib.callback.await("cloud-rental:server:InRental", false, false)
									RemoveBlip(blipVehicle)
									RemoveVehicle(vehicle)
									inRental = false
									timerData.isActive = false
								end
							end
						end
					end
					waitTime = 0
				elseif VEH_STATE.Matching("ownedVehicles", vehicle, spawnedVehicles) then
					local vehData = GetVehicleData(vehicle)
					if vehData then
						FloatingHelpText(FORMATTED_TEXT.Vehicle.NotOwned(vehData, playerName), vehicle)
						waitTime = 0
					end
				end
			end
		end
		Wait(waitTime)
	end
end

--[[ ZONES ]]

-- Credits to https://github.com/JvstDev for improving the logic of this function in some parts
local CreateZones = function(location)
	local rentalZone = lib.zones.sphere({
		coords = location.CenterPosition,
		radius = location.Radius,
		inside = function()
			while isInZone do
				local waitTime = 1000
				local playerCoords = GetEntityCoords(cache.ped)
				local nearbyVehicles = lib.getNearbyVehicles(playerCoords, Config.DisplayDistance + 0.1, false)

				for i = 1, #nearbyVehicles do
					local vehicle = nearbyVehicles[i].vehicle
					local distance = #(playerCoords - nearbyVehicles[i].coords)
					if distance < Config.DisplayDistance and VEH_STATE.Matching("spawnedVehicles", vehicle, spawnedVehicles) then
						local vehData = GetVehicleData(vehicle)

						if vehData then
							if vehicle ~= lastVehicle then
								lastVehicle = vehicle
							else
								FloatingHelpText(FORMATTED_TEXT.Vehicle.Zone(vehData), vehicle)

								if distance < Config.InteractDistance then
									if IsControlJustReleased(0, 38) and not (IsPedDeadOrDying(cache.ped, true) or IsPedFatallyInjured(cache.ped)) then
										if inRental then
											lib.alertDialog({
												header = Locales.Dialog.AlreadyRented,
												centered = true,
												size = "xs",
											})
										else
											local rentVehicle = lib.alertDialog({
												header = FORMATTED_TEXT.Dialog.Rent(vehData),
												centered = true,
												cancel = true,
												size = "xs",
											})

											if rentVehicle == "confirm" then
												local spawnPosition

												for _, vehiclePos in ipairs(location.SpawnPositions) do
													if not IsAnyVehicleNearPoint(vehiclePos.x, vehiclePos.y, vehiclePos.z, 3.0) then
														spawnPosition = vehiclePos
														break
													end
												end

												if spawnPosition then
													lib.callback.await("cloud-rental:server:InRental", false, true)
													local success = lib.callback.await("cloud-rental:server:HandleStartRental", false, GetEntityModel(vehicle))

													if success then
														PlaySoundFrontend(-1, "ROBBERY_MONEY_TOTAL", "HUD_FRONTEND_CUSTOM_SOUNDSET", true)
														if IsPedInAnyVehicle(cache.ped, false) then TaskLeaveAnyVehicle(cache.ped, 0, 16) end

														ClientNotify(Locales.Notification.RentedVehicle.text:format(vehData.DisplayName), Locales.Notification.RentedVehicle)

														local serverVeh = SPAWN_VEH.Spawn(vehData.Model, vec4(spawnPosition.x, spawnPosition.y, spawnPosition.z, spawnPosition.w))
														if serverVeh then
															VEH_STATE.SetOwner(serverVeh, cache.serverId)
															CreateVehicleBlip(serverVeh, Config.VehicleBlip)

															if Config.VehicleKeys then VehKeys(serverVeh) end
															if Config.FuelSystem then VehFuel(serverVeh) end

															inRental = true
															CreateThread(InRentalThread)
														end
													else
														lib.callback.await("cloud-rental:server:InRental", false, false)
													end
												else
													PlaySoundFrontend(-1, "CHECKPOINT_MISSED", "HUD_MINI_GAME_SOUNDSET", true)
													lib.alertDialog({
														header = Locales.NoParkingSlots,
														content = Locales.NoParkingSlotsDesc,
														centered = true,
														size = "xs",
													})
												end
											end
										end
									end
								end
							end
						end
						waitTime = 0
					end
				end

				Wait(waitTime)
			end
		end,
	})

	function rentalZone:onEnter()
		if DebugMode then print("Entered range of zone:", self.id) end
		isInZone = true
	end

	function rentalZone:onExit()
		if DebugMode then print("Left range of zone", self.id) end
		isInZone = false
	end
end

--[[ INITIALIZATION ]]

for _, location in pairs(Config.Locations) do
	CreateBlips(location.CenterPosition, location.BlipIcon, location.BlipRadius, location.Radius)
	CreateZones(location)

	for _, vehiclePos in ipairs(location.VehiclePositions) do
		local randomVeh = GetRandomVehicle(location)
		if DebugMode then print("[CLIENT] Spawning Vehicle:", randomVeh.Model, "at position:", vehiclePos) end
		SPAWN_VEH.SpawnPreview(randomVeh.Model, vehiclePos)
	end
end

--[[ EVENTS ]]

AddEventHandler("onResourceStop", function(resourceName)
	if GetCurrentResourceName() ~= resourceName then return end
	DeleteAllVehicles()
end)

RegisterNetEvent("cloud-rental:client:ResetRental")
AddEventHandler("cloud-rental:client:ResetRental", function()
	inRental = false
end)
