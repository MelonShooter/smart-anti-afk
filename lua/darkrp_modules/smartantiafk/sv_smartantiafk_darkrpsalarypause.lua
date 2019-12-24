if not SmartAntiAFK.Config.SalaryPause.enable then return end

hook.Add("playerGetSalary", "SmartAntiAFK_PauseSalary", function(ply)
	if ply:IsSmartAFK() then
		return false, SmartAntiAFK.Config.Language.SalaryPausedMessage, 0
	end
end)