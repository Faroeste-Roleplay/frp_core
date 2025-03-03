local function ConnectionLog(message, ...)
	print(('^4Conexao: ^7%s'):format(message), ..., '^7')
end


function OnPlayerConnecting(name, setKickReason, deferrals)
	local playerId = source
	local userId = nil

	deferrals.defer()

	local playerSteamNickname = GetPlayerName(playerId)

	-- mandatory wait!
	Wait(0)
	
	local function log(...)
		ConnectionLog(('Player(%s) UserId(%s):'):format(playerSteamNickname, userId and tostring(userId) or '?'), ...)
	end

	local function log_debug(msg)

		-- print('log_debug', ...)

		if DEBUG_LOGS then
			msg = '^4DEBUG ^7' .. msg
			log(msg)
		end
	end

	local function updateDeferrals(...)
		local params = { ... }

		local message = params[1]

		local cardOne = DeferralCards.Card:Create({
			body = {
				DeferralCards.CardElement:TextBlock({
					size = 'extraLarge',
					weight = 'Bolder',
					text = i18n.translate('info.connecting'),
					horizontalAlignment = 'center'
				}),
				DeferralCards.CardElement:TextBlock({
					size = 'medium',
					weight = 'default',
					text = message,
					horizontalAlignment = 'center'
				})
			}
		})

		deferrals.presentCard(cardOne, function(data, rawData)
			deferrals.update(message)
		end)

		log(...)
	end

	local function setDeferralsDone(...)
		local params = { ... }

		local denyReason = params[1]
		local wasDeniedConnection = denyReason ~= nil

		local cardOne = DeferralCards.Card:Create({
			body = {
				DeferralCards.CardElement:TextBlock({
					size = 'extraLarge',
					weight = 'Bolder',
					text = i18n.translate('error.connection_rejected')
				}),
				DeferralCards.CardElement:TextBlock({
					size = 'medium',
					weight = 'default',
					text = string.format(i18n.translate('info.reason'), denyReason)
				})
			},
			actions = {
				DeferralCards.Action:OpenUrl({
					title = i18n.translate('info.access_discord'),
					url = Config.DiscordInvite,
				})
			}
		})

		if wasDeniedConnection then
			log(('Conexão terminada. Motivo: %s'):format(denyReason))

			SetUserIdLock(userId, false)

			deferrals.presentCard(cardOne, function(data, rawData)
				deferrals.done(denyReason)
			end)

			return
		end

		deferrals.done()
	end

	local identifiers = GetPlayerIdentifiers(playerId)
	local mappedIdentifiers = MapIdentifiers(identifiers)

	if not mappedIdentifiers.fivem then
		setDeferralsDone(i18n.translate('error.fivem_not_found'))
		return
	end

	log_debug( ('mappedIdentifiers: %s'):format(json.encode(mappedIdentifiers, { indent = true })) )

	if not IsAnyMappedIdentifierHighTrusted(mappedIdentifiers) then
		return setDeferralsDone(i18n.translate('error.identifiers_not_found'))
	end

	updateDeferrals( i18n.translate('info.searching_user') )

	local matchingUser = GetUserFromIdentifiersRepository(mappedIdentifiers)

	if matchingUser then
		userId = matchingUser.userId

		isUserIdLocked 	  = API.userIdLock[userId] ~= nil
		isUserIdConnected = API.users[userId] ~= nil and GetPlayerEndpoint(API.users[userId]:GetSource()) ~= nil

		isUserIdConnectedOrLocked = isUserIdLocked or isUserIdConnected
	end

	local shouldCreateUser = false

	if userId then
		
		updateDeferrals( i18n.translate('info.checking_ban') )

		local denylistBatch = DenylistBatchRepository:GetBanFromUserId( userId )

		if denylistBatch then
			local batchId 		= denylistBatch.id
			local denyReason 	= denylistBatch.reason
			local denyExpiresAt = denylistBatch.expiresAt
			local denyDuration  = denylistBatch.duration
	
			local isPermanentlyBeingDeniedEntry = denyDuration == nil
	
			if isPermanentlyBeingDeniedEntry then
				return setDeferralsDone( ('\nVocê foi banido do servidor permanentemente.\nO ID do seu ban é %d'):format(batchId) )
			end
	
			denyExpiresAt = denylistBatch.expiresAt / 1000
	
			local timestamp = os.time()
	
			local secondsTillExpiration = os.difftime(denyExpiresAt, timestamp)
	
			if secondsTillExpiration > 0 then
				local dateTillExpiration = seconds_to_days_hours_minutes_seconds(secondsTillExpiration)
	
				local shouldIncludeReason = denyDuration <= 7 --[[ Banimentos de 7 dias ou menos vão incluir o motivo. ]]
	
				return setDeferralsDone(
					('\nVocê foi banido do servidor%s. Esse ban vai se expirar em %s.\nO ID do seu ban é %d'):format(
						shouldIncludeReason and (' por: %s'):format(denyReason) or '',
						dateTillExpiration,
						batchId
					)
				)
			end
	
			--[[ Desativar o baninmento, já passou do tempo de expiração... ]]
			DenylistBatchRepository:SetIsDeactivated(batchId, true)
		end
	end

	if matchingUser then

		log_debug( ('matchingUser: %s'):format(json.encode(matchingUser, { indent = true })) )

		--[[ Usuário encontrado ]]
		local matchingUserNumMatches = matchingUser.matches

		if matchingUserNumMatches == 1 and string.find(matchingUser.identifier, 'ip:') then
			--[[ Ignorar o usuario encontrado caso a unica forma de encontrar tenha sido o identificador do ip. ]]
			--[[ A gente ignora porque pode ter mais deu uma pessoa na mesma rede e a gente não quer que eles conectrem-se no mesmo usuario. ]]
			shouldCreateUser = true

			log_debug('trying to auth via ip, allow user creation')
		else
			if isUserIdConnectedOrLocked then

				log_debug( ('isUserIdConnectedOrLocked connected(%s) locked(%s)'):format(isUserIdConnected and 'true' or 'false', isUserIdLocked and 'true' or 'false') )

				return setDeferralsDone(i18n.translate('error.user_connected'))
			end
		end
	else
		shouldCreateUser = true

		log_debug( ('no user found, allow user creation matchingUserIndex') )
	end


	log_debug( ('shouldCreateUser(%s)'):format(shouldCreateUser == true and 'true' or 'false'))

	--[[ Criar usuário. ]]
	if shouldCreateUser then

		--[[ Não usar mais u userId antigo. ]]
		userId = nil
		--[[ Não vamos mais usar o usuário encontrado anteriormente. ]]
		matchingUser = nil

		updateDeferrals(i18n.translate('info.create_user'))

		userId = API.CreateUser(playerId, mappedIdentifiers)

		if userId == nil then
			return setDeferralsDone(i18n.translate('error.create_user'))
		end
	end
	
	--[[ Mutex lock para o userId. ]]
	SetUserIdLock(userId, true)

	log_debug( ('locking userId(%d)'):format(userId) )

	updateDeferrals( i18n.translate('info.checking_allowlist') )

	local userGroup = matchingUser?.group or 'user'	

	local isGraceTimeActive = IsUserGraceTimeActive(userId)

	-- local wasAuthenticated = allowlistBatch ~= nil
	local isAllowlisted, queuePriority, error = isGraceTimeActive, isGraceTimeActive and 25, nil

	if not isGraceTimeActive then

		isAllowlisted, queuePriority, error = IsAllowlisted(playerId, userGroup, mappedIdentifiers)

		local wasAuthenticated = isAllowlisted

		if not wasAuthenticated then
			local errorMessage = error or ''

			return setDeferralsDone((i18n.translate('info.your_account')):format(errorMessage, playerSteamNickname), false)
		end
	end

	updateDeferrals(i18n.translate('info.authenticated'))

	--[[ Talvez o player tenha se desconectado nesse meio tempo em que a gente está fazendo queries. ]]
	local hasBailedConnection = GetPlayerEndpoint(playerId) == nil

	if hasBailedConnection then
		TriggerEvent('playerConnectionBailed', playerId, i18n.translate('info.connection_canceled') )

		return setDeferralsDone(i18n.translate('error.endpoint'))
	end

	--[[ By ref. ]]
	-- local user = UserRegistry:AddUser(playerId, userId, userGroup, mappedIdentifiers.steam, mappedIdentifiers.license)

	-- --[[ Registrar os dados dos Identity Providers na instancia do User. ]]
	-- onUserCreatedIdentityProviderListener(user)

	API.sources[playerId] = userId

	lib.logger(playerId, 'User', ("AUTENTICADO - %s - source %s - uId %s"):format(GetPlayerName( playerId ), playerId, userId))

	TriggerEvent('playerConnectionAuthenticated', playerId, updateDeferrals, setDeferralsDone, queuePriority)

	--[[ O Queue vai cancelar esse evento caso ele esteja ativo. ]]
	-- if not WasEventCanceled() then
		-- setDeferralsDone()
	-- end
	
	-- exports.oxmysql:single('SELECT id, gold FROM user_gold WHERE userId = ? LIMIT 1' , { userId }, function(row)
	-- 	if row == nil then
	-- 		return
	-- 	end

	-- 	user.setUserGoldId(row.id)
	-- 	user.updateGold(row.gold)
	-- end)

	--[[ #DEBUG: ]]
	--[[
	do
		TriggerEvent('playerConnectionBailed', playerId, 'Debug')

		return setDeferralsDone('No >:a(')
	end
	--]]
end

-- [[ Quando o usuário tenta conectar no servidor ]]
AddEventHandler('playerConnecting', OnPlayerConnecting)



function onPlayerJoining(temporaryPlayerId)
	local permanentPlayerId = source

	temporaryPlayerId = tonumber(temporaryPlayerId)

	local userId = API.sources[temporaryPlayerId]

	API.sources[temporaryPlayerId] = permanentPlayerId

	local identifiers = GetPlayerIdentifiers(temporaryPlayerId)
	local mappedIdentifiers = MapIdentifiers(identifiers)

	API.ConnectUser(permanentPlayerId, userId, mappedIdentifiers)

	-- Users[permanentPlayerId] = user
	-- Users[temporaryPlayerId] = nil

	-- user.setSource(permanentPlayerId)

	-- local steamIdentity   = user.getIdentity('steam')
	-- local discordIdentity = user.getIdentity('discord')

	-- log:captureMessage( ('Usuário %s se conectou | sessao=%d steam="%s" discord="%s" '):format(user.getId(), permanentPlayerId, steamIdentity?.last_nickname, discordIdentity?.last_nickname) )

	-- print( ('playerJoining:: Changed the players netId from(%d) to (%d)'):format(temporaryPlayerId, permanentPlayerId), user, user.source)
end

--[[ Quando o usuário termina de efeturar o login ]]
AddEventHandler('playerJoining', onPlayerJoining)


function ReleasePlayerUserAsDisconnected(playerId, reason)
	local userId = API.sources[playerId]
    local User = API.users[userId]

	if not userId then
		return
	end

	SetUserIdLock(userId, false)

	ConnectionLog( ('Player(%s) UserId(%s):'):format(GetPlayerName(playerId), userId and tostring(userId) or '?') , ('se desconectou, motivo: %s'):format(reason or '?'))
	log:captureMessage( ('Usuário %s se desconectou | "%s" '):format(userId, reason or '?') )

	return true, User
end

function SetUserIdLock(userId, locked)
	if userId then
		API.userIdLock[userId] = locked == true and true or nil
	end

	if DEBUG_LOGS then

		local log

		if locked then
			log = 'locking userId'
		else
			log = 'unlocking userId'
		end

		ConnectionLog( ('UserId(%d):'):format(userId), log )
	end
end
