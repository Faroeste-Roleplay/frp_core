function API.CreateUser(playerId, mappedIdentifiers)
    local userId = MySQL.insert.await(
        [[
            INSERT INTO user (name) VALUES(?)
        ]], 
        {            
            GetPlayerName(playerId)
        })

    if userId then
        MySQL.insert.await(
        [[
            INSERT INTO user_credentials (userId, fivem, steam, ip, license, license2, xbl, live, discord) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?)
        ]],
        {            
            userId,
            mappedIdentifiers.fivem,
            mappedIdentifiers.steam,
            mappedIdentifiers.ip,
            mappedIdentifiers.license,
            mappedIdentifiers.license2,
            mappedIdentifiers.xbl,
            mappedIdentifiers.live,
            mappedIdentifiers.discord,
        })
    end

    return userId
end

function API.GetUserIdByIdentifiers(identifiers, name)
    local mappedIdentifiers =  MapIdentifiers( identifiers )
    local identiferKey = Config.PrimaryIdentifier

    local res = MySQL.single.await([[
        SELECT * 
        FROM user_credentials 
        WHERE ?? = ?
    ]], {
        identiferKey,
        mappedIdentifiers[identiferKey]
    })
    
    if res then 
        return res.userId
    end
end

function API.GetUserFromUserId(userId)
    return API.users[userId]
end

function API.GetUserFromSource(source)
    return API.users[API.sources[source]]
end

function API.GetUserFromCharId(charId)
    return API.users[API.chars[tonumber(charId)]]
end

function API.GetUserFromCitizenId( citizenId )
    return API.users[API.citizen[citizenId]]
end

function API.GetUserIdFromCharId(charId)
    if API.chars[charId] then
        return API.chars[charId]
    else
        local rows = API_Database.query("FRP/GetUserIdByCharId", {charId = charId})
        if #rows > 0 then
            return rows[1].userId
        end
    end
    return nil
end

function API.GetUsers()
    return API.users
end

function API.SetBanned(this, userid, reason)
    if userid ~= nil then
        API_Database.query("FRP/SetBanned", {userId = userid, reason = reason})
        DropPlayer(this, reason)
    end
end


function API.UnBan(this, userid)
    if userid ~= nil then
        API_Database.query("FRP/UnBan", {userId = userid})
    end
end

function API.IsBanned(userId)
    local rows = API_Database.query("FRP/BannedUser", {userId = userId})
    
    if #rows > 0 then
        return rows[1].banned
    else
        return false
    end
end

function API.ClearUserFromCache(source, userId)
    local User = API.users[userId]

    TriggerClientEvent("FRP:_CORE:SetServerIdAsUserId", -1,source, nil)

    API.sources[source] = nil
    API.users[userId] = nil
    API.identifiers[User.primaryIdentifier] = nil
end

function API.CreateCitizenId()
	local isUnique = false
	local citizenId = nil

    repeat
        citizenId = ("%s%s"):format(RandomStr(1), RandomInt(4)):upper()

		local result = MySQL.Sync.prepare('SELECT COUNT(*) as count FROM character WHERE citizenId = ?', { citizenId })

		if result == 0 then
			isUnique = true
		end
    until isUnique

	return citizenId
end

function API.GenerateCharFingerPrint()
	local isUnique = false
	local fingerId = nil

    repeat
        fingerId = tostring(RandomStr(2) .. RandomInt(3) .. RandomStr(1) .. RandomInt(2) .. RandomStr(3) .. RandomInt(4))

		local result = MySQL.prepare.await('SELECT EXISTS(SELECT 1 FROM players WHERE JSON_UNQUOTE(JSON_EXTRACT(metaData, "$.fingerprint")) = ?) AS uniqueCheck', { FingerId })

		if result == 0 then
			isUnique = true
		end
    until isUnique

	return fingerId
end
