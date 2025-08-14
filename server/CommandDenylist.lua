RegisterCommand('ban', function(source, args, raw)
	local isExecuterConsole = source == 0

	local perpetrator = '?'

	if isExecuterConsole then
		perpetrator = 'Console'
	else
		if not API.IsPlayerAceAllowedGroup( source, "staff" ) then
			return
		end
	end

	if #args < 3 then
		print('/ban {userId} {time} {reason}')
		return
	end

	local toBanUserId = tonumber(args[1])

	assert(toBanUserId, 'userId não pode ser nulo')

	local humanReadableDuration = string.lower(args[2])
	local durationInSeconds = GetSecondsFromHumanReadableTime(humanReadableDuration)

	if humanReadableDuration == 'perma' and (durationInSeconds ~= nil and durationInSeconds <= 0) then
		print('Duração invalida.')
		return
	end

	local reason = nil
	
	do
		table.remove(args, 1) --[[ remover userId. ]]
		table.remove(args, 1) --[[ remover duration. ]]

		reason = table.concat(args, ' ')
	end

	AddUserPlayerTokensToDenylist(
		toBanUserId,
		perpetrator,
		reason,
		durationInSeconds
	)
end)

RegisterCommand('unban', function(source, args, raw)
	local isExecuterConsole = source == 0

	if not isExecuterConsole then
		if not API.IsPlayerAceAllowedGroup( source, "staff") then
			return
		end
	end

	if #args < 1 then
		print('/unban {userId}')
		return
	end

	local toUnbanUserId = tonumber(args[1])

	if not SetAllUserDenylistBatchesAsDeactivated(toUnbanUserId) then
		print('failed to unban')
		return
	end

	print('unbanned')
end)

function AddUserPlayerTokensToDenylist(userId, perpetrator, reason, expirationTimeInSeconds)
    --[[
		{
			{ player_token_id: 1 },
			{ player_token_id: 2 },
			...
		}
	]]
	
	local user = API.GetUserFromUserIdOffline(userId)

	if not user then
		return false
	end
	

	local batchId = DenylistBatchRepository:Create(reason, userId, perpetrator, expirationTimeInSeconds)

	assert(batchId, 'Ocorreu um error ao tentar criar um DenylistBatch :(')

	-- DenylistBatchRepository:Create(batchId, playerTokenIds)

	local userConnected = API.GetUserFromUserId(userId)

	if userConnected then
		userConnected:Drop( ("Você foi banido: %s - %s"):format(reason, expirationTimeInSeconds) )
	end

	print('Banido!')

	return true
end
exports('AddUserPlayerTokensToDenylist', AddUserPlayerTokensToDenylist)


function SetAllUserDenylistBatchesAsDeactivated(userId)
	local result = DenylistBatchRepository:GetBanFromUserId(userId)

	if not result then
		return false
	end

	DenylistBatchRepository:SetIsDeactivated( result.id, true )
	
	return true
end
exports('SetAllUserDenylistBatchesAsDeactivated', SetAllUserDenylistBatchesAsDeactivated)