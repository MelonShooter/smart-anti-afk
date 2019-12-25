util.AddNetworkString("SendAFKMessage")

local plyMetatable = FindMetaTable("Player")
SmartAntiAFK.AntiAFKPlayers = SmartAntiAFK.AntiAFKPlayers or {}
--Use CAMI.UsergroupInherits(parentUserGroup, childUserGroup) to check user's usergroup is inherited (arg1) from a group in the blacklist (arg2). if its a whitelist, flip the arguments
--[[
TODO:
use table to kick, ghost, and/or stop salary of player, god, if necessary (make sure it can parse both roles and usergroups)
anti-macro (see freedcamp)
look at freedcamp
MAKE SURE TO MAKE IT SO THAT THEY DO A MAP RESTART FOR CONFIG CHANGES TO TAKE EFFECT
]]

--[[
BUGS:
utime not pausing
keyboard focus will not register keystrokes
opening the console/menu will not register as a key
]]

if SmartAntiAFK.Config.KickPlayer.enable then
	SmartAntiAFK.kickTable = SmartAntiAFK.kickTable or {}
	SmartAntiAFK.AntiAFKPlayers.players = SmartAntiAFK.AntiAFKPlayers.players or 0
end

local uTimeExists = _G["Utime"] and _G["Utime"]["updateAll"]

--[[
Kicks player and runs the OnSmartAFKKick hook
]]

local function smartAFKKick(ply, immideatelyOrNo)
	local abortKick, overwriteKickReason = hook.Run("OnSmartAFKKick", ply, CurTime() - SmartAntiAFK.AntiAFKPlayers[ply:SteamID64()].time)

	if abortKick then return end

	local kickConfig = SmartAntiAFK.Config.KickPlayer

	if kickConfig.kickDelay > 0 then
		if immideatelyOrNo then
			timer.Simple(kickConfig.kickDelay, function() --test the delay
				if not IsValid(ply) then return end

				ply:Kick(overwriteKickReason or SmartAntiAFK.Config.Language.KickReason)
			end)
		else
			timer.Simple(kickConfig.kickDelay, function() --test the delay
				if not IsValid(ply) then
					while SmartAntiAFK.kickTable[1] and not IsValid(SmartAntiAFK.kickTable[1]) do
						table.remove(SmartAntiAFK.kickTable, 1)
					end
				end

				if table.IsEmpty(SmartAntiAFK.kickTable) then return end

				ply:Kick(overwriteKickReason or SmartAntiAFK.Config.Language.KickReason)
			end)
		end
	else
		ply:Kick(overwriteKickReason or SmartAntiAFK.Config.Language.KickReason)
	end
end

--[[
Registers player as AFK with the server only if they weren't AFK to begin with.
If UTime is used and the config allows it, it will pause UTime for the player. 
If DarkRP is used and the config allows it, it will pause salaries for the player
Notifies the client that they have been marked as AFK.
]]

function plyMetatable:StartSmartAntiAFK()
	if SmartAntiAFK.AntiAFKPlayers[self:SteamID64()] and SmartAntiAFK.AntiAFKPlayers[self:SteamID64()].time then return end --Don't execute if they're already registered as AFK

	local supressAFK, timeExtension = hook.Run("OnSmartAFK", self)

	if supressAFK then
		timer.Create("SmartAntiAFK_AntiAFK" .. self:UserID(), timeExtension or 0, 1, function()
			if not IsValid(self) then return end

			self:StartSmartAntiAFK()
		end)

		return
	end

	if not SmartAntiAFK.AntiAFKPlayers[self:SteamID64()] then
		SmartAntiAFK.AntiAFKPlayers[self:SteamID64()] = {}
	end

	SmartAntiAFK.AntiAFKPlayers[self:SteamID64()].time = CurTime() --Registers the user as AFK
	self:SetNWFloat("SmartAntiAFK_AFKTime", CurTime())

	if SmartAntiAFK.Config.GodPlayer.enable then
		if SmartAntiAFK.Config.GodPlayer.time > 0 then --If enabled, player will be godded after a configurable amount of seconds after going AFK
			timer.Simple(SmartAntiAFK.Config.GodPlayer.time, function()
				if not IsValid(self) then return end

				self:GodEnable()
			end)
		else
			self:GodEnable()
		end
	end

	if SmartAntiAFK.Config.KickPlayer.enable and (not SmartAntiAFK.Config.KickPlayer.botsExempt or not self:IsBot()) then
		if SmartAntiAFK.Config.KickPlayer.time > 0 then --If enabled, player will be kicked after a configurable amount of seconds and/or when certain player count is reached after going AFK
			timer.Simple(SmartAntiAFK.Config.KickPlayer.time, function()
				if not IsValid(self) then return end

				if SmartAntiAFK.Config.KickPlayer.kickAll then --Kick immediately if enabled
					smartAFKKick(self, true)
				else --Add to kick queue if they're not going to be kicked immediately. Make sure to check if AFK player still exists
					table.insert(SmartAntiAFK.kickTable, self)
				end
			end)
		else
			if SmartAntiAFK.Config.KickPlayer.kickAll then
				smartAFKKick(self, true)
			else --Add to kick queue if they're not going to be kicked immediately. Make sure to check if AFK player still exists
				table.insert(SmartAntiAFK.kickTable, self)
			end
		end
	end

	if uTimeExists and SmartAntiAFK.Config.UTimePause.enable then
		if SmartAntiAFK.Config.UTimePause.time > 0 then --If enabled, UTime will pause for the player after a configurable amount of seconds after going AFK
			timer.Simple(SmartAntiAFK.Config.UTimePause.time, function()
				if not IsValid(self) then return end

				self:SetNWFloat("SmartAntiAFK_CurrentUTimePause", CurTime()) --Sets NWFloat which will pause UTime
			end)
		else
			self:SetNWFloat("SmartAntiAFK_CurrentUTimePause", CurTime()) --Sets NWFloat which will pause UTime
		end
	end

	net.Start("SendAFKMessage")
	net.Send(self) --Notifies player that they've been marked as AFK

	hook.Run("OnPostSmartAFK", self)
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
	if not SmartAntiAFK.AntiAFKPlayers[self:SteamID64()] or not SmartAntiAFK.AntiAFKPlayers[self:SteamID64()].time then return end --Don't execute if they haven't been registered ask AFK in the first place

	SmartAntiAFK.AntiAFKPlayers[self:SteamID64()].time = nil --Deregisters the user as AFK
	self:SetNWFloat("SmartAntiAFK_AFKTime", 0)

	if SmartAntiAFK.Config.GodPlayer.enable then
		self:GodDisable()
	end

	if uTimeExists and SmartAntiAFK.Config.UTimePause.enable then
		self:SetNWFloat("SmartAntiAFK_TotalUTimePause", self:GetNWFloat("SmartAntiAFK_TotalUTimePause") + CurTime() - self:GetNWFloat("SmartAntiAFK_CurrentUTimePause")) --Adds current pause time to total offset for UTime
		self:SetNWFloat("SmartAntiAFK_CurrentUTimePause", 0) --Resets current pause time
	end

	if SmartAntiAFK.Config.KickPlayer.enable and (not SmartAntiAFK.Config.KickPlayer.botsExempt or not self:IsBot()) then
		table.RemoveByValue(SmartAntiAFK.kickTable, self)
	end

	net.Start("SendAFKMessage")
	net.Send(self) --Remove the notification to the player that they've been marked ask AFK

	startAFKTimer(self) --Restart AFK timer
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
If enabled, resets AFK timer or unAFKs the player if they are AFK upon a key being pushed down
]]

local function resetAFKTimerOrUnAFKPlayerKeyDown(ply, key)
	if SmartAntiAFK.Config.AntiAFKDetectKeyDown then
		resetAFKTimerOrUnAFKPlayer(ply)
	end

	if not SmartAntiAFK.Config.AntiAFKDetectKeyHold then return end

	if not SmartAntiAFK.AntiAFKPlayers[ply:SteamID64()] then
		SmartAntiAFK.AntiAFKPlayers[ply:SteamID64()] = {}
	end

	if not SmartAntiAFK.AntiAFKPlayers[ply:SteamID64()].keysDown then
		SmartAntiAFK.AntiAFKPlayers[ply:SteamID64()].keysDown = {} --Create table to track what keys the client has pushed down to see if it is held down
	end

	SmartAntiAFK.AntiAFKPlayers[ply:SteamID64()].keysDown[key] = true

	timer.Simple(SmartAntiAFK.Config.AntiAFKKeyHoldTimeOut, function()
		if not IsValid(ply) then return end

		SmartAntiAFK.AntiAFKPlayers[ply:SteamID64()].keysDown[key] = nil
	end)
end

--[[
If enabled, resets AFK timer or unAFKs the player if they are AFK upon a key being released
]]

local function resetAFKTimerOrUnAFKPlayerKeyUp(ply, key)
	if SmartAntiAFK.Config.AntiAFKDetectKeyUp then
		resetAFKTimerOrUnAFKPlayer(ply)
	end

	if not SmartAntiAFK.Config.AntiAFKDetectKeyHold or not SmartAntiAFK.AntiAFKPlayers[ply:SteamID64()] or not SmartAntiAFK.AntiAFKPlayers[ply:SteamID64()].keysDown then return end

	SmartAntiAFK.AntiAFKPlayers[ply:SteamID64()].keysDown[key] = nil
end

--[[
If enabled, resets AFK timer or unAFKs the player if they are AFK on mouse movement or a key being held down
]]

local function resetAFKTimerOrUnAFKPlayerMouseMoveOrScrollOrKeyHold(ply, cmd)
	local playerAFKTable = SmartAntiAFK.AntiAFKPlayers[ply:SteamID64()]

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

	SmartAntiAFK.AntiAFKPlayers[ply:SteamID64()] = nil
end

--[[
If enabled, the player who has been AFK the longest will be kicked, if any, when a certain player count is reached
]]

local function kickAFKPlayersOnPlayerCount()
	if not SmartAntiAFK.Config.KickPlayer.enable then return end

	SmartAntiAFK.AntiAFKPlayers.players = SmartAntiAFK.AntiAFKPlayers.players + 1 --Need to get player count this way because there's no way to account for loading players otherwise

	while SmartAntiAFK.kickTable[1] and not IsValid(SmartAntiAFK.kickTable[1]) do
		table.remove(SmartAntiAFK.kickTable, 1)
	end



	if table.IsEmpty(SmartAntiAFK.kickTable) then return end

	local toKick = SmartAntiAFK.kickTable[1]

	local kickConfig = SmartAntiAFK.Config.KickPlayer
	local percentageOrNumber = kickConfig.kickIfPlayerCountPercentageOrNumberReached
	local maxPlayerPercentageReached = percentageOrNumber and SmartAntiAFK.AntiAFKPlayers.players >= kickConfig.kickPlayerCount / 100 * game.MaxPlayers()
	local maxPlayerCountReached = not percentageOrNumber and SmartAntiAFK.AntiAFKPlayers.players >= kickConfig.kickPlayerCount --test out kickAll and these 2 options

	if maxPlayerPercentageReached or maxPlayerCountReached then --Kick AFK people if max player percentage or max allowed players is reached
		smartAFKKick(toKick)
	end
end

--local kickConfig = SmartAntiAFK.Config.KickPlayer print(kickConfig.kickIfPlayerCountPercentageOrNumberReached and SmartAntiAFK.AntiAFKPlayers.players >= kickConfig.kickPlayerCount / 100 * game.MaxPlayers())
--PrintTable(SmartAntiAFK.kickTable)
--kickConfig.kickIfPlayerCountPercentageOrNumberReached
--SmartAntiAFK.AntiAFKPlayers.players > kickConfig.kickPlayerCount / 100 * game.MaxPlayers()

--[[
Removes from player count
]]

local function subtractPlayerCount()
	if not SmartAntiAFK.Config.KickPlayer.enable then return end

	SmartAntiAFK.AntiAFKPlayers.players = SmartAntiAFK.AntiAFKPlayers.players - 1
end

hook.Add("StartCommand", "SmartAntiAFK_UnAFKOnMouseMove", resetAFKTimerOrUnAFKPlayerMouseMoveOrScrollOrKeyHold) --If enabled, the player will be unAFK or have their AFK timer reset upon moving their mouse, scrolling, and/or when holding a key down

hook.Add("PlayerButtonDown", "SmartAntiAFK_UnAFKOnKeyDown", resetAFKTimerOrUnAFKPlayerKeyDown) --If enabled, the player will be unAFK or have their AFK timer reset upon pressing a key down

hook.Add("PlayerButtonUp", "SmartAntiAFK_UnAFKOnKeyUp", resetAFKTimerOrUnAFKPlayerKeyUp) --If enabled, the player will be unAFK or have their AFK timer reset upon lifting a key up

hook.Add("PlayerInitialSpawn", "SmartAntiAFK_StartAFKTimer", startInitialAFKTimer) --Start the AFK timer after a configurable amount of time when the player joins

hook.Add("PlayerDisconnected", "SmartAntiAFK_UnAFKOnDisconnect", cleanUpAntiAFK) --Get rid of any AFK timers and deregister player as AFK with the server if they are AFK when the player disconnects

gameevent.Listen("player_connect") --If enabled, the player who has been AFK the longest will be kicked, if any, when a certain player count is reached

hook.Add("player_connect", "SmartAntiAFK_SmartAntiAFKKickDetection", kickAFKPlayersOnPlayerCount)

gameevent.Listen("player_disconnect") --This is called even when the player hasn't loaded in yet

hook.Add("player_disconnect", "SmartAntiAFK_SmartAntiAFKKickDisconnect", subtractPlayerCount)

--player.GetCount() changes directly after the player is authed and spawned