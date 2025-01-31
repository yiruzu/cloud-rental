-- Configuration
local Config = require("config.cfg_main")
local Locales = require("config.cfg_locales")

-- Utils
local DebugPrint = require("shared.utils.sh_debug-print")
local SpawnVehicle = require("client.utils.cl_spawn-vehicle")
local GetVehicle = require("client.utils.cl_get-vehicle")
local ManageVehicle = require("client.utils.cl_manage-vehicle")
local UpdateTimer = require("client.utils.cl_update-timer")
local FormattedText = require("client.utils.cl_formatted-text")
local Scaleform = require("client.utils.cl_scaleform")
local CreateBlip = require("client.utils.cl_blip")
local GetRandomVehicle = require("client.utils.cl_random-vehicle")

local function MonitorVehicle(vehicle)
	if not vehicle or vehicle == 0 then return end

	local priceInterval = 60000
	local lastPriceInterval = GetGameTimer()
	local lastHealth = 0

	CreateThread(function()
		local isVehMatching = GetVehicle.IsMatching("RentedVehicles", vehicle) and GetVehicle.IsOwner(vehicle, cache.serverId)
		while IsPedInVehicle(cache.ped, vehicle, false) and isVehMatching do
			if not TimerState.Active then
				TimerState:Reset()
				TimerState.Active = true
			end

			local vehConfig = GetVehicle.Config(vehicle)
			if not vehConfig then break end

			local currentTime = GetGameTimer()
			TimerState.TimeLeft = Config.MaxParkingTime
			TimerState.LastUpdate = GetGameTimer()

			if vehConfig.DamagePenalty.Enabled then
				local currentHealth = GetVehicleBodyHealth(vehicle)
				if lastHealth == 0 then lastHealth = currentHealth end

				if currentHealth < lastHealth - (1000 * (vehConfig.DamagePenalty.DamagePercentForPenalty / 100)) then
					lib.callback.await("cloud-rental:server:HandlePenalty", false, GetEntityModel(vehicle))
					lastHealth = currentHealth
				end
			end

			if currentTime - lastPriceInterval >= priceInterval then
				lastPriceInterval = currentTime
				TimerState.TotalPrice = TimerState.TotalPrice + vehConfig.PricePerMinute
				DebugPrint("Total price for vehicle " .. vehicle .. ": " .. TimerState.TotalPrice, "info")

				local moneyAvailable = lib.callback.await("cloud-rental:server:GetPlayerMoney", false)
				local amount = vehConfig.DamagePenalty.PenaltyPrice
				local hasEnoughMoney = moneyAvailable.wallet >= amount or moneyAvailable.bank >= amount

				if not hasEnoughMoney then
					ClientNotify(Locales.Notification.NoMoney, "error")
					ManageVehicle.EndRide()
					return
				end
			end

			Wait(1000)
		end
	end)
end
lib.onCache("vehicle", MonitorVehicle)

local function InRentalThread()
	ClearAllHelpMessages()
	local playerName = lib.callback.await("cloud-rental:server:GetPlayerName", false)

	while PlayerState.isRentingVehicle do
		local waitTime = 1000
		local playerCoords = GetEntityCoords(cache.ped)
		local nearbyVehicles = lib.getNearbyVehicles(playerCoords, Config.DisplayDistance + 0.1, false)

		UpdateTimer()

		for i = 1, #nearbyVehicles do
			local vehicle = nearbyVehicles[i].vehicle
			local distance = #(playerCoords - nearbyVehicles[i].coords)

			if distance >= Config.DisplayDistance then break end

			if GetVehicle.IsMatching("RentedVehicles", vehicle) then
				if GetVehicle.IsOwner(vehicle, cache.serverId) then
					local vehConfig = GetVehicle.Config(vehicle)
					if not vehConfig then break end

					Scaleform.FloatingHelpText(FormattedText.Vehicle.Owned(vehConfig, TimerState.TotalPrice, playerName), vehicle)
					Scaleform.HelpText(Locales.VehicleHelpText.TimeLeft:format(FormattedText.Format.Time(TimerState.TimeLeft)))

					if distance >= Config.InteractDistance then break end

					if IsControlJustReleased(0, 38) then
						if IsPlayerDead(cache.playerId) then break end

						local endRideDialog = lib.alertDialog({
							header = FormattedText.Dialog.EndRental(vehConfig),
							centered = true,
							cancel = true,
							size = "xs",
						})
						if endRideDialog == "confirm" then
							PlaySoundFrontend(-1, "Click", "DLC_HEIST_HACKING_SNAKE_SOUNDS", true)
							ManageVehicle.EndRide()
						end
					end

					waitTime = 0
				else
					local vehConfig = GetVehicle.Config(vehicle)
					if not vehConfig then break end

					Scaleform.FloatingHelpText(FormattedText.Vehicle.NotOwned(vehConfig, playerName), vehicle)
					waitTime = 0
				end
			end
		end

		Wait(waitTime)
	end
end

local function OpenRentDialog(vehConfig, vehicle, location)
	local rentVehicle = lib.alertDialog({
		header = FormattedText.Dialog.Rent(vehConfig),
		centered = true,
		cancel = true,
		size = "xs",
	})

	if rentVehicle == "confirm" then
		local spawnPosition
		for _, vehiclePos in ipairs(location.SpawnPositions) do
			if not IsAnyVehicleNearPoint(vehiclePos.x, vehiclePos.y, vehiclePos.z, 4.0) then
				spawnPosition = vehiclePos
				break
			end
		end

		if not spawnPosition then
			PlaySoundFrontend(-1, "CHECKPOINT_MISSED", "HUD_MINI_GAME_SOUNDSET", true)
			lib.alertDialog({
				header = Locales.Dialog.NoParkingSlots,
				content = Locales.Dialog.NoParkingSlotsDesc,
				centered = true,
				size = "xs",
			})
			return
		end

		lib.callback.await("cloud-rental:server:InRental", false, true)
		local success = lib.callback.await("cloud-rental:server:HandleStartRental", false, GetEntityModel(vehicle))

		if success then
			PlaySoundFrontend(-1, "Click", "DLC_HEIST_HACKING_SNAKE_SOUNDS", true)
			if IsPedInAnyVehicle(cache.ped, false) then TaskLeaveAnyVehicle(cache.ped, 0, 16) end

			local serverVeh = SpawnVehicle.Spawn(vehicle, vehConfig.Model, vec4(spawnPosition.x, spawnPosition.y, spawnPosition.z, spawnPosition.w))
			if not serverVeh then return end

			ClientNotify(Locales.Notification.RentedVehicle:format(vehConfig.DisplayName), "success")

			ManageVehicle.SetOwner(serverVeh, cache.serverId)
			CreateBlip.Vehicle(serverVeh, Config.VehicleBlip)

			if Config.VehicleKeys then VehKeys(serverVeh) end
			if Config.FuelSystem then VehFuel(serverVeh) end

			PlayerState.isRentingVehicle = true
			CreateThread(InRentalThread)
		else
			lib.callback.await("cloud-rental:server:InRental", false, false)
		end
	end
end

local function InZoneThread(location)
	local lastVehicle = 0
	while PlayerState.inRentalZone do
		local waitTime = 1000
		local playerCoords = GetEntityCoords(cache.ped)
		local nearbyVehicles = lib.getNearbyVehicles(playerCoords, Config.DisplayDistance + 0.1, false)

		for i = 1, #nearbyVehicles do
			local vehicle = nearbyVehicles[i].vehicle
			local distance = #(playerCoords - nearbyVehicles[i].coords)

			if distance >= Config.DisplayDistance or not GetVehicle.IsMatching("SpawnedVehicles", vehicle) then
				waitTime = 0
				break
			end

			local vehConfig = GetVehicle.Config(vehicle)
			if not vehConfig then break end

			if vehicle ~= lastVehicle then
				lastVehicle = vehicle
			else
				Scaleform.FloatingHelpText(FormattedText.Vehicle.Zone(vehConfig), vehicle)

				if distance < Config.InteractDistance and IsControlJustReleased(0, 38) then
					if IsPlayerDead(cache.playerId) then break end

					if PlayerState.isRentingVehicle then
						lib.alertDialog({
							header = Locales.Dialog.AlreadyRented,
							centered = true,
							size = "xs",
						})
						break
					end
					OpenRentDialog(vehConfig, vehicle, location)
				end
			end
			waitTime = 0
		end
		Wait(waitTime)
	end
end

-- init zones
local function CreateZones(location)
	local rentalZone = lib.zones.sphere({
		coords = location.CenterPosition,
		radius = location.Radius,
		inside = function()
			InZoneThread(location)
		end,
	})

	function rentalZone:onEnter()
		DebugPrint("Entered range of zone:", self.id, "info")
		PlayerState.inRentalZone = true
	end

	function rentalZone:onExit()
		DebugPrint("Left range of zone", self.id, "info")
		PlayerState.inRentalZone = false
	end
end

-- create zones & vehicles
for _, location in pairs(Config.Locations) do
	CreateBlip.Zone(location.CenterPosition, location.BlipIcon, location.BlipRadius, location.Radius)
	CreateZones(location)

	for _, vehiclePos in ipairs(location.VehiclePositions) do
		local randomVeh = GetRandomVehicle(location)
		DebugPrint("Spawning Vehicle:", randomVeh.Model, "at position:", vehiclePos, "info")
		SpawnVehicle.SpawnPreview(randomVeh.Model, vehiclePos)
	end
end

AddEventHandler("onResourceStop", function(resourceName)
	if GetCurrentResourceName() ~= resourceName then return end
	ManageVehicle.RemoveAll()
end)
