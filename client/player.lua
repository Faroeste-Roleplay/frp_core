local gPedModel
local gCharAppearence
local gLastPosition
local gStats

function cAPI.SetDataAppearence(pedModel, charAppearence)
    gPedModel = pedModel
    gCharAppearence = charAppearence
end

function cAPI.Initialize(pedModel, charAppearence, lastPosition, stats)
    charAppearence = charAppearence[1] 

    gPedModel = pedModel
    gCharAppearence = charAppearence
    gLastPosition = lastPosition
    gStats = stats   

    if lastPosition == nil then
        lastPosition = Config.DefaultSpawnPosition
    end
    decodedLastPosition = lastPosition
    if type(lastPosition) ~= "vector3" then
        decodedLastPosition = json.decode(lastPosition)
    end
    
    if decodedLastPosition.x ~= nil then
        decodedLastPosition = {decodedLastPosition.x, decodedLastPosition.y, decodedLastPosition.z}
    end

    local pScale = gCharAppearence?.pedSize
    -- local pClothing

    -- if type(clothing) ~= "string" then
    --     if clothing <= 100 then
    --         pClothing = clothing
    --     end
    -- else
    --     pClothing = json.decode(clothing)
    -- end

    local pStats = stats

    CreateThread(function()
        cAPI.PlaySkyCameraAnimationAtCoords(decodedLastPosition)
        cAPI.PlayerAsInitialized(true)
    end)

    -- cAPI.ReplaceWeapons({})
    
    -- cAPI.SetPlayerPed(pedModel)

    -- cAPI.SetPlayerAppearence(PlayerPedId())
    --  cAPI.SetPedCloAthing(PlayerPedId(), pClothing)

    pHealth = pStats?[1] or 250
    pStamina = pStats?[2] or 34.0
    pHealthCore = pStats?[3] or 100
    pStaminaCore = pStats?[3] or 100

    Wait(3000)

    cAPI.VaryPlayerHealth(pHealth)
    cAPI.VaryPlayerStamina(pStamina)
    cAPI.VaryPlayerCore(0, pHealthCore)
    cAPI.VaryPlayerCore(1, pStaminaCore)

    TriggerServerEvent("FRP:RESPAWN:CheckDeath")
    TriggerServerEvent("API:pre_OnUserCharacterInitialization")
end

function cAPI.SetPlayerAppearence(playerId)

    --cAPI.SetPedBodyType(PlayerPedId(), pBodySize)    

    cAPI.SetSkin(playerId, gCharAppearence?.enabledComponents)   

    cAPI.SetPedFaceFeature(playerId, gCharAppearence?.faceFeatures)    

    cAPI.SetPedScale(playerId, gCharAppearence?.pedHeight) 
    
    cAPI.SetPedOverlay(playerId, gCharAppearence?.overlays)
    
    local bodySize = json.decode(gCharAppearence?.enabledComponents)

    cAPI.SetPedPortAndWeight(playerId, bodySize?['porte'] or 0, gCharAppearence?.pedWeight)

    if gCharAppearence?.clothes ~= nil then
        cAPI.SetSkin(playerId, gCharAppearence?.clothes)   
    end
    
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


function cAPI.GetMyOrg()
    return Player.orgs
end

function cAPI.SetMyOrg(orgs)
    Player.orgs = json.decode(orgs)
end


function cAPI.HasGroup(group)
    local bit = config_file_GROUPS[group:lower()]

    if bit ~= nil then
        return (Player.role & bit) ~= 0
    end

    return false
end

function cAPI.HasGroupOrInheritance(group)
    if cAPI.HasGroup(group) then
        return true
    else
        for superGroup, childrenGroup in pairs(config_file_INHERITANCE) do
            if childrenGroup == group then
                if cAPI.HasGroup(superGroup) then
                    return true
                end
            end
        end
    end

    return false
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

function cAPI.OpioUse(variation)
    variationTime = 10
    for i = 0, 1 do
        cAPI.VaryPedCore(PlayerPedId(), i, 100, variationTime, 1)
    end
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