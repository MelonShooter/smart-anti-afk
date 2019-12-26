--make this into a config GUI
--make config GUI write to flat file
--then set variables into global table when updated
--Change default language text to change based on language selected in config

SmartAntiAFK = SmartAntiAFK or {}

SmartAntiAFK.Config = SmartAntiAFK.Config or {}

SmartAntiAFK.Config.Language = SmartAntiAFK.Config.Language or {}

--Don't touch anything above this



SmartAntiAFK.Config.AntiAFKTimeOffset = 5
SmartAntiAFK.Config.AntiAFKTimerTime = 5 --Mininum 0.5 seconds
SmartAntiAFK.Config.EnableAntiAFK3D2DMessage = true
SmartAntiAFK.Config.AntiAFK3D2DMessageVerticalOffset = 0
SmartAntiAFK.Config.AntiAFK3D2DMessageColor = Color(0, 255, 255)
SmartAntiAFK.Config.observeInheritance = true --observe inheritance if you have a CAMI-supported admin mod [these options shouldnt appear as options if it isn't present]
SmartAntiAFK.Config.blackList = { --If blacklisted, they will not be marked as AFK at all
	
}



SmartAntiAFK.Config.AntiAFKDetectKeyDown = true
SmartAntiAFK.Config.AntiAFKDetectKeyHold = true
SmartAntiAFK.Config.AntiAFKDetectKeyUp = true
SmartAntiAFK.Config.AntiAFKDetectMouseMove = true
SmartAntiAFK.Config.AntiAFKDetectScrolling = true



SmartAntiAFK.Config.AntiAFKKeyHoldTimeOut = 5 --The amount of time before a held-down key no longer resets the anti AFK timer. The anti AFK timer will start counting down 




SmartAntiAFK.Config.Language.AFKMessage = "Come back to us please. (AFK)"
SmartAntiAFK.Config.Language.AntiAFK3D2DMessage = "I'm AFK!"
SmartAntiAFK.Config.Language.SalaryPausedMessage = "You have received no salary because you are AFK." --Should appear under DarkRP tab
SmartAntiAFK.Config.Language.KickReason = "You have been kicked for being AFK too long."

--test inheritance for utime
--test list and inheritance for salary, kicking, and godding
--BUGS: Blacklist no longer works and UTime no longer pauses

SmartAntiAFK.Config.UTimePause = { --Pauses UTime when enabled
	time = 0, --how much time after player notified as afk will the action be done
	enable = true, --enable action
	observeInheritance = true, --observe inheritance if you have a CAMI-supported admin mod [these options shouldnt appear as options if it isn't present]
	blackList = { --list of teams/usergroups to be blacklisted/whitelisted if you have a CAMI-supported admin mod

	}
}

SmartAntiAFK.Config.SalaryPause = { --Pauses salary when enabled
	time = 0,
	enable = true,
	observeInheritance = true,
	blackList = {
		
	}
}

SmartAntiAFK.Config.KickPlayer = { --Kicks player when enabled
	time = 0,
	enable = true, --Will kick the player with highest AFK time
	kickIfPlayerCountPercentageOrNumberReached = true, --Kick if player count percentage limit is reached (true) or if player count number limit is reached (false)
	kickPlayerCount = 100, --Will either be percentage or flat number depending on option selected, 2 will be minimum for flat number (need at least 1 person in the afk table)
	kickAll = true, --Kick anyone AFK
	kickDelay = 0, --Kick a player "kickDelay" seconds after the requirement is met
	botsExempt = true, --are bots exempt from being kicked
	observeInheritance = true,
	blackList = {

	}
}

SmartAntiAFK.Config.GodPlayer = { --Gods player when enabled
	time = 0,
	enable = false,
	observeInheritance = true,
	blackList = {

	}
}




--add customizeable AFK message theme, have default theme, but list colors below