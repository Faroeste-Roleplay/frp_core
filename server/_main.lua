local Proxy = module("lib/Proxy")
local Tunnel = module("lib/Tunnel")

API = {}
API.users = {} -- key: userId | value: User.class
API.sources = {} -- key: source | value: userId
API.identifiers = {} -- key: identifier | value: userId
API.chars = {}

API.onFirstSpawn = {}
API.userIdLock = {}

Proxy.addInterface("API", API)
Tunnel.bindInterface("API", API)
Proxy.addInterface("API_DB", API_Database)

cAPI = Tunnel.getInterface("API")

AddEventHandler("onResourceStop", function(resName)
    if resName == GetCurrentResourceName() then
        API.DestroyResourcesCoreDependancies()
    end
end)