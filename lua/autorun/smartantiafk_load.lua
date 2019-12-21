if CLIENT then
	AddCSLuaFile("smartantiafk/client/cl_smartantiafk.lua")
	AddCSLuaFile("smartantiafk/smartantiafk_config.lua")
	include("smartantiafk/client/cl_smartantiafk.lua")
end

include("smartantiafk/smartantiafk_config.lua")

if SERVER then
	include("smartantiafk/server/sv_smartantiafk.lua")
end