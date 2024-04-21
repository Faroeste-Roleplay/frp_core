function API.DestroyResourcesCoreDependancies()
    for _, User in pairs(API.users) do
        User:Logout()
    end
end

function API.GetSources()
    return API.sources
end

function API.Logs(archive, text)
    archive = io.open(archive, "a")
    if archive then
        archive:write(text .. "\n")
    end
    archive:close()
end

function API.DropPlayer(source, reason)
    local User = API.GetUserFromSource(source)
    if User then
        User:Drop(reason)
    end
end

function API.Kick(source, reason)
    API.DropPlayer(source, reason)
end

function API.NotifyUsersWithGroup(group, message, checkForInheritance)
    for userId, User in pairs(API.users) do
        local Character = User:GetCharacter()

        if Character ~= nil then
            if checkForInheritance == nil or checkForInheritance == true then
                if Character:HasGroupOrInheritance(group) then
                    User:Notify(message)
                end
            else
                if Character:HasGroup(group) then
                    User:Notify(message)
                end
            end
        end
    end
end

function API.NotifyUsersOrg(org_id, message)
    local members = exports.orgs:GetMembersOrg(org_id)

    for userId, User in pairs(API.users) do
        local Character = User:GetCharacter()

        if Character ~= nil and members[Character.id] ~= nil and members[Character.id].member_id ~= nil and members[Character.id].member_id > 0 then
            User:Notify(message)
        end
    end
end

function API.GroupNameToBit(g)
    return config_file_GROUPS[g] or 0
end