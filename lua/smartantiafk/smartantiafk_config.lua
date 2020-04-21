--Make it so they can select a language here

SmartAntiAFK = SmartAntiAFK or {}

SmartAntiAFK.Config = SmartAntiAFK.Config or {}

SmartAntiAFK.Config.Language = SmartAntiAFK.Config.Language or {}

--Don't touch anything above this







--[[
							Settings for when a player goes AFK
]]






SmartAntiAFK.Config.AntiAFKTimeOffset = 0
SmartAntiAFK.Config.AntiAFKTimerTime = 5 --Mininum 0.5 seconds
SmartAntiAFK.Config.EnableAntiAFK3D2DMessage = true
SmartAntiAFK.Config.AntiAFK3D2DMessageVerticalOffset = 0
SmartAntiAFK.Config.AntiAFK3D2DMessageColor = Color(0, 255, 255)
SmartAntiAFK.Config.observeInheritance = true
SmartAntiAFK.Config.blackListGroups = { --If group is blacklisted, they will not be marked as AFK at all

}

--[[
If a role/team is blacklisted, people will not be marked as AFK ever as that role/team. To add a role into the list, put a possible value (shown below) in between the curly brackets and ensure that the possible value is surrounded by single or double quotes (The possible values shown below are already surrounded in double quotes so don't do it again if copying and pasting). Then, add a comma after the last single/double quote of each value.
Possible values
TTT:
"TTT Spectator"
"Traitor"
"Detective"
"Innocent"

Murder:
"Murderer"
"Bystander"
"Armed Bystander"
"Murder Spectator"

Prop hunt:
"Prop"
"Hunter"
"Prop Hunt Spectator" (includes those who are unassigned or have died and are waiting for the next round)


To add a job or team from a gamemode not listed above, type the team enumerations you want blacklisted (eg: TEAM_CITIZEN). Ensure that all values are separated by a comma and that the team enumerations do NOT have quotes around them.
]]

SmartAntiAFK.Config.blackListRoles = {

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



--[[
Modules
]]



SmartAntiAFK.Config.UTimePause = { --Pauses UTime when enabled and UTIme is present on the server and someone goes AFK
	time = 0, --how much time after player notified as afk will the action be done
	enable = true, --enable or disable
	observeInheritance = true, --observe inheritance if you have a CAMI-supported admin mod [these options shouldnt appear as options if it isn't present]
	blackListGroups = { --list of usergroups to be blacklisted if a CAMI-supported admin mod like ULX is present. To add a group, put the group name without quotes followed by " = true" without the quotes (eg: superadmin = true)

	},
	blackListRoles = { --list of roles or team/jobs to be blacklisted. (Instructions on how to do so are the same as the blackListRoles above)

	}
}

SmartAntiAFK.Config.SalaryPause = { --Pauses salary when enabled and DarkRP or one of its derived gamemode is present and someone goes AFK
	time = 0,
	enable = true,
	observeInheritance = true,
	blackListGroups = {

	},
	blackListRoles = {

	}
}

SmartAntiAFK.Config.KickPlayer = { --Kicks player when enabled and someone goes AFK
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

SmartAntiAFK.Config.GodPlayer = { --Puts players in god player when enabled and someone goes AFK
	time = 0,
	enable = false,
	observeInheritance = true,
	blackListGroups = {

	},
	blackListRoles = {

	}
}

--[[
TTT only configuration
]]

SmartAntiAFK.Config.TTTIdleToSpectator = true




--add customizeable AFK message theme, have default theme, but list colors below