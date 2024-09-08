local Config = require("shared.sh_config")
local Locales = require("shared.sh_locales")

if Config.Framework ~= "esx" then return end

local ESX = exports["es_extended"]:getSharedObject()

local inRental = {}

local GetVehicleData = function(model)
	for _, location in pairs(Config.Locations) do
		for _, vehicleData in pairs(location.Vehicles) do
			if vehicleData.Model == model then return vehicleData end
		end
	end
	return nil
end

local GetPlayerName = function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	return xPlayer and xPlayer.getName() or "Unknown"
end

local GetPlayerMoney = function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	if not xPlayer then return nil end
	return { bank = xPlayer.getAccount("bank").money, wallet = xPlayer.getMoney() }
end

local DeductMoney = function(source, amount)
	local xPlayer = ESX.GetPlayerFromId(source)
	if not xPlayer then return false end

	local moneyAvailable = xPlayer.getMoney()
	local bankAvailable = xPlayer.getAccount("bank").money

	if moneyAvailable >= amount then
		xPlayer.removeMoney(amount)
		return true
	elseif bankAvailable >= amount then
		xPlayer.removeAccountMoney("bank", amount)
		return true
	else
		ServerNotify(source, Locales.Notification.NoMoney.text, Locales.Notification.NoMoney)
		return false
	end
end

lib.callback.register("cloud-rental:server:InRental", function(source, status)
	inRental[source] = status
end)

local HandleStartRental = function(source, model)
	if not inRental[source] then return false end

	local vehicleData = GetVehicleData(model)
	if vehicleData then
		local success = DeductMoney(source, vehicleData.UnlockFee)
		if success then return true end
	end
	return false
end

local HandlePenalty = function(source, model)
	if not inRental[source] then return false end

	local vehicleData = GetVehicleData(model)
	if vehicleData then
		local success = DeductMoney(source, vehicleData.DamagePenalty.PenaltyPrice)
		if success then
			ServerNotify(source, Locales.Notification.DamagePenalty.text:format(vehicleData.DamagePenalty.PenaltyPrice), Locales.Notification.DamagePenalty)
			return true
		end
	end
	return false
end

local HandleEndRental = function(source, price)
	if not inRental[source] then return false end

	local success = DeductMoney(source, price)
	if success then
		ServerNotify(source, Locales.Notification.PaidRide.text:format(price), Locales.Notification.PaidRide)
		return true
	end
	return false
end

lib.callback.register("cloud-rental:server:GetPlayerName", GetPlayerName)
lib.callback.register("cloud-rental:server:GetPlayerMoney", GetPlayerMoney)
lib.callback.register("cloud-rental:server:HandleStartRental", HandleStartRental)
lib.callback.register("cloud-rental:server:HandlePenalty", HandlePenalty)
lib.callback.register("cloud-rental:server:HandleEndRental", HandleEndRental)
