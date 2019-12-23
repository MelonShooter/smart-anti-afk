hook.Add("Initialize", "SmartAntiAFK_LoadUTimeSharedOverride", function() --Load after UTime
	if not _G["Utime"] then return end

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
end)