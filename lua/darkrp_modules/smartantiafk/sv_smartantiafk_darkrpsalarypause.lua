if not SmartAntiAFK.Config.SalaryPause.enable then return end

hook.Add("playerGetSalary", "SmartAntiAFK_PauseSalary", function(ply)
	local config = SmartAntiAFK.Config
	if ply:IsSmartAFK() and CurTime() - SmartAntiAFK.AntiAFKPlayers[ply:SteamID64()].time >= config.SalaryPause.time and SmartAntiAFK.isModuleEnabled(ply, config.SalaryPause) then
		return false, config.Language.SalaryPausedMessage, 0
	end
end)