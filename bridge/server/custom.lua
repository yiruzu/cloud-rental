---@diagnostic disable: undefined-field

local Config = require("config.cfg_main")
local Locales = require("config.cfg_locales")

if Config.Framework ~= "custom" then return end

local inRental = {}

--- Retrieves the Player ID for the given source
---@param source number -- Player's source ID
---@return number|nil -- The Player ID
local function GetPlayerId(source)
	if not source or source == 0 then return nil end
	return Your_Framework.GetPlayer(source) -- example
end

--- Retrieves vehicle data based on the model name
---@param model string  -- The model name of the vehicle
---@return table|nil  -- Returns the vehicle data table if found, otherwise nil
local function GetVehicleConfig(model)
	for _, location in pairs(Config.Locations) do
		for _, vehConfig in pairs(location.Vehicles) do
			if vehConfig.Model == model then return vehConfig end
		end
	end
	return nil
end

--- Deducts money from the player’s account
---@param source number  -- The player's source ID
---@param amount number  -- The amount of money to deduct
---@return boolean  -- Returns true if the deduction was successful, otherwise false
local DeductMoney = function(source, amount)
	local player = GetPlayerId(source)
	if not player then return false end

	local cashAvailable = player.GetMoney("cash")
	local bankAvailable = player.GetMoney("bank")

	if cashAvailable >= amount then
		player.RemoveMoney("cash", amount)
		return true
	elseif bankAvailable >= amount then
		player.RemoveMoney("bank", amount)
		return true
	else
		ServerNotify(source, Locales.Notification.NoMoney, "error")
		return false
	end
end

--- Handles the start of a rental by deducting the unlock fee
---@param source number  -- The player's source ID
---@param model string  -- The model name of the vehicle being rented
---@return boolean  -- Returns true if the rental start was successful, otherwise false
local HandleStartRental = function(source, model)
	if not inRental[source] then return false end

	local vehConfig = GetVehicleConfig(model)
	if not vehConfig then return false end

	local success = DeductMoney(source, vehConfig.UnlockFee)
	if success then return true end
	return false
end

--- Handles a damage penalty by deducting the penalty price
---@param source number  -- The player's source ID
---@param model string  -- The model name of the vehicle that incurred damage
---@return boolean  -- Returns true if the penalty was successfully deducted, otherwise false
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

--- Handles the end of a rental by deducting the rental price
---@param source number  -- The player's source ID
---@param price number  -- The price to be deducted for the rental
---@return boolean  -- Returns true if the end of rental transaction was successful, otherwise false
local HandleEndRental = function(source, price)
	if not inRental[source] then return false end

	local success = DeductMoney(source, price)
	if success then
		ServerNotify(source, Locales.Notification.PaidRide:format(price), "info")
		return true
	end
	return false
end

--- Retrieves the player's name based on their source ID
---@param source number  -- The player's source ID
---@return string  -- The player's name or "Unknown" if the player is not found
local GetPlayerName = function(source)
	local player = GetPlayerId(source)
	return player and player.GetName or "Unknown"
end

--- Retrieves the player's money information
---@param source number  -- The player's source ID
---@return table|nil  -- Returns a table with bank and wallet amounts, or nil if the player is not found
local GetPlayerMoney = function(source)
	local player = GetPlayerId(source)
	if not player then return nil end

	return { bank = player.GetMoney("cash"), wallet = player.GetMoney("bank") }
end

lib.callback.register("cloud-rental:server:HandleStartRental", HandleStartRental)
lib.callback.register("cloud-rental:server:HandlePenalty", HandlePenalty)
lib.callback.register("cloud-rental:server:HandleEndRental", HandleEndRental)
lib.callback.register("cloud-rental:server:GetPlayerName", GetPlayerName)
lib.callback.register("cloud-rental:server:GetPlayerMoney", GetPlayerMoney)
lib.callback.register("cloud-rental:server:InRental", function(source, status)
	inRental[source] = status
end)
