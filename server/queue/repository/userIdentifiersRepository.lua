function GetUserFromIdentifiersRepository(mappedIdentifiers)
    local user

    for key, identifier in pairs(mappedIdentifiers) do

        local res = MySQL.single.await([[
            SELECT id, userId
            FROM `user_credentials` 
            WHERE ?? = ?
        ]], {
            key,
            identifier
        })

        if res?.id then
            user = res
            break
        end
    end

    return user
end
