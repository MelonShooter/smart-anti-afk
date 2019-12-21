--make this into a config GUI
--make config GUI write to flat file
--then set variables into global table when updated

SmartAntiAFK = SmartAntiAFK or {}

SmartAntiAFK = SmartAntiAFK or {}

--Don't touch anything above this




SmartAntiAFK.AntiAFKTimerTime = 300
SmartAntiAFK.AFKMessage = "Come back to us please. (AFK)"




SmartAntiAFK.EnableUTimeStop = true

SmartAntiAFK.UTimeStopObserveInheritance = true

SmartAntiAFK.UTimeStopList = {
	"blacklist",
}




SmartAntiAFK.EnableDarkRPSalaryStop = true

SmartAntiAFK.SalaryStopObserveInheritance = true

SmartAntiAFK.SalaryStopList = {
	"blacklist",
}




SmartAntiAFK.EnableAFKKicking = true

SmartAntiAFK.KickPercentage = 100

SmartAntiAFK.KickObserveInheritance = true

SmartAntiAFK.KickList = {
	"blacklist",
}




SmartAntiAFK.EnableAFKGhosting = false

SmartAntiAFK.GhostObserveInheritance = true

SmartAntiAFK.GhostList = {
	"blacklist",
}




//add customizeable AFK message theme, have default theme, but list colors below