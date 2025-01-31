local Config = require("config.cfg_main")
local Locales = require("config.cfg_locales")

if Config.Framework ~= "esx" then return end

local ESX = exports["es_extended"]:getSharedObject()

local inRental = {}

local function GetPlayerId(source)
	if not source or source == 0 then return nil end
	return ESX.GetPlayerFromId(source)
end

local function GetVehicleConfig(model)
	for _, location in pairs(Config.Locations) do
		for _, vehConfig in pairs(location.Vehicles) do
			if vehConfig.Model == model then return vehConfig end
		end
	end
	return nil
end

local DeductMoney = function(source, amount)
	local xPlayer = GetPlayerId(source)
	if not xPlayer then return false end

	local moneyAvailable = xPlayer.getAccount("money").money
	local bankAvailable = xPlayer.getAccount("bank").money

	if moneyAvailable >= amount then
		xPlayer.removeAccountMoney("money", amount)
		return true
	elseif bankAvailable >= amount then
		xPlayer.removeAccountMoney("bank", amount)
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
	local xPlayer = GetPlayerId(source)
	return xPlayer and xPlayer.getName() or "Unknown"
end

local GetPlayerMoney = function(source)
	local xPlayer = GetPlayerId(source)
	if not xPlayer then return nil end
	return { bank = xPlayer.getAccount("bank").money, wallet = xPlayer.getMoney() }
end

lib.callback.register("cloud-rental:server:HandleStartRental", HandleStartRental)
lib.callback.register("cloud-rental:server:HandlePenalty", HandlePenalty)
lib.callback.register("cloud-rental:server:HandleEndRental", HandleEndRental)
lib.callback.register("cloud-rental:server:GetPlayerName", GetPlayerName)
lib.callback.register("cloud-rental:server:GetPlayerMoney", GetPlayerMoney)
lib.callback.register("cloud-rental:server:InRental", function(source, status)
	inRental[source] = status
end)
