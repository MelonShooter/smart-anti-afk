util.AddNetworkString("SendAFKMessage")

local plymeta = FindMetaTable("Player")
local antiAFKPlayers = {}

--need a function to start AFK to pause UTime and mark as AFK
--need function to end AFK and mark as not AFK anymore
--need to mark as unAFK on disconnect
--need table of player identity (steamID) as key and time AFK, remove key if not AFK
--use table to kick, ghost, and/or stop salary of player
--need a function to check if AFK (hecho)
--need function checking how long afk (hecho)


local function startSmartAntiAFK()

end

local function endSmartAntiAFK()

end

--[[
Detects if player is AFK. Returns true if they are. Returns false if they are not.
]]

function plymeta:IsSmartAntiAFK()
	return IsValid(antiAFKPlayers[self:SteamID()])
end

--[[
Returns the amount of time a player has been AFK. Returns 0 if they are not AFK
]]

function plymeta:AFKTime()
	return IsValid(antiAFKPlayers[self:SteamID()] and antiAFKPlayers[self:SteamID()] or 0
end