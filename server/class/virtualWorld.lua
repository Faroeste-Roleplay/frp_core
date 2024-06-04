
local globalWorldId = 0
local VirtualWorlds = {
    [globalWorldId] = { players = {} }
}

local Players = {}

function VirtualWorld:Create( players, virtualWorldId )
    local virtualWorldId = virtualWorldId or #VirtualWorlds + 1

    local virtualWorld = {
        id = virtualWorldId,
        players = players,
    }

    for _, playerId in pairs( players ) do 

        if Players[playerId] then
            VirtualWorld:RemovePlayerFromVirtualWorld( playerId )
        end

        SetPlayerRoutingBucket(playerId, virtualWorldId)
        Players[playerId] = virtualWorldId
    end

    table.insert(VirtualWorlds, virtualWorld)

    return virtualWorld
end

function VirtualWorld:IsValidWorld( virtualWorldId )
    return VirtualWorlds[virtualWorldId] ~= nil
end

function VirtualWorld:DeleteWorld( virtualWorldId )
    local virtualWorld = VirtualWorlds[virtualWorldId]

    if not virtualWorld then
        return
    end

    for _, playerId in pairs( virtualWorld.players ) do
        VirtualWorld:AddPlayerToGlobalWorld( playerId )
    end

    VirtualWorlds[virtualWorldId] = nil
end

function VirtualWorld:AddPlayerToGlobalWorld( playerId )
    VirtualWorld:AddPlayerOnVirtualWorld( playerId, globalWorldId )
end

function VirtualWorld:AddPlayerOnVirtualWorld( playerId, virtualWorldId )
    local virtualWorld = VirtualWorlds[virtualWorldId]
    local playerOnVirtualWorld = VirtualWorld:GetPlayerVirtualWorld( playerId )

    if not virtualWorld then
        return VirtualWorld:Create( { playerId }, virtualWorldId)
    end

    if playerOnVirtualWorld then
        VirtualWorld:RemovePlayerFromVirtualWorld( playerId )
    end

    SetPlayerRoutingBucket(playerId, virtualWorldId)
    Players[playerId] = virtualWorldId
    table.insert(virtualWorld.players, playerId)
    TriggerEvent("VirtualWorld:PlayerAddedToWorld", playerId, virtualWorldId)
end

function VirtualWorld:RemovePlayerFromVirtualWorld( playerId )
    local playerVirtualWorld = VirtualWorld:GetPlayerVirtualWorld( playerId )

    if not playerVirtualWorld then
        return
    end

    for _, pId in pairs(playerVirtualWorld.players) do 
        if playerId == pId then
            local currentVirtualWorld = Players[playerId]
            playerVirtualWorld[_] = nil
            Players[playerId] = nil
            TriggerEvent("VirtualWorld:PlayerLeftFromWorld", playerId, currentVirtualWorld)
        end
    end
end

function VirtualWorld:GetPlayerVirtualWorld( playerId )
    local playerVirtualWorldId = Players[playerId]
    local virtualWorld = VirtualWorlds[playerVirtualWorldId]
    
    if not virtualWorld then
        return nil
    end

    return virtualWorld
end

function VirtualWorld:GetPlayersFromVirtualWorld( virtualWorldId )
    local virtualWorld = VirtualWorlds[virtualWorldId]
    
    if not virtualWorld then
        return {}
    end

    return virtualWorld.players
end