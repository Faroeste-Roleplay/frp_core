
function API.GroupSystem() 
    local self = {}

    self.groups = {}
    self.groupNameById = {}

    self.groupMemberIdToUserId = {}
    self.groupMemberIdToGroupId = {}

    self.groupService = {}

    self.Initialize = function(this)
        local groupModels = MySQL.query.await("SELECT * FROM `group`")

        for _, groupModel in ipairs(groupModels) do
            local id, name, fullName = groupModel.id, groupModel.name, groupModel.fullName

            local group = API.Group(id, name, fullName)

            table.insert(self.groups, group)
            self.groupNameById[id] = name

            local principal = group:GetPrincipal();

            if not IsPrincipalAceAllowed( principal, principal ) then
                ACL.AddAce(principal, principal, true);
                print(string.format("Added ace to [%s] [%s]", name, principal))
            end

            print(string.format("Created [%s]", name))
        end

        for _, groupModel in ipairs(groupModels) do
            local name, parentId = groupModel.name, groupModel.parentId

            if parentId then
                local parentName = self.groupNameById[parentId]

                local child = self:GetGroupByName(name)
                local parent = self:GetGroupByName(parentName)

                child:SetParent(parent)
                parent:AddChild(child)

                local childPrincipal = child:GetPrincipal()
                local parentPrincipal = parent:GetPrincipal()

                ACL.AddPrincipal(childPrincipal, parentPrincipal)

                print(string.format("[%s] Extends [%s]", name, parentName))
            end
        end
    end

    self.GetGroup = function(this, id)
        for _, group in pairs(self.groups) do 
            if group.id == id then
                return group
            end
        end

        return {}
    end

    self.GetGroupByName = function(this, groupName)
        for _, group in pairs(self.groups) do 
            if group.name == groupName then
                return group
            end
        end

        return {}
    end

    self.LoadUserGroupMembership = function(this, user, view)
        local userId = user:GetId()

        local character = user:GetCharacter()
        local characterId

        if character then
            characterId = character:GetId()
        end

        if view == "USER_ONLY" then
            characterId = nil
        end

        local groupMembers = getGroupMembersAnyGroup(userId, characterId)

        for _, groupMember in pairs(groupMembers) do 
            local canAdd = true
            local groupMemberId, groupId = groupMember.id, groupMember.groupId

            local isGroupMemberAPrimePrivilege, primeId = PrimeService.isGroupMemberAPrimePrivilege(groupMemberId)

            if isGroupMemberAPrimePrivilege then
                local isPrimeActive = PrimeService.isPrimeActive(primeId)
                if not isPrimeActive then
                    canAdd = false
                end
            end

            if canAdd then
                local group = self:GetGroup(groupId)
                self:AddUserToGroupLocally(user, group, groupMemberId)
            end
        end
    end

    self.UnloadUserGroupMemberships = function( this, user, view ) 
        local userId = user:GetId()

        local character = user:GetCharacter()
        local characterId

        if character then
            characterId = character:GetId()
        end

        if view == "USER_ONLY" then
            characterId = nil
        end

        local groupMembers = getGroupMembersAnyGroup(userId, characterId)

        for _, groupMember in pairs(groupMembers) do 
            local groupMemberId, groupId = groupMember.id, groupMember.groupId

            local group = self:GetGroup(groupId)

            self:RemoveUserFromGroupLocally(user, group, groupMemberId)
        end
    end

    self.AddUserToGroupLocally = function(this, user, group, groupMemberId)
        group:AddMember(user, true)

        self.groupMemberIdToUserId[groupMemberId] = user:GetSource()
        self.groupMemberIdToGroupId[groupMemberId] = group:GetId()
    end
    self.RemoveUserFromGroupLocally = function(this, user, group, groupMemberId)
        group:RemoveMember(user)

        self.groupMemberIdToUserId[groupMemberId] = nil
        self.groupMemberIdToGroupId[groupMemberId] = nil
    end

    self.AddUserToGroup = function(this, user, group, characterId)
        local groupId = group:GetId()
        local userId = user:GetId()
        
        local groupMemberId = addGroupMember(groupId, userId, characterId)

        if not groupMemberId then
            return
        end

        self:AddUserToGroupLocally(user, group, groupMemberId)
    end
    self.RemoveUserFromGroup = function(this, user, group, characterId)
        local userId = user:GetId()

        local success, groupMemberId = deleteGroupMember(group:GetId(), userId, characterId)

        if not success then
            return false
        end

        self:RemoveUserFromGroupLocally(user, group, groupMemberId)

        return success
    end

    self.AddUserToGroupByName = function(this, user, groupName, characterId)
        local group = self:GetGroupByName(groupName)

        if not group then
            return false
        end

        return self:AddUserToGroup(user, group, characterId)
    end
    self.RemoveUserFromGroupByName = function(this, user, groupName, characterId)
        local group = self:GetGroupByName(groupName)

        if not group then
            return false
        end

        return self:RemoveUserFromGroup(user, group, characterId)
    end

    self.AddUserToGroupById = function(this, user, groupId)
        local group = self:GetGroup(groupId)

        if not group then
            return false
        end

        return self:AddUserToGroup(user, group)
    end
    self.RemoveUserFromGroupById = function(this, user, groupId)
        local group = self:GetGroup(groupId)

        if not group then
            return false
        end

        return self:RemoveUserFromGroup(user, group)
    end
    
    return self
end
