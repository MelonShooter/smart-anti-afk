timer.Simple(0, function() --Load after UTime
	if not Utime or not SmartAntiAFK.Config.UTimePause.enable then return end

	local plyMetatable = FindMetaTable("Player")

	function plyMetatable:GetUTimeSessionTime()
		local trueSessionTime = CurTime() - self:GetUTimeStart()
		local currentPauseTimeElapsed = self:GetNWFloat("SmartAntiAFK_CurrentUTimePause") ~= 0 and CurTime() - self:GetNWFloat("SmartAntiAFK_CurrentUTimePause") or 0
		local totalPauseTimeElapsed = self:GetNWFloat("SmartAntiAFK_TotalUTimePause") + currentPauseTimeElapsed

		return trueSessionTime - totalPauseTimeElapsed
	end

	function plyMetatable:GetUTimeTotalTime()
		return self:GetUTime() + self:GetUTimeSessionTime()
	end
end)