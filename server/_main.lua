local Proxy = module("frp_lib", "lib/Proxy")
local Tunnel = module("frp_lib", "lib/Tunnel")

VirtualWorld = {}
API = {}
API.users = {} -- key: userId | value: User.class
API.sources = {} -- key: source | value: userId
API.identifiers = {} -- key: identifier | value: userId
API.chars = {}
API.citizen = {}
API.discord = {}
API.userIdLock = {}
API.groupSystem = {}

exports("API", function()
    return API
end)

Proxy.addInterface("API", API)
Tunnel.bindInterface("API", API)
Proxy.addInterface("API_DB", API_Database)
Proxy.addInterface("virtual_world", VirtualWorld)

cAPI = Tunnel.getInterface("API")
PrimeService = Proxy.getInterface("prime")


API.GetGroup = function()
    return API.groupSystem
end

CreateThread(function()
    API.groupSystem = API.GroupSystem()
    API.groupSystem:Initialize()
    
    AddEventHandler("prime:onPrimeExpired", function( prime )
        -- Obter o privGroupMember (simulado como parte do 'prime')
        local groupMemberId = prime.groupMemberId
        local userId = API.groupSystem.groupMemberIdToUserId[groupMemberId]

        local function removeUserFromGroupAreOnline(userId)
            -- Simulando um mapeamento de groupMemberId para sessionId
        
            if not userId then
                return
            end

            local user = API.GetUserFromUserId( userId )
        
            -- Obter o groupId com base no groupMemberId
            local groupId = API.groupSystem.groupMemberIdToGroupId[groupMemberId]
        
            if not groupId then
                return
            end
        
            -- Obter o grupo
            local group = API.groupSystem:GetGroup(groupId)
        
            -- Remover o membro do grupo localmente
            group:RemoveUserFromGroupLocally(user, group, groupMemberId)
        
            print("Remove group member from group because prime expired!")
        end

        local function removeUserOfflineFromGroup( groupMemberId )
            deleteGroupMemberFromId( groupMemberId )
        end


        local isOnline = userId ~= nil

        if isOnline then
            removeUserFromGroupAreOnline(userId)
        end

        -- removeUserOfflineFromGroup( groupMemberId )
    end)
end)

AddEventHandler("onResourceStop", function(resName)
    if resName == GetCurrentResourceName() then
        API.DestroyResourcesCoreDependancies()
    end
end)

SetConvarReplicated('ox:primaryColor', 'dark')
SetConvarReplicated('ox:primaryShade', '9')

-- RegisterCommand("debug_api", function()
--     print(" API users :: ", json.encode(API.users, {intent=true}))
--     print(" ================================= ")
--     print(" API sources :: ", json.encode(API.sources, {intent=true}))
--     print(" ================================= ")
--     print(" API identifiers :: ", json.encode(API.identifiers, {intent=true}))
-- end)

-- AddEventHandler('txAdmin:events:scheduledRestart', function(eventData)
--     if eventData.secondsRemaining ~= 60 then return end

--     for _, user in pairs ( API.users ) do 
--         local playerId = user:GetSource()
--         local playerPosition = GetEntityCoords( GetPlayerPed( playerId ) )

--         TriggerClientEvent("hud:client:requestToSaveStatus", playerId)

--         Wait(200)

--         API.DropUser(playerId, playerPosition, "Servidor agendado para reiniciar")

--         DropPlayer( playerId, "Servidor agendado para reiniciar")
--     end
-- end)