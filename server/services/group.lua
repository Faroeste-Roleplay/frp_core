RegisterNetEvent("FRP:onUserStarted", function(user)
    local groupSystem = API.groupSystem

    -- Carregar todos os grupos do usuário dessa sessão.
    groupSystem:LoadUserGroupMembership(user, 'USER_ONLY')
end)

RegisterNetEvent("FRP:onCharacterLoaded", function(user)
    local groupSystem = API.groupSystem

    -- Carregar todos os grupos da persona dessa sessão.
    groupSystem:LoadUserGroupMembership(user)
end)

RegisterNetEvent("FRP:onCharacterLogout", function (user)
    local groupSystem = API.groupSystem

    -- Liberar todos os grupos da persona dessa sessão.
    groupSystem:UnloadUserGroupMemberships(user)
end)

function API.AddUserToGroupByName( userId, groupName )
    local groupSystem = API.groupSystem
    local User = API.GetUserFromUserId( userId )

    groupSystem:AddUserToGroupByName( User, groupName )
end

function API.RemoveUserFromGroupByName( userId, groupName )
    local User = API.GetUserFromUserId( userId )
    local groupSystem = API.groupSystem

    groupSystem:RemoveUserFromGroupByName( User, groupName )
end

function API.AddCharacterToGroupByName( charId, groupName )
    local User = API.GetUserFromCharId( charId )
    local character = User:GetCharacter()
    assert(character, "Where character??")

    local groupSystem = API.groupSystem

    groupSystem:AddUserToGroupByName( User, groupName, character:GetId() )
end


function API.RemoveCharacterFromGroupByName( charId, groupName )
    local User = API.GetUserFromCharId( charId )
    local character = User:GetCharacter()
    assert(character, "Where character??")

    local groupSystem = API.groupSystem

    groupSystem:RemoveUserFromGroupByName( User, groupName, character:GetId() )
end

function API.IsUserAceAllowedGroup( userId, groupName )
    local User = API.GetUserFromUserId( userId )
    
    return API.IsPlayerAceAllowedGroup( User:GetSource(), groupName )
end

function API.IsCharacterAceAllowedGroup( charId, groupName )
    local User = API.GetUserFromCharId( charId )
    
    return API.IsPlayerAceAllowedGroup( User:GetSource(), groupName )
end

function API.IsPlayerAceAllowedGroup(playerId, groupName)
    if not playerId then
        return false
    end

    return IsPlayerAceAllowed(playerId, string.format("group.%s", groupName)) == 1
end

function API.IsUserAceAllowedGroupFlag( userId, groupName, groupFlagName )
    local User = API.GetUserFromUserId( userId )
    
    return API.IsPlayerAceAllowedGroupFlag( User:GetSource(), groupName, groupFlagName )
end

function API.IsCharacterAceAllowedGroupFlag( charId, groupName, groupFlagName )
    local User = API.GetUserFromCharId( charId )
    
    return API.IsPlayerAceAllowedGroupFlag( User:GetSource(), groupName, groupFlagName )
end

function API.IsPlayerAceAllowedGroupFlag(playerId, groupName, groupFlagName)
    if not playerId then
        return false
    end

    return IsPlayerAceAllowed(playerId, string.format("group_flag.%s.%s", groupName, groupFlagName)) == 1
end

function API.GetPlayersByGroup(g)
    local groupSystem = API.groupSystem
    local group = g

    if type(g) == "string" then
        group = groupSystem:GetGroupByName(g)
    end

    return group:GetMembersId()
end

function getGroupByName(groupName)
    return MySQL.single.await('SELECT * FROM `group` WHERE `groupName` = ? LIMIT 1', {
        groupName
    })
end

function getGroupMember(groupId, userId, characterId) 
    if not characterId then
        return MySQL.single.await('SELECT * FROM `group_member` WHERE `groupId` = ? AND `userId` = ? AND `characterId` IS NULL LIMIT 1', {
            groupId,
            userId
        })
    end

    return MySQL.single.await('SELECT * FROM `group_member` WHERE `groupId` = ? AND `userId` = ? AND `characterId` = ? LIMIT 1', {
        groupId,
        userId,
        characterId
    })
end

function getGroupMembersAnyGroup(userId, characterId)
    if not characterId then
        return MySQL.query.await('SELECT id, groupId FROM `group_member` WHERE `userId` = ? AND `characterId` IS NULL ', {
            userId
        })
    end

    return MySQL.query.await('SELECT id, groupId FROM `group_member` WHERE `userId` = ? AND `characterId` = ? ', {
        userId,
        characterId
    })
end


function addGroupMember(groupId, userId, characterId)
    return MySQL.insert.await('INSERT INTO `group_member` (groupId, userId, characterId) VALUES (?, ?, ?)', {
        groupId,
        userId,
        characterId
    })
end

function deleteGroupMemberFromId( groupMemberId )
    return MySQL.query.await('DELETE FROM `group_member` WHERE `id` = ? ', {
        groupMemberId,
    })
end

function deleteGroupMember(groupId, userId, characterId)
    local groupMember = getGroupMember(groupId, userId, characterId)

    if not groupMember then
        return false
    end

    local groupMemberId = groupMember.id

    return deleteGroupMemberFromId( groupMemberId )
end