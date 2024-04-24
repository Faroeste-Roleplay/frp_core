function API.Group(id, name, fullName)
    local self = {}
    self.id = id
    self.name = name
    self.fullName = fullName
    self.principal = string.format("group.%s", name)

    self.parent = nil
    self.children = {}
    self.membersId = {}

    self.GetId = function(this)
        return self.id
    end
    self.GetName = function(this)
        return self.name
    end
    self.GetParent = function(this)
        return self.parent
    end
    self.GetChildren = function(this)
        return self.children
    end
    self.GetPrincipal = function(this)
        return self.principal
    end
    self.GetMembersId = function(this)
        return self.membersId
    end
    self.HasMemberId = function(this, memberId)
        for _, id in pairs(self.membersId) do 
            if memberId == id then
                return true
            end
        end
        return false
    end

    self.GetAceForFlag = function(this, flag)
        return string.format("group_flag.%s.%s", self.name, flag)
    end

    self.SetParent = function(this, parent)
        self.parent = parent
    end

    self.AddChild = function(this, child)
        table.insert(self.children, child)
    end

    self.AddMember = function(this, member, addPrincipal)
        local memberId = member:GetSource()

        if self:HasMemberId(memberId) then
            return false
        end

        member:JoinGroup(self, addPrincipal)
        table.insert(self.membersId, memberId)

        if self.parent then
            self.parent:AddMember(member, false)
        end

        return true
    end

    self.RemoveMember = function(this, member)
        local memberId = member:GetSource()

        if not self:HasMemberId(memberId) then
            return false
        end

        local enabledFlags = member:GetEnabledGroupFlags(self)
        member:LeaveGroup(self)

        for idx, id in pairs(self.membersId) do 
            if id == memberId then
                table.remove(self.membersId, idx)
            end
        end

        for _, flag in pairs(enabledFlags) do 
            member:SetGroupFlagDisabled(self, flag)
        end

        if self.parent then
            self.parent:RemoveMember(member, false)
        end

        return true
    end

    return self
end