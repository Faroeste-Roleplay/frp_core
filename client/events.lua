
RegisterNetEvent("API:onSessionStoppedPlaying")

AddEventHandler("playerSpawned", function()
	TriggerServerEvent("pre_playerSpawned")
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

	TriggerServerEvent("API:addReconnectPlayer")
end)

RegisterNetEvent('FRP:_CORE:SetServerIdAsUserId', function(serverid, userid)
	gServerToUser[serverid] = userid
	gServerToUserChanged    = true
end)

RegisterNetEvent('FRP:_CORE:SetServerIdAsUserIdPacked', function(r)
	gServerToUser        = r
	gServerToUserChanged = true
end)

RegisterNetEvent("FRP:EVENTS:CharacterSetRole", function(_role)
    Player.role = _role
end)

RegisterNetEvent("FRP:EVENTS:CharacterJoinedGroup", function(group)
    if not cAPI.HasGroup(group) then
        local bit = config_file_GROUPS[group:lower()]

        if bit ~= nil then
            Player.role = Player.role | bit
        end
    end
end)

RegisterNetEvent("FRP:EVENTS:CharacterLeftGroup", function(group)
    if cAPI.HasGroup(group) then
        local bit = config_file_GROUPS[group:lower()]

        if bit ~= nil then
            Player.role = Player.role & (~bit)
        end
    end
end)