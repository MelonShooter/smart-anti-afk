hook.Add("Initialize", "SmartAntiAFK_LoadUTimeServerOverride", function() --Load after UTime
	if not _G["Utime"] then return end

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
end)