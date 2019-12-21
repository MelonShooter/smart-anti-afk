--make this into a config GUI
--make config GUI write to flat file
--then set variables into global table when updated

SmartAntiAFK = SmartAntiAFK or {}

SmartAntiAFK = SmartAntiAFK or {}

--Don't touch anything above this




SmartAntiAFK.AntiAFKTimerTime = 300
SmartAntiAFK.AFKMessage = "Come back to us please. (AFK)"

SmartAntiAFK.Enable = {
	"UTime" = {
		enable = true,
		observeInheritance = true,
		blackListOrWhiteList = "blacklist",
		list = {

		}
	},

	"DarkRP" = {
		enable = true,
		observeInheritance = true,
		blackListOrWhiteList = "blacklist",
		list = {
			
		}
	},

	"Kick" = {
		enable = true,
		observeInheritance = true,
		blackListOrWhiteList = "blacklist",
		list = {
			
		}
	},

	"Ghost" = {
		enable = true,
		observeInheritance = true,
		blackListOrWhiteList = "blacklist",
		list = {
			
		}
	}
}




//add customizeable AFK message theme, have default theme, but list colors below