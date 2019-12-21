--make this into a config GUI
--make config GUI write to flat file
--then set variables into global table when updated

SmartAntiAFK = SmartAntiAFK or {}

SmartAntiAFK.Config = SmartAntiAFK.Config or {}

--Don't touch anything above this




SmartAntiAFK.Config.AntiAFKTimerTime = 300
SmartAntiAFK.Config.AFKMessage = "Come back to us please. (AFK)"

SmartAntiAFK.Config.Enable = {
	["UTime"] = {
		time = 0, --how much time after player notified as afk will utime pause
		enable = true, --enable utime pausing
		observeInheritance = true, --observe inheritance
		blackListOrWhiteList = "blacklist", --blacklist or whitelist
		list = { --list of teams/usergroups to be blacklisted/whitelisted

		}
	},

	["DarkRP"] = {
		time = 0,
		enable = true,
		observeInheritance = true,
		blackListOrWhiteList = "blacklist",
		list = {
			
		}
	},

	["Kick"] = {
		time = 0,
		enable = true,
		observeInheritance = true,
		blackListOrWhiteList = "blacklist",
		list = {
			
		}
	},

	["Ghost"] = {
		time = 0,
		enable = true,
		observeInheritance = true,
		blackListOrWhiteList = "blacklist",
		list = {
			
		}
	}
}




--add customizeable AFK message theme, have default theme, but list colors below