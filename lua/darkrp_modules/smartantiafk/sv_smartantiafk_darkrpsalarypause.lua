if not SmartAntiAFK.Config.SalaryPause.enable then return end

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

hook.Add("playerGetSalary", "SmartAntiAFK_PauseSalary", function(ply)
	local config = SmartAntiAFK.Config
	if ply:IsSmartAFK() and CurTime() - SmartAntiAFK.AntiAFKPlayers[ply:SteamID64()].time >= config.SalaryPause.time and isModuleEnabled(ply, config.SalaryPause) then
		return false, config.Language.SalaryPausedMessage, 0
	end
end)