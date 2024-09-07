local Config = require("shared.sh_config")
local Locales = require("shared.sh_locales")

if Config.Framework ~= "qbcore" then return end

local QBCore = exports["qb-core"]:GetCoreObject()

local inRental = {}

local GetVehicleData = function(model)
	for _, vehicleData in pairs(Config.Vehicles) do
		if vehicleData.Model == model then return vehicleData end
	end
	return nil
end

local GetPlayerName = function(source)
	local Player = QBCore.Functions.GetPlayer(source)
	return Player and Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname or "Unknown"
end

local GetPlayerMoney = function(source)
	local Player = QBCore.Functions.GetPlayer(source)
	if not Player then return nil end
	return { bank = Player.Functions.GetMoney("cash"), wallet = Player.Functions.GetMoney("bank") }
end

local function DeductMoney(source, amount)
	local Player = QBCore.Functions.GetPlayer(source)
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
