RegisterNetEvent("FRP:onUserStarted", function(user)
    local groupSystem = API.groupSystem

    -- Carregar todos os grupos do usuário dessa sessão.
    groupSystem:LoadUserGroupMembership(user, 'USER_ONLY')
end)

RegisterNetEvent("FRP:OnUserSelectCharacter", function(user)
    local groupSystem = API.groupSystem

    -- Carregar todos os grupos da persona dessa sessão.
    groupSystem:LoadUserGroupMembership(user, 'USER_ONLY')
end)

function API.IsPlayerAceAllowedGroup(playerId, groupName)
    if not playerId then
        return false
    end

    return IsPlayerAceAllowed(playerId, string.format("group.%s", groupName)) == 1
end

function API.IsPlayerAceAllowedGroupFlag(playerId, groupName, groupFlagName)
    if not playerId then
        return false
    end

    return IsPlayerAceAllowed(playerId, string.format("group_flag.%s.%s", groupName, groupFlagName)) == 1
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

function isGroupMemberAPrimePrivilege(groupMemberId)

end

function addGroupMember(groupId, userId, characterId)
    return  MySQL.insert.await('INSERT INTO `group_member` (groupId, userId, characterId) VALUES (?, ?, ?)', {
        groupId,
        userId,
        characterId
    })
end

function deleteGroupMember(groupId, userId, characterId)
    local groupMember = getGroupMember(groupId, userId, characterId)

    if not groupMember then
        return false
    end

    local groupMemberId = groupMember.id

    local res = MySQL.query.await('DELETE FROM `group_member` WHERE `groupMemberId` = ? ', {
        groupMemberId,
    })

    return res
end