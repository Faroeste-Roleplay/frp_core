function GetPlayerTokens(playerId)
	local tokens = { }

	local numTokens = GetNumPlayerTokens(playerId)
	
	for index = 0, numTokens - 1 do
		local token = GetPlayerToken(playerId, index)

		tokens[index + 1] = token
	end

	return tokens
end