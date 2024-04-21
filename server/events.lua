AddEventHandler('playerDropped', function(reason)
	local playerId = source
	local playerPosition = GetEntityCoords( GetPlayerPed( playerId ) )
    
    local userId = API.sources[playerId]
    local User = API.users[userId]

    local wasReleased, userRef = ReleasePlayerUserAsDisconnected(source, reason)


	if wasReleased then
	    if User then 
	        local Character = User:Character()
	        Character:setLastPosition( playerPosition )
			
			TriggerEvent("FRP:playerDropped", playerId, User)
			
		    User:Save()
		    User:ClearCache()
	    end 
	end
	log:captureMessage(('Desconectou %s - %s'):format(GetPlayerName( playerId ), GetPlayerIdentifiers( playerId )[1]))
end)

AddEventHandler('playerConnectionBailed', function(playerId, reason)
	ReleasePlayerUserAsDisconnected(playerId, reason or 'playerConnectionBailed?')
end)
