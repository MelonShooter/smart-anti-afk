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
SmartAntiAFK.Config.EnableAntiAFK3D2DMessage = true
SmartAntiAFK.Config.AntiAFK3D2DMessageVerticalOffset = 0
SmartAntiAFK.Config.AntiAFK3D2DMessageColor = Color(0, 255, 255)




SmartAntiAFK.Config.AntiAFKDetectKeyDown = true
SmartAntiAFK.Config.AntiAFKDetectKeyHold = true
SmartAntiAFK.Config.AntiAFKDetectKeyUp = true
SmartAntiAFK.Config.AntiAFKDetectMouseMove = true
SmartAntiAFK.Config.AntiAFKDetectScrolling = true



SmartAntiAFK.Config.AntiAFKKeyHoldTimeOut = 5 --The amount of time before a held-down key no longer resets the anti AFK timer. The anti AFK timer will start counting down 




SmartAntiAFK.Config.Language.AFKMessage = "Come back to us please. (AFK)"
SmartAntiAFK.Config.Language.AntiAFK3D2DMessage = "I'm AFK!"
SmartAntiAFK.Config.Language.SalaryPausedMessage = "You have received no salary because you are AFK." --Should appear under DarkRP tab



SmartAntiAFK.Config.UTimePause = {
	time = 0, --how much time after player notified as afk will the action be done
	enable = true, --enable action
	observeInheritance = true, --observe inheritance
	blackListOrNo = true, --true for blacklist or false for whitelist
	list = { --list of teams/usergroups to be blacklisted/whitelisted

	}
}

SmartAntiAFK.Config.SalaryPause = {
	time = 0,
	enable = true,
	observeInheritance = true,
	blackListOrNo = true,
	list = {
		
	}
}

SmartAntiAFK.Config.KickPlayer = {
	time = 0,
	enable = true,
	kickIfCertainPlayerCountPercentageReachedOrNo = true, --Kick if player count percentage limit is reached
	kickIfCertainPlayerCountNumberReachedOrNo = false, --Kick if player count number limit is reached
	kickAll = false, --Kick anyone AFK
	kickDelay = 0, --Kick the player "kickDelay" seconds after the requirement is met
	observeInheritance = true,
	blackListOrNo = true,
	list = {
		
	}
}

SmartAntiAFK.Config.GodPlayer = {
	time = 0,
	enable = false,
	observeInheritance = true,
	blackListOrNo = true,
	list = {
		
	}
}




--add customizeable AFK message theme, have default theme, but list colors below