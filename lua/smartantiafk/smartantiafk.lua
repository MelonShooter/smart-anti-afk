local plyMetatable = FindMetaTable("Player")

--[[
Detects if player is AFK.
Returns true if they are.
Returns false if they are not.
]]

function plyMetatable:IsSmartAFK()
	return self:GetNWFloat("SmartAntiAFK_AFKTime") ~= 0
end

--[[
Returns the amount of time a player has been AFK. 
Returns 0 if they are not AFK
]]

function plyMetatable:AFKTime()
	return self:GetNWFloat("SmartAntiAFK_AFKTime") ~= 0 and CurTime() - self:GetNWFloat("SmartAntiAFK_AFKTime") or 0
end