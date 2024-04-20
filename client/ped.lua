function cAPI.SetPlayerPed(model)
    local modelHash = GetHashKey(model)

    if IsModelValid(modelHash) then
        if not HasModelLoaded(modelHash) then
            RequestModel(modelHash)
            while not HasModelLoaded(modelHash) do
                Citizen.Wait(10)
            end
        end
    end

    SetPlayerModel(PlayerId(), modelHash, true)
    NativeSetRandomOutfitVariation(PlayerPedId(SetPlayerPed))

    -- while not NativeHasPedComponentLoaded(ped) do
    --     Wait(10)
    -- end

    SetModelAsNoLongerNeeded(model)

    Citizen.Wait(200)
end

function cAPI.SetPedScale(ped, num)
    if num == 0 or num == nil then
        SetPedScale(ped, tonumber(1.0))
    else
        SetPedScale(ped, tonumber(num))
    end

    -- Citizen.InvokeNative(0xCC8CA3E88256E58F, ped, 0, 1, 1, 1, 0) -- update
end

function cAPI.SetPedOverlay(ped, data)
    if data ~= "{}" then
        data = json.decode(data)
        for i = 1, #data do
            exports.frp_core:setOverlayData(ped, data[i]) 
        end
    end
end

local WAIST_TYPES = {
    -2045421226,    -- smallest
    -1745814259,
    -325933489,
    -1065791927,
    -844699484,
    -1273449080,
    927185840,
    149872391,
    399015098,
    -644349862,
    1745919061,      -- default
    1004225511,
    1278600348,
    502499352,
    -2093198664,
    -1837436619,
    1736416063,
    2040610690,
    -1173634986,
    -867801909,
    1960266524,      -- biggest    
}

function cAPI.SetPedPortAndWeight(ped, bodySize, pedWeight)
    print('sizeee', bodySize, pedWeight)
    Citizen.InvokeNative(0xA5BAE410B03E7371, ped, bodySize, false, true)     
    Citizen.InvokeNative(0xCC8CA3E88256E58F, ped, 0, 1, 1, 1, 0) 

    Citizen.InvokeNative(0x1902C4CFCC5BE57C,ped, WAIST_TYPES[pedWeight])
    Citizen.InvokeNative(0xCC8CA3E88256E58F,ped, 0, 1, 1, 1, false)
    
end

function cAPI.SetPedFaceFeature(ped, faceFeatures)
    faceFeatures = json.decode(faceFeatures)

    for index, floatValue in pairs(faceFeatures) do
        -- Doesn't need to be requested !!!!!!        
        NativeSetPedFaceFeature(ped, tonumber(index), tonumber(floatValue))
    end
end

function cAPI.SetPedBodyType(ped, bodyTypeHash)
    bodyTypeHash = tonumber(bodyTypeHash)

    -- Doesn't need to be requested !!!!!!

    -- if IsPedMale(ped) then
    Citizen.InvokeNative(0xA5BAE410B03E7371, ped, bodyTypeHash, true, true, true)

    while not NativeHasPedComponentLoaded(ped) do
        Wait(10)
    end
end

function cAPI.SetSkin(ped, componentArray)
    componentArray = json.decode(componentArray)

    local isMale = "female"

    if IsPedMale(ped) then
        isMale = "male"
    end

    for index, componentHash in pairs(componentArray) do        

        if index ~= "porte" then
            if type(componentHash) ~= "table" then

                componentHash = tonumber(componentHash)

                if componentHash ~= 0 then
                    -- Doesn't need to be requested !!!!!!
                    NativeSetPedComponentEnabled(ped, componentHash, true, true)
                end

                while not NativeHasPedComponentLoaded(ped) do
                    Wait(10)
                end

                SetModelAsNoLongerNeeded(componentHash)
            else         

                local categoryIndex = index
                local componentIndex = componentHash[1]
                local variationIndex = componentHash[2]

                for i = 1, #componentsHashNames do

                    local components = componentsHashNames[i]                

                    if components.ped_type == isMale then
                        if components.category_hashname == categoryIndex then                    

                            local componentHash = components.models[componentIndex][variationIndex].hash

                            componentHash = tonumber(componentHash)
                            
                            if componentHash ~= 0 then
                                -- Doesn't need to be requested !!!!!!
                                NativeSetPedComponentEnabled(ped, componentHash, true, true)
                            end
                    
                            while not NativeHasPedComponentLoaded(ped) do
                                Wait(10)
                            end
                    
                            SetModelAsNoLongerNeeded(componentHash)           
                        end

                        if categoryIndex == "BODIES_UPPER" then
                            if components.category_hashname == "BODIES_UPPER" then

                                local componentHash = componentsHashNames[i-2].models[componentIndex][variationIndex].hash
                                Citizen.InvokeNative(0xD3A7B003ED343FD9, ped, componentHash, true, true, true)

                            end
                        end

                    end
                end
                
            end
        end
    end


end

function cAPI.SetPedClothing(ped, clothingArray)
    local numComponents = 0

    if clothingArray ~= "{}" then
        if clothingArray ~= nil then
            if type(clothingArray) == "table" then
                for _, componentHash in pairs(clothingArray) do
                    componentHash = tonumber(componentHash)
                    -- Doesn't need to be requested !!!!!!
                    NativeSetPedComponentEnabled(ped, componentHash, true, true)
                    while not NativeHasPedComponentLoaded(ped) do
                        Wait(10)
                    end
                    SetModelAsNoLongerNeeded(modelHash)
                    numComponents = numComponents + 1
                end
            else
                if clothingArray <= 100 then
                    SetPedOutfitPreset(ped, clothingArray)
                end
            end
        end
    else
        if numComponents <= 0 then
            -- Load default clothing
            if IsPedMale(ped) then
                NativeSetPedComponentEnabled(ped, 0x1B164391, true, true)
                NativeSetPedComponentEnabled(ped, 0x10B87936, true, true)
                NativeSetPedComponentEnabled(ped, 0x11B7CAB1, true, true)
                NativeSetPedComponentEnabled(ped, 0x1526EAB7, true, true)
            else
                NativeSetPedComponentEnabled(ped, 0x15B760CE, true, true)
                NativeSetPedComponentEnabled(ped, 0x1178F4F4, true, true)
                NativeSetPedComponentEnabled(ped, 0x141281DC, true, true)
                NativeSetPedComponentEnabled(ped, 0x1945CE44, true, true)
            end

            while not NativeHasPedComponentLoaded(ped) do
                Wait(10)
            end
        end
    end
end

function cAPI.TaskAnimalInteraction(interaction)
    local ped = PlayerPedId()

    local interactions = {
        -- interactionId      interactionAnimation    propId
        ["injection"] = {"INTERACT_INJECTION", "p_cs_syringe01x"}
    }

    if interactions[interaction] then
        if cAPI.IsPlayerHorseActive() then
            local playerHorse = cAPI.GetPlayerHorse()
            local v = interactions[interaction]

            SetCurrentPedWeapon(ped, GetHashKey("WEAPON_UNARMED"), true, 0, 0, 0)
            TaskAnimalInteraction(ped, playerHorse, GetHashKey(v[1]), v[2] ~= nil and GetHashKey(v[2]) or 0, 0)
        end
    end
end

function cAPI.TaskInteraction(interaction)
    local ped = PlayerPedId()
    local hasWeaponInHead = GetCurrentPedWeapon(ped, 0)

    local unk1 = 1 -- 1 or 3
    local unk2 = 0 -- always
    local unk3 = -1.0

    local interactions = {
        -- p_cs_bottleslim01x
        -- interactionId       propId              promptName     propSlot            interactionAnimation
        ["drink_tonic"] = {"s_inv_antidote01x", -1199896558, "PrimaryItem", "USE_TONIC_SATCHEL_UNARMED_QUICK"},
        ["injection"] = {"s_immunitybooster01x", -1199896558, "PrimaryItem", "USE_STIMULANT_INJECTION_QUICK_LEFT_HAND"}
    }

    if interactions[interaction] then
        local v = interactions[interaction]

        local propEntity = 0
        if v[1] ~= nil then
            propEntity = CreateObject(GetHashKey(v[1]), GetEntityCoords(ped), false, true, false, false, true)
        end

        SetCurrentPedWeapon(ped, GetHashKey("WEAPON_UNARMED"), true, 0, 0, 0)
        TaskItemInteraction_2(ped, GetHashKey(v[2]), propEntity, GetHashKey(v[3]), GetHashKey(v[4]), unk1, unk2, unk3)
    end
end

function cAPI.TaskScriptedAnim(scriptedAnimName)
    local playerPed = PlayerPedId()

    local animDict
    local animName

    if scriptedAnimName == "eat" then
        animDict = "mech_inventory@eating@multi_bite@sphere_d8-4_fruit"
        animName = "quick_right_hand_throw"

        if not HasAnimDictLoaded(animDict) then
            RequestAnimDict(animDict)
            while not HasAnimDictLoaded(animDict) do
                Citizen.Wait(0)
            end
        end

        SetCurrentPedWeapon(playerPed, GetHashKey("WEAPON_UNARMED"), true, 0, 0, 0)
        ClearPedTasks(playerPed)
        TaskPlayAnim(playerPed, animDict, animName, 8.0, -8.0, -1, 32, 0.0, false, 0, false, "", false)
    end
end

function NativeSetRandomOutfitVariation(ped)
    Citizen.InvokeNative(0x283978A15512B2FE, ped, true)
end

function NativeSetPedFaceFeature(ped, index, value)
    Citizen.InvokeNative(0x5653AB26C82938CF, ped, index, value)
    NativeUpdatePedVariation(ped)
end

function NativeSetPedComponentEnabled(ped, componentHash, immediately, isMp)
    local categoryHash = NativeGetPedComponentCategory(not IsPedMale(ped), componentHash)
    -- print(componentHash, categoryHash, NativeGetMetapedType(ped))
    
    Citizen.InvokeNative(0xD3A7B003ED343FD9, ped, componentHash, immediately, isMp, true)
    --NativeUpdatePedVariation(ped)
end

function NativeUpdatePedVariation(ped)
    Citizen.InvokeNative(0x704C908E9C405136, ped)
    Citizen.InvokeNative(0xCC8CA3E88256E58F, ped, false, true, true, true, false)
end

function NativeIsPedComponentEquipped(ped, componentHash)
    return Citizen.InvokeNative(0xFB4891BD7578CDC1, ped, componentHash)
end

function NativeGetPedComponentCategory(isFemale, componentHash)
    return Citizen.InvokeNative(0x5FF9A878C3D115B8, componentHash, isFemale, true)
end

function NativeGetMetapedType(ped)
    return Citizen.InvokeNative(0xEC9A1261BF0CE510, ped)
end

function NativeHasPedComponentLoaded(ped)
    return Citizen.InvokeNative(0xA0BC8FAED8CFEB3C, ped)
end

function cAPI.VaryPedHealth(ped, variation, variationTime)
    if variationTime == nil or variationTime <= 1 then
        SetEntityHealth(ped, GetEntityHealth(ped) + variation)
    else
        Citizen.CreateThread(
            function()
                variationPerTick = variation / variationTime
                while true do
                    local oldValue = GetEntityHealth(ped)
                    SetEntityHealth(ped, oldValue + variationPerTick)

                    variationTime = variationTime - 1

                    if variationTime <= 0 then
                        break
                    end

                    Citizen.Wait(1000)
                end
            end
        )
    end
end

--     -1000.0 - 1000.0
function cAPI.VaryPedStamina(ped, variation, variationTime)
    if variationTime == nil or variationTime <= 1 then
        -- Citizen.InvokeNative(0xC3D4B754C0E86B9E, ped, variation) -- _CHARGE_PED_STAMINA
        Citizen.InvokeNative(0x675680D089BFA21F, ped, variation) -- _RESTORE_PED_STAMINA
    else
        Citizen.CreateThread(
            function()
                variationPerTick = variation / variationTime
                while variationTime > 0 do
                    local oldValue = GetPedStamina(ped)
                    -- Citizen.InvokeNative(0xC3D4B754C0E86B9E, ped, oldValue + variationPerTick) -- _CHARGE_PED_STAMINA
                    Citizen.InvokeNative(0x675680D089BFA21F, ped, variationPerTick) -- _RESTORE_PED_STAMINA

                    variationTime = variationTime - 1

                    if variationTime <= 0 then
                        break
                    end

                    Citizen.Wait(1000)
                end
            end
        )
    end
end

function cAPI.VaryPedCore(ped, core, variation, variationTime, goldenEffect)
    if variationTime == nil or variationTime <= 1 then
        local oldCoreValue = GetAttributeCoreValue(ped, core)
        Citizen.InvokeNative(0xC6258F41D86676E0, ped, core, oldCoreValue + variation)
    else
        Citizen.CreateThread(
            function()
                valuePerTick = variation / variationTime
                while true do
                    local oldCoreValue = GetAttributeCoreValue(ped, core)
                    Citizen.InvokeNative(0xC6258F41D86676E0, ped, core, oldCoreValue + valuePerTick)

                    variationTime = variationTime - 1

                    if variationTime <= 0 then
                        break
                    end

                    Citizen.Wait(1000)
                end
            end
        )
    end
end

function cAPI.PackPedComponentsCustomizable( playerAppearanceComponents )
    return {
        overridePedModel = playerAppearanceComponents?.pedModel,
        overridePedIsMale = playerAppearanceComponents?.pedIsMale,

        -- equippedOutfitId = playerAppearanceComponents.hair[1],

        hairApparatusId = playerAppearanceComponents?.hair[1],
        hairApparatusStyleId = playerAppearanceComponents?.hair[2],

        mustacheApparatusId = playerAppearanceComponents?.mustache?[1] or 0,
        mustacheApparatusStyleId = playerAppearanceComponents?.mustache?[2] or 0,

        weightPercentage = playerAppearanceComponents.waistType,
    }
end

function cAPI.PackPedComponents( playerProfileCreation, playerAppearanceComponents )
    return {
        isMale = playerProfileCreation?.isMale,
        bodyApparatusId = playerAppearanceComponents?.BODIES_UPPER[2],
        bodyApparatusStyleId = playerAppearanceComponents?.BODIES_UPPER[1],

        headApparatusId = playerAppearanceComponents?.heads[1],
        teethApparatusStyleId = playerAppearanceComponents?.teeth[2],
        eyesApparatusId = playerAppearanceComponents?.eyes[1],
        eyesApparatusStyleId = playerAppearanceComponents?.eyes[2],

        -- whistleShape = playerAppearanceComponents[1],
        -- whistlePitch = playerAppearanceComponents[1],
        -- whistleClarity = playerAppearanceComponents[1],

        height = playerProfileCreation?.pedSize,
        -- bodyWeightOufitType = playerAppearanceComponents[1],
        -- bodyKindType = playerAppearanceComponents[1],
    }
end

function cAPI.UnpackPedComponents ( playerAppearance )

end