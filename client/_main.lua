local Tunnel = module("frp_lib", "lib/Tunnel")
local Proxy = module("frp_lib", "lib/Proxy")

API = Tunnel.getInterface("API")
Appearance = {}
cAPI = {}
Player = {}

Tunnel.bindInterface("API", cAPI)
Proxy.addInterface("API", cAPI)

Appearance = Proxy.getInterface("frp_appearance")

initializedPlayer = false

gServerToUserChanged = false
gServerToUser = {}

CreateThread(function()
	Wait(5000)

	if Config.DisableAutoSpawn then
		exports.spawnmanager:setAutoSpawn(false)
	end
end)