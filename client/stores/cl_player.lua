local PlayerStore = {
	isRentingVehicle = false,
	inRentalZone = false,
}

local PlayerState = {}

function PlayerState.GetState()
	return PlayerStore
end

function PlayerState.SetState(state, boolean)
	PlayerStore[state] = boolean
end

return PlayerState
