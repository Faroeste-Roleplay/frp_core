AddEventHandler('playerDropped', function(reason)
	local playerId = source
	local playerPosition = GetEntityCoords( GetPlayerPed( playerId ) )
    
    local userId = API.sources[playerId]
    local User = API.users[userId]

	local Character = User:Character()
	Character:SetLastPosition( playerPosition )

    local wasReleased, userRef = ReleasePlayerUserAsDisconnected(source, reason)

	if wasReleased then
		TriggerEvent("FRP:playerDropped", playerId, User)
	end
end)

AddEventHandler('playerConnectionBailed', function(playerId, reason)
	ReleasePlayerUserAsDisconnected(playerId, reason or 'playerConnectionBailed?')
end)
