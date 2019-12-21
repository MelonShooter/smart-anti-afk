util.AddNetworkString("SendAFKMessage")

local plyMetatable = FindMetaTable("Player")
local antiAFKPlayers = {}

--[[
TODO:
use table to kick, ghost, and/or stop salary of player, if necessary (make sure it can parse both roles and usergroups)
finish dev API
add salary stop implementation
]]

--add timer to make player afk after it
--use table to kick, ghost, and/or stop salary of player (make sure it can parse both roles and usergroups)
--need to mark as unAFK on disconnect
--need function to end AFK and mark as not AFK anymore
--need a function to start AFK to pause UTime and mark as AFK, set nwint SmartAntiAFKUTimePauseTime, make salary stop
--need table of player identity (steamID) as key and time AFK, remove key if not AFK
--need a function to check if AFK
--need function checking how long afk

--[[
Registers player as AFK with the server only if they weren't AFK to begin with.
If UTime is used and the config allows it, it will pause UTime for the player. 
If DarkRP is used and the config allows it, it will pause salaries for the player
Notifies the client that they have been marked as AFK.
]]

function plyMetatable:StartSmartAntiAFK()
	if antiAFKPlayers[self:SteamID()] then return end --Don't execute if they're already registered ask AFK

	antiAFKPlayers[self:SteamID()] = CurTime() --Registers the user as AFK

	if UTime and SmartAntiAFK.Config.Enable["UTime"].enable then
		self:SetNWInt("SmartAntiAFK_CurrentUTimePause", CurTime()) --Sets NWInt which will pause UTime
	end

	if DarkRP and SmartAntiAFK.Config.Enable["DarkRP"].enable then

	end

	net.Start("SendAFKMessage")
	net.Send(self) --Notifies player that they've been marked as AFK
end

--[[
Deregisters player as AFK with the server only if they were AFK to begin with.
If UTime is used and the config allows it, it will unpause UTime for the player. 
If DarkRP is used and the config allows it, it will unpause salaries for the player
Gets rid of the notification on the client
]]

function plyMetatable:EndSmartAntiAFK()
	if not antiAFKPlayers[self:SteamID()] then return end --Don't execute if they haven't been registered ask AFK in the first place

	antiAFKPlayers[self:SteamID()] = nil --Deregisters the user as AFK

	if UTime and SmartAntiAFK.Config.Enable["UTime"].enable then
		self:SetNWInt("SmartAntiAFK_TotalUTimePause", self:GetNWInt("SmartAntiAFK_TotalUTimePause") + CurTime() - self:GetNWInt("SmartAntiAFK_CurrentUTimePause")) --Adds current pause time to total offset for UTime
		self:SetNWInt("SmartAntiAFK_CurrentUTimePause", 0) --Resets current pause time
	end

	if DarkRP and SmartAntiAFK.Config.Enable["DarkRP"].enable then

	end

	net.Start("SendAFKMessage")
	net.Send(self) --Remove the notification to the player that they've been marked ask AFK
end

--[[
Detects if player is AFK. Returns true if they are. 
Returns false if they are not.
]]

function plyMetatable:IsSmartAntiAFK()
	return IsValid(antiAFKPlayers[self:SteamID()])
end

--[[
Returns the amount of time a player has been AFK. 
Returns 0 if they are not AFK
]]

function plyMetatable:AFKTime()
	return IsValid(antiAFKPlayers[self:SteamID()]) and CurTime() - antiAFKPlayers[self:SteamID()] or 0
end

hook.Add("PlayerDisconnected", "SmartAntiAFK_UnAFKOnDisconnect", function(ply)
	ply:EndSmartAntiAFK()
end)