AddEventHandler('playerDropped', function(reason)
	local playerId = source
	local playerPosition = GetEntityCoords( GetPlayerPed( playerId ) )
    
    local userId = API.sources[playerId]
    local User = API.users[userId]

	local Character = User:GetCharacter()

	if Character then
		Character:SavePosition( playerPosition )
	end

    local wasReleased, userRef = ReleasePlayerUserAsDisconnected(source, reason)

	if wasReleased then
        API.ClearUserFromCache(playerId, userId)
		TriggerEvent("FRP:playerDropped", playerId, User)
	end
end)

AddEventHandler('playerConnectionBailed', function(playerId, reason)
	ReleasePlayerUserAsDisconnected(playerId, reason or 'playerConnectionBailed?')
end)
