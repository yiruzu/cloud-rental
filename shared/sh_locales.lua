return {
	ServiceName = "~b~[ VEHICLE RENTAL ]~s~",
	VehicleName = "Vehicle: ~b~%s~s~",
	PricePerMinute = "Per Minute: ~b~$%s~s~",
	UnlockFee = "Unlock Fee: ~b~$%s~s~",
	UnlockText = "Press ~b~[ E ]~s~ To Unlock",

	PaidTotal = "Total Price: ~b~$%s~s~",
	VehicleOwner = "Owner: ~b~%s~s~",
	EndRide = "Press ~b~[ E ]~s~ To End Ride",

	TimeLeft = "Your rented vehicle will be removed if left parked.~n~Time remaining: ~b~%s~s~ ~BLIP_TEMP_2~",

	Dialog = {
		RentVehicle = "Would you like to rent this **%s** for an unlock fee of **$%s**?",
		EndRide = "Do you want to end the Ride for your **%s**?",

		AlreadyRented = "You can only have one vehicle rented at the same time!",

		NoParkingSlots = "No Parking Slots Available",
		NoParkingSlotsDesc = "Please try again later or move to a different location.",
	},
	Notification = {
		PaidRide = { title = "Information", text = "You paid $%s for your ride.", type = "info" },
		RentedVehicle = { title = "Success", text = "You successfully rented a %s", type = "success" },
		NoMoney = { title = "Error", text = "You don't have enough money.", type = "error" },
		DamagePenalty = { title = "Error", text = "You paid $%s for damaging the vehicle.", type = "error" },
	},
}
