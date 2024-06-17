local Proxy = module("frp_lib", "lib/Proxy")
local Tunnel = module("frp_lib", "lib/Tunnel")

VirtualWorld = {}
API = {}
API.users = {} -- key: userId | value: User.class
API.sources = {} -- key: source | value: userId
API.identifiers = {} -- key: identifier | value: userId
API.chars = {}
API.citizen = {}

API.userIdLock = {}

Proxy.addInterface("API", API)
Tunnel.bindInterface("API", API)
Proxy.addInterface("API_DB", API_Database)
Proxy.addInterface("virtual_world", VirtualWorld)

cAPI = Tunnel.getInterface("API")

CreateThread(function()
    API.groupSystem = API.GroupSystem()
    API.groupSystem:Initialize()
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