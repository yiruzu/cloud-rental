-- Configuration
local Locales = require("config.cfg_locales")

-- Vehicle

local OwnedVehicleText = function(vehData, totalPrice, playerName)
	local serviceText = Locales.VehicleHelpText.ServiceName
	local vehicleNameText = Locales.VehicleHelpText.VehicleName:format(vehData.DisplayName)
	local vehicleOwnerText = Locales.VehicleHelpText.VehicleOwner:format(playerName)
	local paidTotalText = Locales.VehicleHelpText.PaidTotal:format(totalPrice)
	local endRideText = Locales.VehicleHelpText.EndRide

	local displayText = serviceText .. "~n~" .. vehicleNameText .. "~n~" .. vehicleOwnerText .. "~n~" .. paidTotalText .. "~n~" .. endRideText

	return displayText
end
local NotOwnedVehicleText = function(vehData, playerName)
	local serviceText = Locales.VehicleHelpText.ServiceName
	local vehicleNameText = Locales.VehicleHelpText.VehicleName:format(vehData.DisplayName)
	local vehicleOwnerText = Locales.VehicleHelpText.VehicleOwner:format(playerName)

	local displayText = serviceText .. "~n~" .. vehicleNameText .. "~n~" .. vehicleOwnerText

	return displayText
end
local ZoneVehicleText = function(vehData)
	local serviceText = Locales.VehicleHelpText.ServiceName
	local vehicleNameText = Locales.VehicleHelpText.VehicleName:format(vehData.DisplayName)
	local pricePerMinuteText = Locales.VehicleHelpText.PricePerMinute:format(vehData.PricePerMinute)
	local unlockFeeText = Locales.VehicleHelpText.UnlockFee:format(vehData.UnlockFee)
	local unlockText = Locales.VehicleHelpText.UnlockText

	local displayText = serviceText .. "~n~" .. vehicleNameText .. "~n~" .. pricePerMinuteText .. "~n~" .. unlockFeeText .. "~n~" .. unlockText

	return displayText
end

-- Dialog

local RentVehicleConfirmText = function(vehData)
	return Locales.Dialog.RentVehicle:format(vehData.DisplayName, vehData.UnlockFee)
end
local EndRentalConfirmText = function(vehData)
	return Locales.Dialog.EndRide:format(vehData.DisplayName)
end

-- Format

local FormatTime = function(rawSeconds)
	local minutes = math.floor(rawSeconds / 60)
	local seconds = rawSeconds % 60
	return ("%dm %ds"):format(minutes, seconds)
end

return {
	Vehicle = {
		Owned = OwnedVehicleText,
		NotOwned = NotOwnedVehicleText,
		Zone = ZoneVehicleText,
	},
	Dialog = {
		Rent = RentVehicleConfirmText,
		EndRental = EndRentalConfirmText,
	},
	Format = {
		Time = FormatTime,
	},
}
