AddEventHandler('playerDropped', function(reason)
	local playerId = source
	local playerPosition = GetEntityCoords( GetPlayerPed( playerId ) )
    
    local userId = API.sources[playerId]
    local User = API.users[userId]

    local wasReleased, userRef = ReleasePlayerUserAsDisconnected(source, reason)

    local Character = User:Character()
    Character:SetLastPosition( playerPosition )

	if wasReleased then
        TriggerEvent("FRP:playerDropped", playerId, User)
	end

	log:captureMessage(('Desconectou %s - %s'):format(GetPlayerName( playerId ), GetPlayerIdentifiers( playerId )[1]))

    User:Save()
    User:ClearCache()
end)

AddEventHandler('playerConnectionBailed', function(playerId, reason)
	ReleasePlayerUserAsDisconnected(playerId, reason or 'playerConnectionBailed?')
end)
