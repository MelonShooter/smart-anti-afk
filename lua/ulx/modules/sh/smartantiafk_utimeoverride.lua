if not UTime then return end
--UTimePauseNumber = CurTime() of when pause begins
--GetUTime() = the time they had upon joining the session
--GetUTimeStart() = the CurTime upon joining
--CurTime() - self:GetUTimeStart() = session time
--self:GetUTime() + CurTime() - self:GetUTimeStart() = total time
--take into account if they aren't afk and have no SmartAntiAFKUTimePauseTime
local meta = FindMetaTable("Player")

function meta:GetUTimeTotalTime()

end

function meta:GetUTimeSessionTime()
	
end

if not SERVER then return end
module("Utime", package.seeall)

if timer.Exists("UTimeTimer") then
	timer.Remove("UTimeTimer")
end

function updateAll()
	local players = player.GetAll()

	for _, ply in ipairs(players) do
		if ply and ply:IsConnected() and not ply:IsAFK() then
			updatePlayer(ply)
		end
	end
end

timer.Create("UTimeTimer", 67, 0, updateAll)