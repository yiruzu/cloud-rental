local Config = require("config.cfg_main")

TimerState = {
	Active = false,
	TimeLeft = Config.MaxParkingTime,
	LastUpdate = GetGameTimer(),
	TotalPrice = 0,
}

function TimerState:Reset()
	self.Active = false
	self.TimeLeft = Config.MaxParkingTime
	self.LastUpdate = GetGameTimer()
	self.TotalPrice = 0
end
