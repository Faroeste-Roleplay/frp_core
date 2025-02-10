local gPedModel
local gCharAppearence
local gLastPosition
local gStats


function cAPI.SetDataAppearence(appearance)
    local pedIsMale = appearance.appearance.isMale
    local pedModel = pedIsMale and 'mp_male' or 'mp_female'
    
    if appearance?.overridePedModel and appearance?.overridePedModel ~= "" then
        pedModel = appearance.overridePedModel
    end

    gPedModel = pedModel
    gCharAppearence = appearance
end

function cAPI.SetPlayerScale()
    local height = gCharAppearence.appearance.height
    setPlayerPedScale( height )
end

function cAPI.SetCharacterId(charId)
    LocalPlayer.state:set('characterId', charId, false)
end

function cAPI.SetCurrentCharacterData(data)
    LocalPlayer.state:set('activeCharacter', data, true)
end

function cAPI.Initialize(pedModel, lastPosition, stats, metadata)
    cAPI.StartFade(500, true)
    TriggerServerEvent("FRP:preCharacterInitialization")
    TriggerEvent("FRP:preCharacterInitialization")

    local decodedLastPosition

    local getFirstCoords = function()
        local random = Config.DefaultFirstSpawnCoords[math.random(1, #Config.DefaultFirstSpawnCoords)]
        return random
    end

    if lastPosition == nil or lastPosition.x == 0 then
        lastPosition = getFirstCoords()
    end

    decodedLastPosition = lastPosition
    if type(lastPosition) ~= "vector3" then
        decodedLastPosition = json.decode(lastPosition)
    end
    
    if decodedLastPosition.x ~= nil then
        decodedLastPosition = {decodedLastPosition.x, decodedLastPosition.y, decodedLastPosition.z}
    end

    local pStats = stats

    local playerPed = PlayerPedId()
    FreezeEntityPosition(playerPed, true)

    if Config.SkyCamSpawnEffect then
        CreateThread(function()
            cAPI.PlaySkyCameraAnimationAtCoords(decodedLastPosition)
        end)
    else
        cAPI.TeleportPlayer( vec3(decodedLastPosition[1], decodedLastPosition[2], decodedLastPosition[3]) )
    end

    cAPI.PlayerAsInitialized(true)

    pHealth = pStats?[1] or 250
    pStamina = pStats?[2] or 34.0
    pHealthCore = pStats?[3] or 100
    pStaminaCore = pStats?[3] or 100

    Wait(3000)

    cAPI.VaryPlayerHealth(pHealth)
    cAPI.VaryPlayerStamina(pStamina)
    cAPI.VaryPlayerCore(0, pHealthCore)
    cAPI.VaryPlayerCore(1, pStaminaCore)

    cAPI.SetPlayerWhistle()

    SetEntityVisible(playerPed, true)
    SetEntityInvincible(playerPed, false)
    NetworkSetEntityInvisibleToNetwork(playerPed, false)
    FreezeEntityPosition(playerPed, false)

    TriggerEvent("FRP:postCharacterInitialization")
    TriggerServerEvent("FRP:postCharacterInitialization")

    if metadata?.walkStyle then
        Citizen.InvokeNative(0xCB9401F918CB0F75, playerPed, metadata.walkStyle, true,-1) -- aplicar walk
    end

    if metadata?.facialExp then
        Citizen.InvokeNative(0x8B3B71C80A29A4BB, playerPed, GetHashKey(metadata.facialExp), 6)
        Citizen.InvokeNative(0xA762C9D6CF165E0D, playerPed, "MoodName", metadata.facialExp, -1)
    end
    
    cAPI.EndFade(500, true)
end

cAPI.ApplyCharacterAppearance = Appearance.ApplyCharacterAppearance
cAPI.GetPedOverlayInstance = Appearance.GetPedOverlayInstance
cAPI.SetPedOverlayInstance = Appearance.SetPedOverlayInstance

function cAPI.SetPlayerAppearence()
    cAPI.ApplyCharacterAppearance(PlayerPedId(), gCharAppearence)

    cAPI.FixStuckAmmoClothingPiece()
end

function cAPI.TeleportPlayer(position, variation)
    local findCollisionLand = false
    local xAdd = math.random(-(variation or 0), variation or 0)
    local yAdd = math.random(-(variation or 0), variation or 0)

    -- DEBUG(" position :: ", position)

    local newCoords = vec3(position.x + xAdd, position.y + yAdd, position.z)
    local _, groundZ, normal = GetGroundZAndNormalFor_3dCoord(newCoords.x, newCoords.y, newCoords.z)

    if _ then
        newCoords = vec3(newCoords.xy, groundZ)
    end

    -- DEBUG(" newCoords :: ", newCoords)
    RequestCollisionAtCoord(newCoords)

    local playerId = PlayerId();
    StartPlayerTeleport(playerId, newCoords.x + 0.0001, newCoords.y + 0.0001, newCoords.z + 0.0001, (position?.w or 0) + 0.0001, true, true, true);

    while IsPlayerTeleportActive() do
        Citizen.InvokeNative(0xC39DCE4672CBFBC1, playerId)
        Wait(500)
    end
    
    StopPlayerTeleport()
end

function cAPI.SetPlayerWhistle()
    local pedId = PlayerPedId()
    local whistlePitch, whistleClarity, whistleShape = 
            gCharAppearence.appearanceCustomizable.whistlePitch, 
            gCharAppearence.appearanceCustomizable.whistleClarity, 
            gCharAppearence.appearanceCustomizable.whistleShape

    N_0x9963681a8bc69bf3(pedId, 'Ped.WhistlePitch', whistlePitch);
    N_0x9963681a8bc69bf3(pedId, 'Ped.WhistleClarity', whistleClarity);
    N_0x9963681a8bc69bf3(pedId, 'Ped.WhistleShape', whistleShape);
end

function cAPI.SetPlayerDefaultModel()
    cAPI.SetPlayerPedModel(gPedModel)
end

function cAPI.PlayerAsInitialized(bool)
    initializedPlayer = bool
end

function cAPI.IsPlayerInitialized()
    return initializedPlayer
end

function cAPI.TeleportPlayerToWaypoint()
    if not IsWaypointActive() then
        return
    end

    local x, y, z = table.unpack(GetWaypointCoords())

    local ped = PlayerPedId()

    -- for i, height in ipairs(groundCheckHeights) do
    -- SetEntityCoordsNoOffset(ped, x, y, height, 0, 0, 1)

    RequestCollisionAtCoord(x, y, z)
    local retVal, groundZ, normal = GetGroundZAndNormalFor_3dCoord(x, y, z)

    if retVal == false then
        RequestCollisionAtCoord(x, y, z)
        local tries = 10
        while retVal == false and tries > 0 do
            Citizen.Wait(100)
            retVal, groundZ, normal = GetGroundZAndNormalFor_3dCoord(x, y, z)
            tries = tries - 1
        end

        z = (groundZ or 2000.0) + 1.0
    end
    -- end

    -- if not groundFound then
    -- 	z = 1200
    -- end

    SetEntityCoordsNoOffset(ped, x, y, z, 0, 0, 1)
end

function cAPI.IsPlayerMountedOnOwnHorse()
    local mount = GetMount(PlayerPedId())

    if mount ~= 0 and mount == cAPI.GetPlayerHorse() then
        return true
    end

    return false
end

function cAPI.VaryPlayerHealth(variation, variationTime)
    cAPI.VaryPedHealth(PlayerPedId(), variation, variationTime)
end

function cAPI.VaryPlayerStamina(variation, variationTime)
    cAPI.VaryPedStamina(PlayerPedId(), variation, variationTime)
end

function cAPI.VaryPlayerCore(core, variation, variationTime, goldenEffect)
    cAPI.VaryPedCore(PlayerPedId(), core, variation, variationTime, goldenEffect)
end

function cAPI.AddWantedTime(wanted, time)
    if wanted then
        local add = 1000 * 60 * time

        if Player.wantedEndTimestamp >= GetGameTimer() then
            Player.wantedEndTimestamp = Player.wantedEndTimestamp + add
        else
            Player.wantedEndTimestamp = GetGameTimer() + add
        end
    end

    if wanted ~= Player.isWanted then
        TriggerServerEvent("FRP:WANTED:MarkAsWanted", wanted)
    end

    Player.isWanted = wanted
end

function cAPI.IsWanted()
    return Player.isWanted ~= nil and Player.isWanted or false
end

function cAPI.VarySickness(variation)
    Player.sickness = math.min(100, Player.sickness + variation)
end


function cAPI.GetSickness()
    return Player.sickness
end

function cAPI.IsPlayerLassoed()
    local isLassoed = Citizen.InvokeNative(0x9682F850056C9ADE, PlayerPedId())

    if isLassoed == false then
        return false
    end

    return true
end

local playerStatus = {}

function cAPI.SaveHealth()
	local playerPed = PlayerPedId()

	local hCore = GetAttributeCoreValue(playerPed, 0)
	local hNormal = Citizen.InvokeNative(0x0317C947D062854E, PlayerId(), Citizen.ResultAsFloat()) --[[ Porque tem que calcular vezes 6????????? ]]
	local sCore = GetAttributeCoreValue(playerPed, 1)
	local sNormal = Citizen.InvokeNative(0x22F2A386D43048A9, playerPed, Citizen.ResultAsFloat())

    playerStatus.hCore = hCore
    playerStatus.hNormal = hNormal
    playerStatus.sCore = sCore
    playerStatus.sNormal = sNormal
end

function cAPI.ReturnLastStatus()
    local ped = PlayerPedId()
    
    SetEntityHealth(ped, playerStatus.hNormal)
    SetAttributeCoreValue(ped, 0, playerStatus.hCore)

    ChangePedStamina(ped, playerStatus.sNormal)
    SetAttributeCoreValue(ped, 1, playerStatus.sCore)
end


-- Citizen.CreateThread(function()
--     while true do
--         Citizen.Wait(0)

--         local diff = wantedEndTimestamp - GetGameTimer()

--         if diff > 1 then
--             if isWanted then
--                 DrawText("Você está procurado por " .. string.format("%.0f", math.max(diff / 1000, 0)) .. " segundos", 0.925, 0.96, 0.25, 0.25, false, 255, 255, 255, 145, 1, 7)
--             end
--         else
--             if isWanted then
--                 isWanted = false
--             end

--             Citizen.Wait(1000)
--         end
--     end
-- end)

-- Citizen.CreateThread(function()
--     local sleep = 1000

--     local animDict = "amb_misc@world_human_vomit@male_a@idle_a"
--     local animName = "idle_b"

--     local isVomiting = false
--     local vomitingTime = 10000

--     while true do
--         sleep = 1000

--         if cAPI.GetSickness() > 0 then
--             sleep = 100

--             Player.sickness = math.max(0, Player.sickness - 0.025)

--             if Player.sickness > 50 then
--                 local playerPed = PlayerPedId()
--                 local v = GetEntityVelocity(playerPed)

--                 -- ? 8.3m/s = 30.0km/h

--                 if GetMount(playerPed) ~= 0 then
--                     if (math.abs(v.x) >= 2.5 or math.abs(v.y) >= 2.5 or math.abs(v.z) >= 2.5) or (Player.sickness >= 95) then
--                         if not isVomiting then
--                             isVomiting = true

--                             Citizen.CreateThread(
--                                 function()
--                                     Citizen.Wait(vomitingTime)
--                                     isVomiting = false
--                                 end
--                             )
--                         end
--                     end
--                 end

--                 if isVomiting then
--                     local moveBlendTarget = playerPed
--                     local flag = 31

--                     if IsPedOnFoot(playerPed) then
--                         -- if not IsPedWalking(playerPed) then
--                         --     flag = 32
--                         -- end
--                     else
--                         local mount = GetMount(playerPed)

--                         if mount ~= 0 then
--                             moveBlendTarget = mount
--                         end
--                     end

--                     SetPedMaxMoveBlendRatio(moveBlendTarget, 0.2)

--                     if not IsEntityPlayingAnim(playerPed, animDict, animName, 3) and Citizen.InvokeNative(0x6AA3DCA2C6F5EB6D, playerPed) == false then
--                         if not HasAnimDictLoaded(animDict) then
--                             RequestAnimDict(animDict)
--                             while not HasAnimDictLoaded(animDict) do
--                                 Citizen.Wait(0)
--                             end
--                         end
--                         TaskPlayAnim(playerPed, animDict, animName, 4.0, 4.0, vomitingTime, flag, 0, true, 0, false, 0, false)
--                     end
--                 end
--             end
--         end

--         Citizen.Wait(sleep)
--     end
-- end)