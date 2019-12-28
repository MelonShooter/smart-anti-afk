--make this into a config GUI
--make config GUI write to flat file
--then set variables into global table when updated
--Change default language text to change based on language selected in config

SmartAntiAFK = SmartAntiAFK or {}

SmartAntiAFK.Config = SmartAntiAFK.Config or {}

SmartAntiAFK.Config.Language = SmartAntiAFK.Config.Language or {}

--Don't touch anything above this

--if someone is blacklisted from going AFK, the option to enable modules for them should be grayed out with paratheses saying (Anti-AFK Exempt)



--[[
What to display in the Config GUI for groups, roles, jobs, etc:
Display "Groups" as the first category then "Roles" as the second category. Don't show a category if no item is listed in there


For blackListGroups, save the usergroup as a key

Display all user groups if CAMI is present.
["superadmin"] = true


For blackListRoles, create separate keys for different gamemodes. The key name should be GAMEMODE.Name. The value of each gamemode key should be a SEQUENTIAL table of roles/RP job commands/team enumeration and team name separated by "&" AS values.

Display 4 options if the game mode "Trouble in Terrorist Town" is active:
Traitor, Detective, Innocent, Spectator
Example: ["Trouble in Terrorist Town"] = {
	"Traitor",
	"Detective"
}


Display 4 options if the game mode "Murder" is active:
Murderer, Armed Bystander, Bystander, Spectator
Example: ["Murder"] = {
	"Bystander",
	"Spectator"
}

Display all "pretty" job names if RPExtraTeams and DarkRP.getJobByCommand exists
Citizen, Civil Protection, etc
Example: ["DarkRP"] = {
	"citizen",
	"cp"
}

Display all teams' pretty names excluding TEAM_UNASSIGNED, and TEAM_CONNECTING (include TEAM_SPECTATOR) for any other cases
Example: ["prophunt"] = {
	"2&Props",
	"1&Hunters"
}
]]

SmartAntiAFK.Config.AntiAFKTimeOffset = 0
SmartAntiAFK.Config.AntiAFKTimerTime = 5 --Mininum 0.5 seconds
SmartAntiAFK.Config.EnableAntiAFK3D2DMessage = true
SmartAntiAFK.Config.AntiAFK3D2DMessageVerticalOffset = 0
SmartAntiAFK.Config.AntiAFK3D2DMessageColor = Color(0, 255, 255)
SmartAntiAFK.Config.observeInheritance = true --observe inheritance if you have a CAMI-supported admin mod [these options shouldnt appear as options if it isn't present]
SmartAntiAFK.Config.blackListGroups = { --If group is blacklisted, they will not be marked as AFK at all

}
SmartAntiAFK.Config.blackListRoles = { --If Murder or TTT role or team is blacklisted, they will not be marked as AFK at all
	["Trouble in Terrorist Town"] = {
		"Traitor",
		"Detective",
		--"Spectator",
		--"Innocent"
	},

	["DarkRP"] = {
		"citizen",
		"cp"
	},

	["Prop Hunt"] = {
		--"2&Props",
		"1&Hunters",
		TEAM_SPECTATOR .. "&Spectator"
	}
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
SmartAntiAFK.Config.Language.KickReason = "You have been kicked for being AFK too long"

SmartAntiAFK.Config.UTimePause = { --Pauses UTime when enabled
	time = 0, --how much time after player notified as afk will the action be done
	enable = true, --enable action
	observeInheritance = true, --observe inheritance if you have a CAMI-supported admin mod [these options shouldnt appear as options if it isn't present]
	blackListGroups = { --list of usergroups to be blacklisted if you have a CAMI-supported admin mod

	},
	blackListRoles = { --list of Murder or TTT roles or team to be blacklisted

	}
}

SmartAntiAFK.Config.SalaryPause = { --Pauses salary when enabled
	time = 0,
	enable = true,
	observeInheritance = true,
	blackListGroups = {

	},
	blackListRoles = {

	}
}

SmartAntiAFK.Config.KickPlayer = { --Kicks player when enabled
	time = 0,
	enable = true, --Will kick the player with highest AFK time
	kickIfPlayerCountPercentageOrNumberReached = true, --Kick if player count percentage limit is reached (true) or if player count number limit is reached (false)
	kickPlayerCount = 100, --Will either be percentage or flat number depending on option selected, 2 will be minimum for flat number (need at least 1 person in the afk table)
	kickAll = false, --Kick anyone AFK
	kickDelay = 0, --Kick a player "kickDelay" seconds after the requirement is met
	botsExempt = true, --are bots exempt from being kicked
	observeInheritance = true,
	blackListGroups = {

	},
	blackListRoles = {

	}
}

SmartAntiAFK.Config.GodPlayer = { --Gods player when enabled
	time = 0,
	enable = false,
	observeInheritance = true,
	blackListGroups = {

	},
	blackListRoles = {

	}
}




--add customizeable AFK message theme, have default theme, but list colors below