local Config = require("configuration.config")

local TimerStore = {
	isActive = false,
	timeLeft = Config.MaxParkingTime,
	lastUpdate = GetGameTimer(),
	totalPrice = 0,
}

local TimerState = {}

function TimerState.GetState()
	return TimerStore
end

function TimerState.Reset()
	TimerStore.isActive = false
	TimerStore.timeLeft = Config.MaxParkingTime
	TimerStore.lastUpdate = GetGameTimer()
	TimerStore.totalPrice = 0
end

function TimerState.SetActive(boolean)
	TimerStore.isActive = boolean
end

function TimerState.UpdateLastTime()
	TimerStore.lastUpdate = GetGameTimer()
end

function TimerState.UpdateTimeLeft(number)
	TimerStore.timeLeft = number
end

function TimerState.UpdatePrice(amount)
	TimerStore.totalPrice = TimerStore.totalPrice + amount
end

return TimerState
