local IS_SERVER = IsDuplicityVersion()

-- Função para ler o conteúdo de um arquivo
local function read_file(filename)
    local file = assert(io.open(filename, "r"))
    local content = file:read("*a")
    file:close()
    return json.decode(content)
end

if not IS_SERVER then
    RegisterNetEvent("FRP:Core:RegisterFileData", function(MpOverlayLayers, HorsesComponents, MpPedsComponents)
        gHorsesComponents = HorsesComponents
        gMpOverlayLayers = MpOverlayLayers
        gMpPedsComponents = MpPedsComponents
    end)
end

CreateThread(function()
    if IS_SERVER then
        gHorsesComponents = read_file("./data/horses_components.json")
        gMpOverlayLayers = read_file("./data/mp_overlay_layers.json")
        gMpPedsComponents = read_file("./data/mp_peds_components.json")
    end
end)

AddEventHandler('playerJoining', function(source)
    if IS_SERVER then
        TriggerClientEvent("FRP:Core:RegisterFileData", gMpOverlayLayers, gHorsesComponents, gMpPedsComponents)
    end
end)