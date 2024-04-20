function API.destroyResourcesCoreDependancies()
    for _, User in pairs(API.users) do
        User:Logout()
    end
end

function API.getSources()
    return API.sources
end

function API.logs(archive, text)
    archive = io.open(archive, "a")
    if archive then
        archive:write(text .. "\n")
    end
    archive:close()
end

function API.dropPlayer(source, reason)
    local User = API.getUserFromSource(source)
    if User then
        User:drop(reason)
    end
end

function API.kick(source, reason)
    API.dropPlayer(source, reason)
end

function API.NotifyUsersWithGroup(group, message, checkForInheritance)
    for userId, User in pairs(API.users) do
        local Character = User:getCharacter()

        if Character ~= nil then
            if checkForInheritance == nil or checkForInheritance == true then
                if Character:hasGroupOrInheritance(group) then
                    User:notify(message)
                end
            else
                if Character:hasGroup(group) then
                    User:notify(message)
                end
            end
        end
    end
end

function API.NotifyUsersOrg(org_id, message)
    local members = exports.orgs:GetMembersOrg(org_id)

    for userId, User in pairs(API.users) do
        local Character = User:getCharacter()

        if Character ~= nil and members[Character.id] ~= nil and members[Character.id].member_id ~= nil and members[Character.id].member_id > 0 then
            User:notify(message)
        end
    end
end

function API.GroupNameToBit(g)
    return config_file_GROUPS[g] or 0
end