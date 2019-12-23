if CLIENT then
	include("smartantiafk/client/cl_smartantiafk.lua")
end

AddCSLuaFile("smartantiafk/client/cl_smartantiafk.lua")
AddCSLuaFile("smartantiafk/smartantiafk_config.lua")
AddCSLuaFile("smartantiafk/smartantiafk_utimeoverride.lua")
include("smartantiafk/smartantiafk_config.lua")
include("smartantiafk/smartantiafk_utimeoverride.lua")

if SERVER then
	include("smartantiafk/server/sv_smartantiafk.lua")
	include("smartantiafk/server/sv_smartantiafk_utimeoverride.lua")
end