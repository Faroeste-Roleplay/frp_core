function FindHighestMatchingUserForPlayerIdentifiers(playerIdentifierIds)
	local result = UserPlayerIdentifierRepository:FindAndOrderByPlayerIdentifiers(playerIdentifierIds)

	if #result <= 0 then
		return nil
	end

	--[[ Tá ordenado em ordem decrescente, então o primeiro sempre vai ser o mais compatível ]]
	--[[
	local highestMatchingUser = result[1]

	return highestMatchingUser
	]]

	return result
end