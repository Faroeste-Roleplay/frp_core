
RegisterNetEvent("FRP:onCharacterLogout")

AddEventHandler("playerSpawned", function()
	local playerPed = PlayerPedId()

    SetEntityVisible(playerPed, false)
    SetEntityInvincible(playerPed, true)
    NetworkSetEntityInvisibleToNetwork(playerPed, true)
	
	TriggerServerEvent("FRP:onPlayerSpawned")
end)

AddEventHandler("onClientResourceStart", function() -- Reveal whole map on spawn and enable pvp
    if Config.RevealMap then
        Citizen.InvokeNative(0x4B8F743A4A6D2FF8, true)
    end
end)

CreateThread( function()
    if Config.RevealMap then
        Citizen.InvokeNative(0x4B8F743A4A6D2FF8, true)
    end
end)

AddEventHandler("onClientMapStart",	function()
	-- print("client map initialized")
end)

AddEventHandler("onResourceStart",	function(resourceName)
	if (GetCurrentResourceName() ~= resourceName) then
		return
	end

	local playerPed = PlayerPedId()
    SetEntityVisible(playerPed, false)
    SetEntityInvincible(playerPed, true)
    NetworkSetEntityInvisibleToNetwork(playerPed, true)

	TriggerServerEvent("FRP:addReconnectPlayer")
end)

RegisterNetEvent('FRP:_CORE:SetServerIdAsUserId', function(serverid, userid)
	gServerToUser[serverid] = userid
	gServerToUserChanged    = true
end)

RegisterNetEvent('FRP:_CORE:SetServerIdAsUserIdPacked', function(r)
	gServerToUser        = r
	gServerToUserChanged = true
end)