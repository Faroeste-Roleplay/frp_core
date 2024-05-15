local Tunnel = module("frp_lib", "lib/Tunnel")
local Proxy = module("frp_lib", "lib/Proxy")

API = Tunnel.getInterface("API")
cAPI = Proxy.getInterface("API")

Player = {}

initializedPlayer = false

gServerToUserChanged = false
gServerToUser = {}

CreateThread(function()
	if Config.DisableAutoSpawn then
		exports.spawnmanager:setAutoSpawn(false)
	end
end)