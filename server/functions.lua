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