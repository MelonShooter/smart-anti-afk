timer.Simple(0, function() --Load after UTime
	local plyMetaTable = FindMetaTable("Player")
	if not _G["Utime"] or not plyMetaTable["GetUTimeSessionTime"] then return end

	function plyMetaTable:GetUTimeSessionTime()
		local trueSessionTime = CurTime() - self:GetUTimeStart()
		local currentPauseTimeElapsed = self:GetNWInt("SmartAntiAFK_CurrentUTimePause") ~= 0 and CurTime() - self:GetNWInt("SmartAntiAFK_CurrentUTimePause") or 0
		local totalPauseTimeElapsed = self:GetNWInt("SmartAntiAFK_TotalUTimePause") + currentPauseTimeElapsed

		return trueSessionTime - totalPauseTimeElapsed
	end

	function plyMetaTable:GetUTimeTotalTime()
		return self:GetUTime() + self:GetUTimeSessionTime()
	end
end)