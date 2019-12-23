--make this into a config GUI
--make config GUI write to flat file
--then set variables into global table when updated
--Change default language text to change based on language selected in config

SmartAntiAFK = SmartAntiAFK or {}

SmartAntiAFK.Config = SmartAntiAFK.Config or {}

SmartAntiAFK.Config.Language = SmartAntiAFK.Config.Language or {}

--Don't touch anything above this



SmartAntiAFK.Config.AntiAFKTimeOffset = 5
SmartAntiAFK.Config.AntiAFKTimerTime = 5




SmartAntiAFK.Config.AntiAFKDetectKeyDown = true
SmartAntiAFK.Config.AntiAFKDetectKeyHold = true
SmartAntiAFK.Config.AntiAFKDetectKeyUp = true
SmartAntiAFK.Config.AntiAFKDetectMouseMove = true
SmartAntiAFK.Config.AntiAFKDetectScrolling = true



SmartAntiAFK.Config.AntiAFKKeyHoldTimeOut = 5 --The amount of time before a held-down key no longer resets the anti AFK timer. The anti AFK timer will start counting down 




SmartAntiAFK.Config.Language.AFKMessage = "Come back to us please. (AFK)"
SmartAntiAFK.Config.Language.SalaryPausedMessage = "You have received no salary because you are AFK."



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
	},

	["God"] = {
		time = 0,
		enable = false,
		observeInheritance = true,
		blackListOrWhiteList = "blacklist",
		list = {
			
		}
	}
}




--add customizeable AFK message theme, have default theme, but list colors below