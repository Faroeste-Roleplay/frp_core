RegisterNetEvent("FRP:onCharacterLoaded")
RegisterNetEvent("FRP:onPlayerDeath")

AddEventHandler('playerDropped', function(reason)
	local playerId = source
	local playerPosition = GetEntityCoords( GetPlayerPed( playerId ) )
    
	API.DropUser(playerId, playerPosition, reason)
end)

AddEventHandler('playerConnectionBailed', function(playerId, reason)
	ReleasePlayerUserAsDisconnected(playerId, reason or 'playerConnectionBailed?')
end)

RegisterNetEvent("FRP:onPlayerSpawned", function()
    local playerId = source
    local userId = API.sources[playerId]

    if userId then
        API.ConnectUser(playerId, userId)
    end
end)

RegisterNetEvent("FRP:addReconnectPlayer", function()
    local playerId = source
    local identifiers = GetPlayerIdentifiers(playerId)

    local userId = API.GetUserIdByIdentifiers(identifiers, GetPlayerName(playerId))

    if userId then
        API.ConnectUser(playerId, userId)
    end
end)