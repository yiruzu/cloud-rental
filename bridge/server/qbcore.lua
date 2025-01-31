local Config = require("config.cfg_main")
local Locales = require("config.cfg_locales")

if Config.Framework ~= "qbcore" then return end

local QBCore = exports["qb-core"]:GetCoreObject()

local inRental = {}

local function GetPlayerId(source)
	if not source or source == 0 then return nil end
	return QBCore.Functions.GetPlayer(source)
end

local function GetVehicleConfig(model)
	for _, location in pairs(Config.Locations) do
		for _, vehConfig in pairs(location.Vehicles) do
			if vehConfig.Model == model then return vehConfig end
		end
	end
	return nil
end

local function DeductMoney(source, amount)
	local Player = GetPlayerId(source)
	if not Player then return false end

	local cashAvailable = Player.Functions.GetMoney("cash")
	local bankAvailable = Player.Functions.GetMoney("bank")

	if cashAvailable >= amount then
		Player.Functions.RemoveMoney("cash", amount)
		return true
	elseif bankAvailable >= amount then
		Player.Functions.RemoveMoney("bank", amount)
		return true
	else
		ServerNotify(source, Locales.Notification.NoMoney, "error")
		return false
	end
end

local HandleStartRental = function(source, model)
	if not inRental[source] then return false end

	local vehConfig = GetVehicleConfig(model)
	if not vehConfig then return false end

	local success = DeductMoney(source, vehConfig.UnlockFee)
	if success then return true end
	return false
end

local HandlePenalty = function(source, model)
	if not inRental[source] then return false end

	local vehConfig = GetVehicleConfig(model)
	if not vehConfig then return false end

	local success = DeductMoney(source, vehConfig.DamagePenalty.PenaltyPrice)
	if success then
		ServerNotify(source, Locales.Notification.DamagePenalty:format(vehConfig.DamagePenalty.PenaltyPrice), "error")
		return true
	end
	return false
end

local HandleEndRental = function(source, price)
	if not inRental[source] then return false end

	local success = DeductMoney(source, price)
	if success then
		ServerNotify(source, Locales.Notification.PaidRide:format(price), "info")
		return true
	end
	return false
end

local GetPlayerName = function(source)
	local Player = GetPlayerId(source)
	return Player and Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname or "Unknown"
end

local GetPlayerMoney = function(source)
	local Player = GetPlayerId(source)
	if not Player then return nil end
	return { bank = Player.Functions.GetMoney("cash"), wallet = Player.Functions.GetMoney("bank") }
end

lib.callback.register("cloud-rental:server:HandleStartRental", HandleStartRental)
lib.callback.register("cloud-rental:server:HandlePenalty", HandlePenalty)
lib.callback.register("cloud-rental:server:HandleEndRental", HandleEndRental)
lib.callback.register("cloud-rental:server:GetPlayerName", GetPlayerName)
lib.callback.register("cloud-rental:server:GetPlayerMoney", GetPlayerMoney)
lib.callback.register("cloud-rental:server:InRental", function(source, status)
	inRental[source] = status
end)
