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

RegisterNetEvent('FRP:sv_playAmbSpeech', function(pedNet, line)
    TriggerClientEvent('FRP:cl_onPlayAmbSpeech', -1, pedNet, line)
end)

AddEventHandler("net.session.requestEnterDimension", function(playerId, dimensionId, transportEntityNetworkId)
    -- Garantir que a dimensão corresponde ao jogador
    if tonumber(dimensionId) ~= tonumber(playerId) then
        return
    end

    -- Se um transportEntityNetworkId for fornecido, ajustar sua dimensão
    if transportEntityNetworkId then
        local transportEntityId = NetworkGetEntityFromNetworkId(transportEntityNetworkId)

        if transportEntityId then
            SetEntityRoutingBucket(transportEntityId, dimensionId)
        end
    end

    -- Ajustar a dimensão do jogador
    VirtualWorld:AddPlayerOnVirtualWorld(playerId, dimensionId)
end)


AddEventHandler("net.session.requestEnterDimension", function(playerId, dimensionId, transportEntityNetworkId)
    -- Garantir que o jogador está em uma dimensão (não na padrão)
    if GetPlayerRoutingBucket(playerId) == 0 then
        return
    end

    -- Se um transportEntityNetworkId for fornecido, ajustar sua dimensão de volta para 0
    if transportEntityNetworkId then
        local transportEntityId = NetworkGetEntityFromNetworkId(transportEntityNetworkId)

        if transportEntityId then
            SetEntityRoutingBucket(transportEntityId, 0)
        end
    end

    -- Ajustar a dimensão do jogador de volta para 0
    VirtualWorld:AddPlayerOnVirtualWorld(playerId, 0)
end)