local discordBotToken = GetConvar("discord_bot_token", '')

local baseUrl = ("https://discord.com/api/guilds/%s"):format(Config.DiscordGuildId)

local headers = {
    ['Content-Type'] = 'application/json',
    ['Authorization'] = string.format('Bot %s', discordBotToken)
}

local cachedUsernames = {}

function API.GetDiscordGuildMember( discordId )
	
    local request = '' -- json.encode({ })
    local url = ('%s/members/%s'):format(baseUrl, discordId)

	local p = promise.new()

	local onResponse = function(status, body, headers, errorData)

		if status ~= 200 then
			return p:reject(tostring(status))
		end

		local response = json.decode(body)

		p:resolve(response)
	end

	PerformHttpRequest(
		url,
		onResponse,
		'GET',
		request,
		headers
	)

	return Citizen.Await(p)
end

function API.GetDiscordNameCached( discordId )
	if not discordId then return end
    return cachedUsernames[ discordId ] or ''
end 

function API.DefineDiscordMemberRole( discordId, roleId )
	if not discordId then return end

	if not name then
		name = cachedUsernames[ discordId ] or ''
	end

    local postBody = json.encode({nick = name})
	local p = promise.new()

    local url = ('%s/members/%s/roles/%s'):format(baseUrl, discordId, roleId)

	local onResponse = function(status, body, headers, errorData)
		local response = json.decode(body)
		p:resolve(response)
	end

	PerformHttpRequest(
		url,
		onResponse,
		'PUT',
		postBody,
		headers
	)

	return Citizen.Await(p)
end

function API.GetDiscordRolesFromUser( discordId )
	if not discordId then return end
	local user =  API.GetDiscordGuildMember( discordId )

	return user?.roles
end

function API.DiscordMemberHasRole( discordId, roleId )
	local roles = API.GetDiscordRolesFromUser( discordId )
	local hasRole = false

	if roles then
		for _, rId in pairs( roles ) do 
			if tonumber(rId) == tonumber(roleId) then
				hasRole = true
			end	
		end
	end
	
	return hasRole
end

function API.RemoveDiscordMemberRole( discordId, roleId )
	if not discordId then return end

	if not name then
		name = cachedUsernames[ discordId ] or ''
	end

    local postBody = json.encode({nick = name})
	local p = promise.new()

    local url = ('%s/members/%s/roles/%s'):format(baseUrl, discordId, roleId)

	local onResponse = function(status, body, headers, errorData)
		local response = json.decode(body)
		p:resolve(response)
	end

	PerformHttpRequest(
		url,
		onResponse,
		'DELETE',
		postBody,
		headers
	)

	return Citizen.Await(p)
end

function API.GetDiscordMemberName( discordId )
	if not discordId then return end
    local discordUser = API.GetDiscordGuildMember( discordId )
	
	local user = discordUser.user

	if not user then return end

    local username = user.username

    if user.global_name then
        username = user.global_name
    end

    cachedUsernames[ discordId ] = username or ''

    return username 
end

function API.DefineDiscordMemberName( discordId, name )
	if not discordId then return end

	if not name then
		name = cachedUsernames[ discordId ] or ''
	end

    local postBody = json.encode({nick = name})
	local p = promise.new()

    local url = ('%s/members/%s'):format(baseUrl, discordId)

	local onResponse = function(status, body, headers, errorData)
		local response = json.decode(body)
		p:resolve(response)
	end

	PerformHttpRequest(
		url,
		onResponse,
		'PATCH',
		postBody,
		headers
	)

	return Citizen.Await(p)
end