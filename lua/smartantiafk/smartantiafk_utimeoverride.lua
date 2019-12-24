timer.Simple(0, function() --Load after UTime
	local plyMetatable = FindMetaTable("Player")
	if not SmartAntiAFK.Config.UTimePause.enable or not _G["Utime"] or not plyMetatable["GetUTimeSessionTime"] then return end

	function plyMetatable:GetUTimeSessionTime()
		local trueSessionTime = CurTime() - self:GetUTimeStart()
		local currentPauseTimeElapsed = self:GetNWInt("SmartAntiAFK_CurrentUTimePause") ~= 0 and CurTime() - self:GetNWInt("SmartAntiAFK_CurrentUTimePause") or 0
		local totalPauseTimeElapsed = self:GetNWInt("SmartAntiAFK_TotalUTimePause") + currentPauseTimeElapsed

		return trueSessionTime - totalPauseTimeElapsed
	end

	function plyMetatable:GetUTimeTotalTime()
		return self:GetUTime() + self:GetUTimeSessionTime()
	end
end)