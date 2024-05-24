function API.ConnectUser(source, userId, identifiers)
    if API.users[userId] then
        return
    end

    local User = API.User(source, userId, GetPlayerEndpoint(source), identifiers)
    User:Initialize();

    API.users[userId] = User

    print(#GetPlayers() .. "/" .. GetConvarInt('sv_maxclients', 32) .. " | " .. GetPlayerName(source) .. " (" .. User:GetIpAddress() .. ") entrou (userId = " .. userId .. ", source = " .. source .. ")")

    TriggerEvent("FRP:onUserLoaded", User)

    TriggerClientEvent("FRP:_CORE:SetServerIdAsUserId", -1, source, userId)
    TriggerClientEvent("FRP:_CORE:SetServerIdAsUserIdPacked", source, API.sources)

    return User
end

function API.DropUser(playerId, playerPosition, reason)
    local userId = API.sources[playerId]
    local User = API.users[userId]

	local Character = User:GetCharacter()

	if Character then
		Character:SavePosition( playerPosition )
	end

    local wasReleased, userRef = ReleasePlayerUserAsDisconnected(playerId, reason)

	if wasReleased then
		TriggerEvent("FRP:playerDropped", playerId, User)
        API.ClearUserFromCache(playerId, userId)
	end
end