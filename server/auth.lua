function API.ConnectUser(source, userId, identifiers)
    if API.users[userId] then
        return
    end

    local User = API.User(source, userId, GetPlayerEndpoint(source), identifiers)
    User:Initialize();

    API.users[userId] = User

    print(#GetPlayers() .. "/" .. GetConvarInt('sv_maxclients', 32) .. " | " .. GetPlayerName(source) .. " (" .. User:GetIpAddress() .. ") entrou (userId = " .. userId .. ", source = " .. source .. ")")

    TriggerEvent("FRP:onUserLoaded", User)

    lib.logger(source, 'User', ("CONECTOU - %s - source %s - UserId - %s "):format(User:GetName(), source, userId))

    TriggerClientEvent("FRP:_CORE:SetServerIdAsUserId", -1, source, userId)
    TriggerClientEvent("FRP:_CORE:SetServerIdAsUserIdPacked", source, API.sources)

    return User
end

function API.DropUser(playerId, playerPosition, reason)
    local userId = API.sources[playerId]
    local User = API.users[userId]

	local Character = User:GetCharacter()

	if Character then
        User:Logout()
		Character:SavePosition( playerPosition )
	end
    
    lib.logger(source, 'User', ("DESCONECTOU - %s - source %s - UserId - %s "):format(User:GetName(), source, userId))

    local wasReleased, userRef = ReleasePlayerUserAsDisconnected(playerId, reason)

	if wasReleased then
		TriggerEvent("FRP:playerDropped", playerId, User)
        API.ClearUserFromCache(playerId, userId)
	end
end