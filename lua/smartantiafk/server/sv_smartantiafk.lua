util.AddNetworkString("SendAFKMessage")

local plyMetatable = FindMetaTable("Player")
SmartAntiAFK.AntiAFKPlayers = SmartAntiAFK.AntiAFKPlayers or {}
--[[
TODO:
analyze the delays in startafk and how it affects the checks for endafk, see if there will be a bug
also analyze delay in smartAFKKick()
make sure it can parse BOTH roles and usergroups
anti-macro (see freedcamp)
look at freedcamp
make as many config changes as possible happen instantly
MAKE SURE TO MAKE IT SO THAT THEY DO A MAP RESTART FOR CONFIG CHANGES TO TAKE EFFECT
in the end, test all config values to see if they work (especially the delays in combination with other things, like enabling of modules)
]]

--[[
BUGS:
module config changes won't take effect until they go afk again (if they're currently afk, the effects don't happen yet, which means bots will be unaffected by any module config changes)
keyboard focus will not register keystrokes
opening the console/menu will not register as a key
]]

if SmartAntiAFK.Config.KickPlayer.enable then
	SmartAntiAFK.KickTable = SmartAntiAFK.KickTable or {}
	SmartAntiAFK.AntiAFKPlayers.players = SmartAntiAFK.AntiAFKPlayers.players or 0
end

local uTimeExists = _G["Utime"] and _G["Utime"]["updateAll"]

--[[
Kicks player and runs the OnSmartAFKKick hook
]]

local function smartAFKKick(ply)
	local abortKick, overwriteKickReason = hook.Run("OnSmartAFKKick", ply, CurTime() - SmartAntiAFK.AntiAFKPlayers[ply:SteamID64()].time)

	if abortKick then return end

	local kickConfig = SmartAntiAFK.Config.KickPlayer

	if kickConfig.kickDelay > 0 then
		if kickConfig.kickAll then --validate kick again here with the according config values
			timer.Simple(kickConfig.kickDelay, function() --test the delay
				if not IsValid(ply) then return end

				ply:Kick(overwriteKickReason or SmartAntiAFK.Config.Language.KickReason)
			end)
		else
			timer.Simple(kickConfig.kickDelay, function() --test the delay
				if not IsValid(ply) then
					while SmartAntiAFK.KickTable[1] and not IsValid(SmartAntiAFK.KickTable[1]) do
						table.remove(SmartAntiAFK.KickTable, 1)
					end
				end

				if table.IsEmpty(SmartAntiAFK.KickTable) then return end

				SmartAntiAFK.KickTable[1]:Kick(overwriteKickReason or SmartAntiAFK.Config.Language.KickReason)
			end)
		end
	else
		ply:Kick(overwriteKickReason or SmartAntiAFK.Config.Language.KickReason)
	end
end

local function isModuleEnabled(ply, moduleTable)
	if not CAMI or table.IsEmpty(moduleTable.blackList) then return true end --If there's no one in the blackList or no CAMI-supported admin mod is present, everyone is allowed

	if moduleTable.observeInheritance then --Take inheritance into account
		for group in pairs(moduleTable.blackList) do
			if CAMI.UsergroupInherits(ply:GetUserGroup(), group) then
				return not CAMI.UsergroupInherits(ply:GetUserGroup(), group)
			end
		end

		return true --If the player's group doesn't inherit from any of the groups in the list, then the module should be enabled
	else --Don't take inheritance into account
		return not moduleTable.blackList[ply:GetUserGroup()]
	end
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
Registers player as AFK with the server only if they weren't AFK to begin with.
If UTime is used and the config allows it, it will pause UTime for the player. 
If DarkRP is used and the config allows it, it will pause salaries for the player
Notifies the client that they have been marked as AFK.
]]

function plyMetatable:StartSmartAntiAFK()
	local playerAFKTable = SmartAntiAFK.AntiAFKPlayers[self:SteamID64()]
	local config = SmartAntiAFK.Config

	if playerAFKTable and playerAFKTable.time then return end --Don't execute if they're already registered as AFK

	if not isModuleEnabled(self, config) then --Restart timer (for autorefresh) and don't execute if they are blacklisted
		startAFKTimer(self)
		return
	end

	local supressAFK, timeExtension = hook.Run("OnSmartAFK", self)

	if supressAFK then
		timer.Create("SmartAntiAFK_AntiAFK" .. self:UserID(), timeExtension or 0, 1, function()
			if not IsValid(self) then return end

			self:StartSmartAntiAFK()
		end)

		return
	end

	local passBotCheck = not config.KickPlayer.botsExempt or not self:IsBot()

	if not SmartAntiAFK.AntiAFKPlayers[self:SteamID64()] then
		SmartAntiAFK.AntiAFKPlayers[self:SteamID64()] = {}
	end

	SmartAntiAFK.AntiAFKPlayers[self:SteamID64()].time = CurTime() --Registers the user as AFK
	self:SetNWFloat("SmartAntiAFK_AFKTime", CurTime())

	if config.GodPlayer.enable and isModuleEnabled(self, config.GodPlayer) then
		if config.GodPlayer.time > 0 then --If enabled, player will be godded after a configurable amount of seconds after going AFK
			timer.Simple(config.GodPlayer.time, function()
				if not IsValid(self) or not config.GodPlayer.enable or not isModuleEnabled(self, config.GodPlayer) or not self:IsSmartAFK() then return end --Verify this should happen

				self.SmartAntiAFKGodded = true
				self:GodEnable()
			end)
		else
			self.SmartAntiAFKGodded = true
			self:GodEnable()
		end
	end

	if config.KickPlayer.enable and isModuleEnabled(self, config.KickPlayer) and passBotCheck then
		if config.KickPlayer.time > 0 then --If enabled, player will be kicked after a configurable amount of seconds and/or when certain player count is reached after going AFK
			timer.Simple(config.KickPlayer.time, function()
				if not IsValid(self) or not config.KickPlayer.enable or not isModuleEnabled(self, config.KickPlayer) or not self:IsSmartAFK() or not passBotCheck then return end --Verify

				if config.KickPlayer.kickAll then --Kick immediately if enabled
					smartAFKKick(self)
				else --Add to kick queue if they're not going to be kicked immediately. Make sure to check if AFK player still exists
					self.WillBeSmartAFKKicked = true
					table.insert(SmartAntiAFK.KickTable, self)
				end
			end)
		else
			if config.KickPlayer.kickAll then
				smartAFKKick(self)
			else --Add to kick queue if they're not going to be kicked immediately. Make sure to check if AFK player still exists
				self.WillBeSmartAFKKicked = true
				table.insert(SmartAntiAFK.KickTable, self)
			end
		end
	end

	if uTimeExists and config.UTimePause.enable and isModuleEnabled(self, config.UTimePause) then
		if config.UTimePause.time > 0 then --If enabled, UTime will pause for the player after a configurable amount of seconds after going AFK
			timer.Simple(config.UTimePause.time, function()
				if not IsValid(self) or not config.UTimePause.enable or not isModuleEnabled(self, config.UTimePause) or not self:IsSmartAFK() then return end --Verify

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
Deregisters player as AFK with the server only if they were AFK to begin with.
If UTime is used and the config allows it, it will unpause UTime for the player. 
If DarkRP is used and the config allows it, it will unpause salaries for the player.
Gets rid of the notification on the client
]]

function plyMetatable:EndSmartAntiAFK()
	local playerAFKTable = SmartAntiAFK.AntiAFKPlayers[self:SteamID64()]

	if not playerAFKTable or not playerAFKTable.time then return end --Stop if they haven't been registered ask AFK or are blacklisted

	playerAFKTable.time = nil --Deregisters the user as AFK
	self:SetNWFloat("SmartAntiAFK_AFKTime", 0)

	if self.SmartAntiAFKGodded then
		self.SmartAntiAFKGodded = nil
		self:GodDisable()
	end

	if uTimeExists and self:GetNWFloat("SmartAntiAFK_CurrentUTimePause") > 0 then
		local newTotalTime = self:GetNWFloat("SmartAntiAFK_TotalUTimePause") + CurTime() - self:GetNWFloat("SmartAntiAFK_CurrentUTimePause")

		self:SetNWFloat("SmartAntiAFK_TotalUTimePause", newTotalTime) --Adds current pause time to total offset for UTime
		self:SetNWFloat("SmartAntiAFK_CurrentUTimePause", 0) --Resets current pause time
	end

	if self.WillBeSmartAFKKicked then
		table.RemoveByValue(SmartAntiAFK.KickTable, self)
		self.WillBeSmartAFKKicked = false
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
	local playerAFKTable = SmartAntiAFK.AntiAFKPlayers[ply:SteamID64()]

	if SmartAntiAFK.Config.AntiAFKDetectKeyUp then
		resetAFKTimerOrUnAFKPlayer(ply)
	end

	if not SmartAntiAFK.Config.AntiAFKDetectKeyHold or not playerAFKTable or not playerAFKTable.keysDown then return end

	SmartAntiAFK.AntiAFKPlayers[ply:SteamID64()].keysDown[key] = nil
end

--[[
If enabled, resets AFK timer or unAFKs the player if they are AFK on mouse movement or a key being held down
]]

local function resetAFKTimerOrUnAFKPlayerMouseMoveOrScrollOrKeyHold(ply, cmd)
	local playerAFKTable = SmartAntiAFK.AntiAFKPlayers[ply:SteamID64()]
	local config = SmartAntiAFK.Config

	if config.AntiAFKDetectMouseMove and (cmd:GetMouseX() ~= 0 or cmd:GetMouseY() ~= 0) then
		resetAFKTimerOrUnAFKPlayer(ply)
	elseif config.AntiAFKDetectKeyHold and playerAFKTable and playerAFKTable.keysDown and not table.IsEmpty(playerAFKTable.keysDown) then
		resetAFKTimerOrUnAFKPlayer(ply)
	elseif config.AntiAFKDetectScrolling and cmd:GetMouseWheel() ~= 0 then
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
	local kickConfig = SmartAntiAFK.Config.KickPlayer

	if not kickConfig.enable then return end

	local afkPlayers = SmartAntiAFK.AntiAFKPlayers

	afkPlayers.players = afkPlayers.players + 1 --Need to get player count this way because there's no way to account for loading players otherwise

	while SmartAntiAFK.KickTable[1] and not IsValid(SmartAntiAFK.KickTable[1]) do
		table.remove(SmartAntiAFK.KickTable, 1)
	end



	if table.IsEmpty(SmartAntiAFK.KickTable) then return end

	local toKick = SmartAntiAFK.KickTable[1]
	local percentageOrNumber = kickConfig.kickIfPlayerCountPercentageOrNumberReached
	local maxPlayerPercentageReached = percentageOrNumber and afkPlayers.players >= kickConfig.kickPlayerCount / 100 * game.MaxPlayers()
	local maxPlayerCountReached = not percentageOrNumber and afkPlayers.players >= kickConfig.kickPlayerCount --test out kickAll and these 2 options

	if maxPlayerPercentageReached or maxPlayerCountReached then --Kick AFK people if max player percentage or max allowed players is reached
		smartAFKKick(toKick)
	end
end

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