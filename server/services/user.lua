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

function API.getUserFromUserId(userId)
    return API.users[userId]
end

function API.GetUserFromSource(source)
    return API.users[API.sources[source]]
end

function API.GetUserIdFromSourceIdentifier(source)
    if source ~= nil then
        local ids = GetPlayerIdentifiers(source)
        if ids ~= nil and #ids > 0 then
            return API.users[ids[1]]
        end
    end
    return nil
end

function API.GetUserFromCharId(charId)
    if API.users[API.chars[tonumber(charId)]] then
        return API.users[API.chars[tonumber(charId)]]
    end
    return nil
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

function API.GetUsersByGroup(group, checkForInheritance)
    local ret = {}

    for userId, User in pairs(API.GetUsers()) do
        local Character = User:GetCharacter()
        if Character ~= nil then
            if checkForInheritance == nil or checkForInheritance == true then
                if Character:HasGroupOrInheritance(group) then
                    table.insert(ret, User)
                end
            else
                if Character:HasGroup(group) then
                    table.insert(ret, User)
                end
            end
        end
    end

    return ret
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

function API.IsWhitelisted(identifier)
    local rows = API_Database.query("FRP/Whitelisted", {identifier = identifier})
    
    if #rows > 0 then        
        return rows[1].whitelist
    else
        return false
    end
end

function API.SetAsWhitelisted(userId, whitelisted)
    if whitelisted then
        if not API.IsWhitelisted(userId) then
            API_Database.execute("AddIdentifierWhitelist", {userId = userId})
            return true
        end
    else
        if API.IsWhitelisted(userId) then
            API_Database.execute("RemoveIdentifierWhitelist", {userId = userId})
            return true
        end
    end

    return false
end

function API.ClearUserFromCache(source, userId)
    local User = API.users[userId]

    TriggerClientEvent("FRP:_CORE:SetServerIdAsUserId", -1,source, nil)

    API.sources[source] = nil
    API.users[userId] = nil
    API.identifiers[User.primaryIdentifier] = nil
end