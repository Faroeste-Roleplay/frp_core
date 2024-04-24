function API.ConnectUser(source, userId, identifiers)
    if API.users[userId] then
        return
    end

    local User = API.User(source, userId, GetPlayerEndpoint(source), identifiers)
    User:Initialize();

    API.users[userId] = User

    print(#GetPlayers() .. "/" .. GetConvarInt('sv_maxclients', 32) .. " | " .. GetPlayerName(source) .. " (" .. User:GetIpAddress() .. ") entrou (userId = " .. userId .. ", source = " .. source .. ")")

    TriggerEvent("FRP:spawnSelector:DisplayCharSelection", User)

    TriggerClientEvent("FRP:_CORE:SetServerIdAsUserId", -1, source, userId)
    TriggerClientEvent("FRP:_CORE:SetServerIdAsUserIdPacked", source, API.sources)

    return User
end


RegisterNetEvent("pre_playerSpawned")
AddEventHandler("pre_playerSpawned", function()
    local playerId = source
    local userId = API.sources[playerId]

    if userId then
        local isFirstSpawn = API.onFirstSpawn[userId]
        TriggerEvent("API:playerSpawned", playerId, userId, isFirstSpawn)
        if isFirstSpawn then
            API.onFirstSpawn[userId] = nil
        end
    end
end)

RegisterNetEvent("API:playerSpawned") -- Use this one !!!!!!!!!!!!!!!!!
AddEventHandler("API:playerSpawned", function(source, userId, isFirstSpawn)
    if isFirstSpawn then
        API.ConnectUser(source, userId)
        -- API.onFirstSpawn[userId] = nil
    end
end)

RegisterNetEvent("API:addReconnectPlayer", function()
    local playerId = source
    local identifiers = GetPlayerIdentifiers(playerId)

    local userId = API.GetUserIdByIdentifiers(identifiers, GetPlayerName(playerId))

    if userId then
        API.ConnectUser(playerId, userId)
    end
end)

RegisterNetEvent("FRP:OnUserSelectCharacter")

RegisterNetEvent("API:OnUserCharacterInitialization")
AddEventHandler("API:OnUserCharacterInitialization", function(User, character_id)
    TriggerClientEvent("FRP:EVENTS:CharacterSetRole", User:GetSource(), User:GetCharacter().role)
end)

RegisterNetEvent("API:pre_OnUserCharacterInitialization")
AddEventHandler("API:pre_OnUserCharacterInitialization", function()
    local _source = source
    local User = API.GetUserFromSource(_source)
    local Character = User:GetCharacter()
    TriggerEvent("API:OnUserCharacterInitialization", User, Character:GetId())
end)