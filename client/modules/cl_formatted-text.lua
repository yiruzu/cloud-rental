local Locales = require("shared.sh_locales")

local OwnedVehicleText = function(vehicleData, totalPrice, playerName)
	local serviceText = Locales.ServiceName
	local vehicleNameText = Locales.VehicleName:format(vehicleData.DisplayName)
	local vehicleOwnerText = Locales.VehicleOwner:format(playerName)
	local paidTotalText = Locales.PaidTotal:format(totalPrice)
	local endRideText = Locales.EndRide

	local displayText = serviceText .. "~n~" .. vehicleNameText .. "~n~" .. vehicleOwnerText .. "~n~" .. paidTotalText .. "~n~" .. endRideText

	return displayText
end

local NotOwnedVehicleText = function(vehicleData, playerName)
	local serviceText = Locales.ServiceName
	local vehicleNameText = Locales.VehicleName:format(vehicleData.DisplayName)
	local vehicleOwnerText = Locales.VehicleOwner:format(playerName)

	local displayText = serviceText .. "~n~" .. vehicleNameText .. "~n~" .. vehicleOwnerText

	return displayText
end

local ZoneVehicleText = function(vehicleData)
	local serviceText = Locales.ServiceName
	local vehicleNameText = Locales.VehicleName:format(vehicleData.DisplayName)
	local pricePerMinuteText = Locales.PricePerMinute:format(vehicleData.PricePerMinute)
	local unlockFeeText = Locales.UnlockFee:format(vehicleData.UnlockFee)
	local unlockText = Locales.UnlockText

	local displayText = serviceText .. "~n~" .. vehicleNameText .. "~n~" .. pricePerMinuteText .. "~n~" .. unlockFeeText .. "~n~" .. unlockText

	return displayText
end

local RentVehicleConfirmText = function(vehicleData)
	return Locales.Dialog.RentVehicle:format(vehicleData.DisplayName, vehicleData.UnlockFee)
end

local EndRentalConfirmText = function(vehicleData)
	return Locales.Dialog.EndRide:format(vehicleData.DisplayName)
end

return { Vehicle = { Owned = OwnedVehicleText, NotOwned = NotOwnedVehicleText, Zone = ZoneVehicleText }, Dialog = { Rent = RentVehicleConfirmText, EndRental = EndRentalConfirmText } }
