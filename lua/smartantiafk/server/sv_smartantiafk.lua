util.AddNetworkString("SendAFKMessage")

local plyMetatable = FindMetaTable("Player")
SmartAntiAFK.AntiAFKPlayers = SmartAntiAFK.AntiAFKPlayers or {}



--doesn't detect mouse movement in GUIs



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
	if SmartAntiAFK.AntiAFKPlayers[self:SteamID()] and SmartAntiAFK.AntiAFKPlayers[self:SteamID()].time then return end --Don't execute if they're already registered ask AFK

	if not SmartAntiAFK.AntiAFKPlayers[self:SteamID()] then
		SmartAntiAFK.AntiAFKPlayers[self:SteamID()] = {}
	end

	SmartAntiAFK.AntiAFKPlayers[self:SteamID()].time = CurTime() --Registers the user as AFK

	if UTime and SmartAntiAFK.Config.Enable["UTime"].enable then
		self:SetNWInt("SmartAntiAFK_CurrentUTimePause", CurTime()) --Sets NWInt which will pause UTime
	end

	if DarkRP and SmartAntiAFK.Config.Enable["DarkRP"].enable then

	end

	net.Start("SendAFKMessage")
	net.Send(self) --Notifies player that they've been marked as AFK
end

--[[
Starts AFK timer.
]]

local function startAFKTimer(ply)
	timer.Create("SmartAntiAFK_AntiAFK" .. ply:UserID(), SmartAntiAFK.Config.AntiAFKTimerTime, 1, function()
		if not IsValid(ply) then return end

		ply:StartSmartAntiAFK()
	end)
end

--[[
Deregisters player as AFK with the server only if they were AFK to begin with.
If UTime is used and the config allows it, it will unpause UTime for the player. 
If DarkRP is used and the config allows it, it will unpause salaries for the player.
Gets rid of the notification on the client
]]

function plyMetatable:EndSmartAntiAFK()
	if not SmartAntiAFK.AntiAFKPlayers[self:SteamID()] or not SmartAntiAFK.AntiAFKPlayers[self:SteamID()].time then return end --Don't execute if they haven't been registered ask AFK in the first place

	SmartAntiAFK.AntiAFKPlayers[self:SteamID()].time = nil --Deregisters the user as AFK

	if UTime and SmartAntiAFK.Config.Enable["UTime"].enable then
		self:SetNWInt("SmartAntiAFK_TotalUTimePause", self:GetNWInt("SmartAntiAFK_TotalUTimePause") + CurTime() - self:GetNWInt("SmartAntiAFK_CurrentUTimePause")) --Adds current pause time to total offset for UTime
		self:SetNWInt("SmartAntiAFK_CurrentUTimePause", 0) --Resets current pause time
	end

	if DarkRP and SmartAntiAFK.Config.Enable["DarkRP"].enable then

	end

	net.Start("SendAFKMessage")
	net.Send(self) --Remove the notification to the player that they've been marked ask AFK

	startAFKTimer(self) --Restart AFK timer
end

--[[
Detects if player is AFK.
Returns true if they are.
Returns false if they are not.
]]

function plyMetatable:IsSmartAntiAFK()
	return SmartAntiAFK.AntiAFKPlayers[self:SteamID()] and isnumber(SmartAntiAFK.AntiAFKPlayers[self:SteamID()].time)
end

--[[
Returns the amount of time a player has been AFK. 
Returns 0 if they are not AFK
]]

function plyMetatable:AFKTime()
	return SmartAntiAFK.AntiAFKPlayers[self:SteamID()] and CurTime() - SmartAntiAFK.AntiAFKPlayers[self:SteamID()].time or 0
end

--[[
Resets AFK timer or unAFKs the player if they are AFK
]]

local function resetAFKTimerOrUnAFKPlayer(ply)
	if ply:IsSmartAntiAFK() then --If the player is AFK, make them unAFK
		ply:EndSmartAntiAFK()
	else --If they aren't AFK, reset their timer
		timer.Adjust("SmartAntiAFK_AntiAFK" .. ply:UserID(), SmartAntiAFK.Config.AntiAFKTimerTime, 1,  function()
			ply:StartSmartAntiAFK()
		end)
	end
end

--[[
If enabled, Resets AFK timer or unAFKs the player if they are AFK upon a key being pushed down
]]

local function resetAFKTimerOrUnAFKPlayerKeyDown(ply, key)
	resetAFKTimerOrUnAFKPlayer(ply)

	if not SmartAntiAFK.Config.AntiAFKDetectKeyHold then return end

	if not SmartAntiAFK.AntiAFKPlayers[ply:SteamID()] then
		SmartAntiAFK.AntiAFKPlayers[ply:SteamID()] = {}
	end

	if not SmartAntiAFK.AntiAFKPlayers[ply:SteamID()].keysDown then
		SmartAntiAFK.AntiAFKPlayers[ply:SteamID()].keysDown = {} --Create table to track what keys the client has pushed down to see if it is held down
	end

	SmartAntiAFK.AntiAFKPlayers[ply:SteamID()].keysDown[key] = true

	timer.Simple(SmartAntiAFK.Config.AntiAFKKeyHoldTimeOut, function()
		SmartAntiAFK.AntiAFKPlayers[ply:SteamID()].keysDown[key] = nil
	end)
end

--[[
If enabled, Resets AFK timer or unAFKs the player if they are AFK upon a key being released
]]

local function resetAFKTimerOrUnAFKPlayerKeyUp(ply, key)
	if SmartAntiAFK.Config.AntiAFKDetectKeyUp then
		resetAFKTimerOrUnAFKPlayer(ply)
	end

	if not SmartAntiAFK.Config.AntiAFKDetectKeyHold then return end

	SmartAntiAFK.AntiAFKPlayers[ply:SteamID()].keysDown[key] = nil
end

--[[
If enabled, Resets AFK timer or unAFKs the player if they are AFK on mouse movement or a key being held down
]]

local function resetAFKTimerOrUnAFKPlayerMouseMoveOrKeyHold(ply, cmd)
	PrintTable(SmartAntiAFK.AntiAFKPlayers[ply:SteamID()].keysDown)
	if SmartAntiAFK.Config.AntiAFKDetectMouseMove and (cmd:GetMouseX() ~= 0 or cmd:GetMouseY() ~= 0) then
		resetAFKTimerOrUnAFKPlayer(ply)
	elseif SmartAntiAFK.Config.AntiAFKDetectKeyHold and not table.IsEmpty(SmartAntiAFK.AntiAFKPlayers[ply:SteamID()].keysDown) then
		resetAFKTimerOrUnAFKPlayer(ply)
	end
end

--[[
Get rid of any AFK timers and deregister player as AFK with the server if they are AFK
]]

local function cleanUpAntiAFK(ply)
	if not IsValid(ply) then return end

	if ply:IsSmartAntiAFK() then
		ply:EndSmartAntiAFK()
	end

	timer.Remove("SmartAntiAFK_AntiAFK" .. ply:UserID())

	SmartAntiAFK.AntiAFKPlayers[ply:SteamID()] = nil
end

if SmartAntiAFK.Config.AntiAFKDetectMouseMove or SmartAntiAFK.Config.AntiAFKDetectKeyHold then
	hook.Add("StartCommand", "SmartAntiAFK_UnAFKOnMouseMove", resetAFKTimerOrUnAFKPlayerMouseMoveOrKeyHold) --If enabled, the player will be unAFK or have their AFK timer reset upon moving their mouse or when holding a key down
end

if SmartAntiAFK.Config.AntiAFKDetectKeyDown then
	hook.Add("PlayerButtonDown", "SmartAntiAFK_UnAFKOnKeyDown", resetAFKTimerOrUnAFKPlayerKeyDown) --If enabled, the player will be unAFK or have their AFK timer reset upon pressing a key down
end

hook.Add("PlayerButtonUp", "SmartAntiAFK_UnAFKOnKeyUp", resetAFKTimerOrUnAFKPlayerKeyUp) --If enabled, the player will be unAFK or have their AFK timer reset upon lifting a key up

hook.Add("PlayerInitialSpawn", "SmartAntiAFK_StartAFKTimer", startAFKTimer)

hook.Add("PlayerDisconnected", "SmartAntiAFK_UnAFKOnDisconnect", cleanUpAntiAFK)

--make sure to check if value exists in table, if not, terminate the function