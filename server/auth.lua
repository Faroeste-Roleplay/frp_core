function API.ConnectUser(source, userId, identifiers)
    if API.users[userId] then
        local user = API.users[userId]
        local oldId = user:GetSource()

        if oldId == tonumber(source) then
            return
        end
    end

    local User = API.User(source, userId, GetPlayerEndpoint(source), identifiers)
    User:Initialize();

    print(#GetPlayers() .. "/" .. GetConvarInt('sv_maxclients', 32) .. " | " .. GetPlayerName(source) .. " (" .. User:GetIpAddress() .. ") entrou (userId = " .. userId .. ", source = " .. source .. ")")

    TriggerEvent("FRP:onUserLoaded", User)

    TriggerClientEvent("FRP:_CORE:SetServerIdAsUserId", -1, source, userId)
    TriggerClientEvent("FRP:_CORE:SetServerIdAsUserIdPacked", source, API.sources)

    API.users[userId] = User

    lib.logger(source, 'User', ("CONECTOU - %s - source %s - UserId - %s "):format(User:GetName(), source, userId))

    return User
end

function API.DropUser(playerId, playerPosition, reason)
    local userId = API.sources[tostring(playerId)]
    local User = API.users[userId]

    if User then
        local Character = User:GetCharacter()

        if Character then
            User:Logout()
            local dist = #( playerPosition - Config.CoordsToIgnoreCoords )
            if dist > 50 then
                Character:SavePosition( playerPosition )
            end
        end

        lib.logger(source, 'User', ("Desconectou - %s - source %s - UserId %s "):format(User:GetName(), User:GetSource(), userId))
    end

    ReleasePlayerUserAsDisconnected(playerId, reason)

    TriggerEvent("FRP:playerDropped", playerId, User, reason)
    API.ClearUserFromCache(playerId, userId)
end