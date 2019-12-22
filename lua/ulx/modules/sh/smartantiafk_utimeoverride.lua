if not UTime then return end
--SmartAntiAFKUTimePauseTime = CurTime() of when pause begins
--GetUTime() = the time they had upon joining the session
--GetUTimeStart() = the CurTime upon joining

--CurTime() - self:GetUTimeStart() = session time
--self:GetUTime() + CurTime() - self:GetUTimeStart() = total time

--take into account if they aren't afk and have no SmartAntiAFKUTimePauseTime
local plyMetaTable = FindMetaTable("Player")

function plyMetaTable:GetUTimeSessionTime()
	local trueTotalTime = CurTime() - self:GetUTimeStart()
	local currentPauseTimeElapsed = self:GetNWInt("SmartAntiAFK_CurrentUTimePause") ~= 0 and CurTime() - self:GetNWInt("SmartAntiAFK_CurrentUTimePause") or 0
	local totalPauseTimeElapsed = self:GetNWInt("SmartAntiAFK_TotalUTimePause") + currentPauseTimeElapsed

	return trueTotalTime - totalPauseTimeElapsed
end

function plyMetaTable:GetUTimeTotalTime()
	return self:GetUTime() + self:GetUTimeSessionTime()
end

if not SERVER then return end
module("Utime", package.seeall)

if timer.Exists("UTimeTimer") then
	timer.Remove("UTimeTimer")
end

function updateAll()
	local players = player.GetAll()

	for _, ply in ipairs(players) do
		if ply and ply:IsConnected() and not ply:IsSmartAntiAFK() then
			updatePlayer(ply)
		end
	end
end

timer.Create("UTimeTimer", 67, 0, updateAll)

--   CurTime() - SmartAntiAFKUTimePauseTime = the paused time elapsed