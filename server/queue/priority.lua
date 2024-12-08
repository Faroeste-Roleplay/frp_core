function IsAllowlisted(playerId, userGroup, mappedIdentifiers)
	if not Config.Allowlist then
		return true, 100, nil
	end

	local priority = -1
	local error = nil

	local isStaff = userGroup == 'superadmin' or
					userGroup == 'support'

	if isStaff then
		priority = 100

		return true --[[ isAllowlisted ]], priority, nil --[[ error ]]
	end

	local isPrime =    userGroup == 'bronze'
					or userGroup == 'prata'
					or userGroup == 'ouro'
					or userGroup == 'platina'
					or userGroup == 'texas'

	if isPrime then
		priority = 50

		return true --[[ isAllowlisted ]], priority, nil --[[ error ]]
	end

	--[[ Não é staff, então a gente vai verificar baseado nos cargos do discord... ]]
	local discordIdentifier = mappedIdentifiers.discord

	if not discordIdentifier then
		return false, -1, i18n.translate("error.discord_not_found")
	end

	--[[ Vamos lidar com o error gerado pelo request ]]
	local status, err = pcall(function()
		local discordUserId = string.gsub(discordIdentifier, 'discord:', '')

		return FetchGuildMemberObject(discordUserId)
	end)

	if not status then
		local errCode = tonumber(err)

		local errMeaning = err

		if errCode == 400 then
			errMeaning = 'BAD_REQUEST'
		elseif errCode == 401 then
			errMeaning = i18n.translate("error.join_discord")
		elseif errCode == 403 then
			errMeaning = i18n.translate("error.auth_code_invalid")
		elseif errCode == 429 then
			errMeaning = i18n.translate("error.requests_exceeded")
		end

		error = errCode and errMeaning or err

		return false, -1, error
	end

	local guildMember = err

	local date = os.date('*t', os.time())

	local dateHour = date.hour

	--[[ Só verificar os cargos caso nenhum error tenha sido gerado. ]]
	for _, registeredRole in ipairs(gGuildPriorityRoles) do
		for _, role in ipairs(guildMember.roles) do
			if role == registeredRole.roleId then
				local disableAtTimeOfDay = registeredRole.disableAtTimeOfDay

				--[[ 00:00 - 06:00 ]]
				local disabledByTimeOfDay = disableAtTimeOfDay and (dateHour >= 0 and dateHour < 6 )

				if disabledByTimeOfDay then
					priority = -1 --[[ Invalidar a prioridade, deixar para o próximo cargo dizer qual seria ]]
					error = i18n.translate("error.not_priority_role")
				else
					priority = registeredRole.priority
				end
			end
		end
	end

	local isAllowlisted = priority >= 0

	if not isAllowlisted and not error then
		error = i18n.translate("error.not_allowed")
	end

	error = isAllowlisted and nil or error

	return isAllowlisted, priority, error
end

function FetchGuildMemberObject(discordUserId)
	local request = '' -- json.encode({ })

	local p = promise.new()

	local onResponse = function(status, body, headers, errorData)

		if status ~= 200 then
			return p:reject(tostring(status))
		end

		print(" body :: ", body)

		local response = json.decode(body)

		print(" response :: ", response)

		p:resolve(response)
	end

	PerformHttpRequest( 
		('https://discord.com/api/v10/guilds/%s/members/%s'):format(Config.DiscordGuildId, discordUserId),
		onResponse,
		'GET',
		request,
		{
			['Content-Type'] = 'application/json',
			['Authorization'] = string.format('Bot %s', GetConvar("discord_bot_token", ""))
		}
	)

	return Citizen.Await(p)
end

--[[
	Private: prioridade mais alta que a publica
	Public: prioridade e não pode entrar depois das 00:00
]]