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
	exports.spawnmanager:setAutoSpawn(false)
end)

--- disable things
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		DisableControlAction(0, 0x580C4473, true) -- hud disable
		DisableControlAction(0, 0xCF8A4ECA, true) -- hud disable

		DisableControlAction(0, 0x399C6619, true) -- loot 2

		DisableControlAction(0, 0xFF8109D8, true) -- loot Alive
		
		DisableControlAction(0, 0x6E9734E8, true) -- DESATIVAR DESISTIR
		DisableControlAction(0, 0x295175BF, true) -- DESATIVAR SOLTAR DA CORDA
	end
end)

Citizen.CreateThread(function()
	while true do

		Citizen.Wait(30000)

		if cAPI.IsPlayerInitialized() then
			local playerPed = PlayerPedId()
			if playerPed and playerPed ~= -1 then
				local x, y, z = table.unpack(GetEntityCoords(playerPed))

				x = tonumber(string.format("%.3f", x))
				y = tonumber(string.format("%.3f", y))
				z = tonumber(string.format("%.3f", z))

				local pHealth = GetEntityHealth(playerPed)
				local pStamina = tonumber(string.format("%.2f",
					Citizen.InvokeNative(0x775A1CA7893AA8B5, playerPed, Citizen.ResultAsFloat())))
				local pHealthCore = Citizen.InvokeNative(0x36731AC041289BB1, playerPed, 0, Citizen.ResultAsInteger())
				local pStaminaCore = Citizen.InvokeNative(0x36731AC041289BB1, playerPed, 1, Citizen.ResultAsInteger())

				TriggerServerEvent("FRP:CacheCharacterStats", { x, y, z }, pHealth, pStamina, pHealthCore,
					pStaminaCore)
			end
		end
	end
end)