util.AddNetworkString("SendAFKMessage")

local plyMetatable = FindMetaTable("Player")
SmartAntiAFK.AntiAFKPlayers = SmartAntiAFK.AntiAFKPlayers or {}

--[[
TODO:
use table to kick, ghost, and/or stop salary of player, god, if necessary (make sure it can parse both roles and usergroups)
finish dev API (see freedcamp)
anti-macro (see freedcamp)
look at freedcamp
]]

--[[
BUGS:
utime not pausing
keyboard focus will not register keystrokes
opening the console/menu will not register as a key
]]

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

	if _G["Utime"] and _G["Utime"]["updateAll"] and SmartAntiAFK.Config.Enable["UTime"].enable then
		self:SetNWInt("SmartAntiAFK_CurrentUTimePause", CurTime()) --Sets NWInt which will pause UTime
	end

	if DarkRP and SmartAntiAFK.Config.Enable["DarkRP"].enable then
		self.SmartAntiAFKSalaryStop = true
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

	if _G["Utime"] and _G["Utime"]["updateAll"] and SmartAntiAFK.Config.Enable["UTime"].enable then
		self:SetNWInt("SmartAntiAFK_TotalUTimePause", self:GetNWInt("SmartAntiAFK_TotalUTimePause") + CurTime() - self:GetNWInt("SmartAntiAFK_CurrentUTimePause")) --Adds current pause time to total offset for UTime
		self:SetNWInt("SmartAntiAFK_CurrentUTimePause", 0) --Resets current pause time
	end

	if DarkRP and SmartAntiAFK.Config.Enable["DarkRP"].enable then
		self.SmartAntiAFKSalaryStop = nil
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

function plyMetatable:IsSmartAFK()
	local playerAFKTable = SmartAntiAFK.AntiAFKPlayers[self:SteamID()]
	return playerAFKTable and isnumber(playerAFKTable.time)
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
	local timerIdentifier = "SmartAntiAFK_AntiAFK" .. ply:UserID()
	if ply:IsSmartAFK() then --If the player is AFK, make them unAFK
		ply:EndSmartAntiAFK()
	elseif timer.Exists(timerIdentifier) then --If they aren't AFK and the timer exists, reset their timer
		timer.Adjust(timerIdentifier, SmartAntiAFK.Config.AntiAFKTimerTime, 1,  function()
			if not IsValid(ply) then return end

			ply:StartSmartAntiAFK()
		end)
	end
end

--[[
If enabled, Resets AFK timer or unAFKs the player if they are AFK upon a key being pushed down
]]

local function resetAFKTimerOrUnAFKPlayerKeyDown(ply, key)
	if SmartAntiAFK.Config.AntiAFKDetectKeyDown then
		resetAFKTimerOrUnAFKPlayer(ply)
	end

	if not SmartAntiAFK.Config.AntiAFKDetectKeyHold then return end

	if not SmartAntiAFK.AntiAFKPlayers[ply:SteamID()] then
		SmartAntiAFK.AntiAFKPlayers[ply:SteamID()] = {}
	end

	if not SmartAntiAFK.AntiAFKPlayers[ply:SteamID()].keysDown then
		SmartAntiAFK.AntiAFKPlayers[ply:SteamID()].keysDown = {} --Create table to track what keys the client has pushed down to see if it is held down
	end

	SmartAntiAFK.AntiAFKPlayers[ply:SteamID()].keysDown[key] = true

	timer.Simple(SmartAntiAFK.Config.AntiAFKKeyHoldTimeOut, function()
		if not IsValid(ply) then return end

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

	if not SmartAntiAFK.Config.AntiAFKDetectKeyHold or not SmartAntiAFK.AntiAFKPlayers[ply:SteamID()] or not SmartAntiAFK.AntiAFKPlayers[ply:SteamID()].keysDown then return end

	SmartAntiAFK.AntiAFKPlayers[ply:SteamID()].keysDown[key] = nil
end

--[[
If enabled, Resets AFK timer or unAFKs the player if they are AFK on mouse movement or a key being held down
]]

local function resetAFKTimerOrUnAFKPlayerMouseMoveOrScrollOrKeyHold(ply, cmd)
	local playerAFKTable = SmartAntiAFK.AntiAFKPlayers[ply:SteamID()]

	if SmartAntiAFK.Config.AntiAFKDetectMouseMove and (cmd:GetMouseX() ~= 0 or cmd:GetMouseY() ~= 0) then
		resetAFKTimerOrUnAFKPlayer(ply)
	elseif SmartAntiAFK.Config.AntiAFKDetectKeyHold and playerAFKTable and playerAFKTable.keysDown and not table.IsEmpty(playerAFKTable.keysDown) then
		resetAFKTimerOrUnAFKPlayer(ply)
	elseif SmartAntiAFK.Config.AntiAFKDetectScrolling and cmd:GetMouseWheel() ~= 0 then
		resetAFKTimerOrUnAFKPlayer(ply)
	end
end

--[[
Starts the AFK timer after a configurable amount of time
]]

local function startInitialAFKTimer(ply)
	timer.Simple(SmartAntiAFK.Config.AntiAFKTimeOffset, function()
		if not IsValid(ply) then return end

		startAFKTimer(ply)
	end)
end

--[[
Get rid of any AFK timers and deregister player as AFK with the server if they are AFK
]]

local function cleanUpAntiAFK(ply)
	if not IsValid(ply) then return end

	if ply:IsSmartAFK() then
		ply:EndSmartAntiAFK()
	end

	timer.Remove("SmartAntiAFK_AntiAFK" .. ply:UserID())

	SmartAntiAFK.AntiAFKPlayers[ply:SteamID()] = nil
end

hook.Add("StartCommand", "SmartAntiAFK_UnAFKOnMouseMove", resetAFKTimerOrUnAFKPlayerMouseMoveOrScrollOrKeyHold) --If enabled, the player will be unAFK or have their AFK timer reset upon moving their mouse, scrolling, and/or when holding a key down

hook.Add("PlayerButtonDown", "SmartAntiAFK_UnAFKOnKeyDown", resetAFKTimerOrUnAFKPlayerKeyDown) --If enabled, the player will be unAFK or have their AFK timer reset upon pressing a key down

hook.Add("PlayerButtonUp", "SmartAntiAFK_UnAFKOnKeyUp", resetAFKTimerOrUnAFKPlayerKeyUp) --If enabled, the player will be unAFK or have their AFK timer reset upon lifting a key up

hook.Add("PlayerInitialSpawn", "SmartAntiAFK_StartAFKTimer", startInitialAFKTimer) --Start the AFK timer after a configurable amount of time when the player joins

hook.Add("PlayerDisconnected", "SmartAntiAFK_UnAFKOnDisconnect", cleanUpAntiAFK) --Get rid of any AFK timers and deregister player as AFK with the server if they are AFK when the player disconnects