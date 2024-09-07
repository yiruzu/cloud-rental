local Config = require("shared.sh_config")
local Locales = require("shared.sh_locales")

if Config.Framework ~= "custom" then return end

local inRental = {}

--- Retrieves vehicle data based on the model name
---@param model string  -- The model name of the vehicle
---@return table|nil  -- Returns the vehicle data table if found, otherwise nil
local GetVehicleData = function(model)
	for _, vehicleData in pairs(Config.Vehicles) do
		if vehicleData.Model == model then return vehicleData end
	end
	return nil
end

--- Retrieves the player's name based on their source ID
---@param source number  -- The player's source ID
---@return string  -- The player's name or "Unknown" if the player is not found
local GetPlayerName = function(source)
	local Player = GetPlayer(source)
	return Player and Player.GetName or "Unknown"
end

--- Retrieves the player's money information
---@param source number  -- The player's source ID
---@return table|nil  -- Returns a table with bank and wallet amounts, or nil if the player is not found
local GetPlayerMoney = function(source)
	local Player = GetPlayer(source)
	if not Player then return nil end
	return { bank = Player.GetMoney("cash"), wallet = Player.GetMoney("bank") }
end

--- Deducts money from the player’s account
---@param source number  -- The player's source ID
---@param amount number  -- The amount of money to deduct
---@return boolean  -- Returns true if the deduction was successful, otherwise false
local function DeductMoney(source, amount)
	local Player = GetPlayer(source)
	if not Player then return false end

	local cashAvailable = Player.GetMoney("cash")
	local bankAvailable = Player.GetMoney("bank")

	if cashAvailable >= amount then
		Player.RemoveMoney("cash", amount)
		return true
	elseif bankAvailable >= amount then
		Player.RemoveMoney("bank", amount)
		return true
	else
		ServerNotify(source, Locales.Notification.NoMoney.text, Locales.Notification.NoMoney)
		return false
	end
end

--- Updates the rental status of a player
---@param source number  -- The player's source ID
---@param status boolean  -- The rental status (true if renting, false otherwise)
lib.callback.register("cloud-rental:server:InRental", function(source, status)
	inRental[source] = status
end)

--- Handles the start of a rental by deducting the unlock fee
---@param source number  -- The player's source ID
---@param model string  -- The model name of the vehicle being rented
---@return boolean  -- Returns true if the rental start was successful, otherwise false
local HandleStartRental = function(source, model)
	if not inRental[source] then return false end

	local vehicleData = GetVehicleData(model)
	if vehicleData then
		local success = DeductMoney(source, vehicleData.UnlockFee)
		if success then return true end
	end
	return false
end

--- Handles a damage penalty by deducting the penalty price
---@param source number  -- The player's source ID
---@param model string  -- The model name of the vehicle that incurred damage
---@return boolean  -- Returns true if the penalty was successfully deducted, otherwise false
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

--- Handles the end of a rental by deducting the rental price
---@param source number  -- The player's source ID
---@param price number  -- The price to be deducted for the rental
---@return boolean  -- Returns true if the end of rental transaction was successful, otherwise false
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
