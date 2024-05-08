local Tunnel = module("frp_core", "lib/Tunnel")
local Proxy = module("frp_core", "lib/Proxy")

API = Tunnel.getInterface("API")
cAPI = {}
Tunnel.bindInterface("API", cAPI)
Proxy.addInterface("API", cAPI)

Player = {}

initializedPlayer = false

gServerToUserChanged = false
gServerToUser = {}

CreateThread(function()
	if Config.DisableAutoSpawn then
		exports.spawnmanager:setAutoSpawn(false)
	end
end)