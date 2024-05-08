local equippedMetapedClothing = {}
gMetapedClothingSystemOverlayHandler = {}

function handleStartEditor(ped)
    local isMale = IsPedMale(ped);

    local numMetaAssets = N_0x90403e8107b60e81(ped); 

    local boolBuffer = DataView.ArrayBuffer(8 * 5);
    local boolView = boolBuffer:Buffer();
    
    local dataBuffer = DataView.ArrayBuffer(8 * 5);
    local dataView = dataBuffer:Buffer();

    local equippedApparelsHash = {};

    for index = 0, numMetaAssets - 1 do
        local hash = N_0x77ba37622e22023b(ped, index, 1, boolView, dataView);

        equippedApparelsHash[index] = hash;
    end

    local apparelsGender = isMale and eMetapedBodyApparatusGender.Male or eMetapedBodyApparatusGender.Female;

    local equippedApparels = {};

    for _, hash in ipairs(equippedApparelsHash) do
        -- print(" hash :: ", json.encode(hash))
        if hash and hash ~= 0 then
            local apparel = getMetapedBodyApparatusFromShopitemAny(nil, apparelsGender, nil, nil, hash);
            table.insert(equippedApparels, apparel);
        end
    end

    local newEquippedMetapedClothing =
    {
        bodyApparatusId = nil,
        bodyApparatusStyleId = nil,
    
        isMale = nil,
    
        whistleShape = nil,
        whistlePitch = nil,
        whistleClarity = nil,
    
        expressionsMap = {},
    
        overlayLayersMap = {},
    
        equippedApparelsByType = {},
    
        height = nil,
    
        bodyWeightOufitType = nil,
    
        bodyKindType = nil,
    };

    for _, apparel in ipairs(equippedApparels) do
        if apparel ~= nil then
            newEquippedMetapedClothing.equippedApparelsByType[apparel.type] = { id = apparel.id, styleId = apparel.styleId };
        end
    end
    
    gMetapedClothingSystemOverlayHandler = MetapedClothingSystemOverlayHandler.createPlayer()

    equippedMetapedClothing = newEquippedMetapedClothing

    return newEquippedMetapedClothing
end
exports('handleStartEditor', handleStartEditor)
AddEventHandler('appearance:handleStartEditor', handleStartEditor);


function getPedEquippedApparels(pedId, pedIsMale)
    local numMetaAssets = N_0x90403e8107b60e81(pedId); 

    local boolBuffer = DataView.ArrayBuffer(8 * 5);
    local boolView = boolBuffer:Buffer();
    
    local dataBuffer = DataView.ArrayBuffer(8 * 5);
    local dataView = dataBuffer:Buffer();
    
    local equippedApparelsHash = {};
    
    for index = 0, numMetaAssets - 1 do
        local hash = N_0x77ba37622e22023b(pedId, index, 1, boolView, dataView);
    
        table.insert(equippedApparelsHash, hash);
    end
    
    local apparelsGender = pedIsMale and 1 or 0;
    
    local equippedApparels = {};
    
    for _, hash in ipairs(equippedApparelsHash) do
        local apparel = getMetapedBodyApparatusFromShopitemAny(nil, apparelsGender, nil, nil, hash);
    
        table.insert(equippedApparels, apparel);
    end
    
    local equippedApparelsMap = {};
    
    for _, apparel in ipairs(equippedApparels) do
        if apparel ~= nil then
            equippedApparelsMap[apparel.type] = { id = apparel.id, styleId = apparel.styleId };
        end
    end
    
    return equippedApparelsMap;    
end

local UNDEFINED

function requestChangeApparatus(ped, request)
    local requestType = request.type
    local requestSubtype = request.component

    -- print(" requestSubtype :: ", requestSubtype)

    local apparatusTypeName = exports.frp_core:snakeToPascal(requestSubtype:gsub('_COLOR', ''))

    -- print(" apparatusTypeName :: ", apparatusTypeName)

    local apparatusType = eMetapedBodyApparatusType[apparatusTypeName]

    -- print(" apparatusType :: ", apparatusType)

    local isChangeApparatusStyleRequest = requestSubtype:find('COLOR') ~= nil

    -- print(" isChangeApparatusStyleRequest :: ", isChangeApparatusStyleRequest)

    local apparatusId
    local apparatusStyleId

    if isChangeApparatusStyleRequest then
        apparatusStyleId = request.data
    end

    if not isChangeApparatusStyleRequest then
        apparatusId = request.data
    end

    -- print(" apparatusId ", apparatusId)
    -- print(" apparatusStyleId ", apparatusStyleId)

    local equippedApparelsByType = equippedMetapedClothing.equippedApparelsByType
    local equippedBodyApparatusId = equippedMetapedClothing.bodyApparatusId
    local equippedBodyApparatusStyleId = equippedMetapedClothing.bodyApparatusStyleId

    if apparatusType ~= nil then
        local equippedApparatus = equippedApparelsByType[apparatusType]

        local equipApparatusId = apparatusId or equippedApparatus?.id
        local equipApparatusStyleId = apparatusStyleId or equippedApparatus?.styleId

        -- print(" equipApparatusId :: ", equipApparatusId)
        -- print(" equipApparatusStyleId :: ", equipApparatusStyleId)

        if equipApparatusId == nil then
            equipApparatusId = 0
        end

        if equipApparatusStyleId == nil then
            equipApparatusStyleId = 1
        end

        local hasValidApparatus = equipApparatusId > 0

        if hasValidApparatus then
            clothingSystemPushRequest(ped, 'UpdateCurrentApparatus', {
                apparatusType = apparatusType,
                apparatusId = equipApparatusId,
                apparatusStyleId = equipApparatusStyleId
            })

            equippedApparelsByType[apparatusType] = {
                id = equipApparatusId,
                styleId = equipApparatusStyleId
            }

            TriggerEvent("appearance:update:equippedMetapedClothing", "equippedApparelsByType", "set", apparatusType, {
                id = equipApparatusId,
                styleId = equipApparatusStyleId
            })
        else
            clothingSystemPushRequest(ped, 'RemoveCurrentApparatusByType', apparatusType)

            equippedApparelsByType[apparatusType] = nil
            TriggerEvent("appearance:update:equippedMetapedClothing", "equippedApparelsByType", "delete", apparatusType)
        end
    else
        if requestSubtype == 'BODY_TYPE' or requestSubtype == 'SKIN_COLOR' then

            local bodyApparatusId = apparatusId or equippedBodyApparatusId
            local bodyApparatusStyleId = apparatusStyleId or equippedBodyApparatusStyleId
    
            -- print(" bodyApparatusId :: ", bodyApparatusId)
            -- print(" bodyApparatusStyleId :: ", bodyApparatusStyleId)
    
            if bodyApparatusId == nil then
                bodyApparatusId = 1
            end
    
            if bodyApparatusStyleId == nil then
                bodyApparatusStyleId = 1
            end

            equippedMetapedClothing.bodyApparatusId = bodyApparatusId
            equippedMetapedClothing.bodyApparatusStyleId = bodyApparatusStyleId

            clothingSystemPushRequest(ped, 'UpdateCurrentBody', {
                id = bodyApparatusId,
                styleId = bodyApparatusStyleId
            })
        
            local isPedMale = IsPedMale(ped)

            local headApparatus = {
                type = eMetapedBodyApparatusType.Heads,
                gender = isPedMale and eMetapedBodyApparatusGender.Male or eMetapedBodyApparatusGender.Female,
                id = equippedApparelsByType[eMetapedBodyApparatusType.Heads].id,
                styleId = bodyApparatusStyleId
            }

            local shopitemName = getShopitemAnyByMetapedBodyApparatus(headApparatus)
            local shopitemHash = type(shopitemName) == 'string' and GetHashKey(shopitemName) or shopitemName

            local bDrawable = DataView.ArrayBuffer(8);
            local vDrawable = bDrawable:Buffer()

            local bAlbedo = DataView.ArrayBuffer(8);
            local vAlbedo = bAlbedo:Buffer()

            local bNormal = DataView.ArrayBuffer(8);
            local vNormal = bNormal:Buffer()

            local bMaterial = DataView.ArrayBuffer(8);
            local vMaterial = bMaterial:Buffer()

            local bUnk0 = DataView.ArrayBuffer(8);
            local vUnk0 = bUnk0:Buffer()

            local bUnk1 = DataView.ArrayBuffer(8);
            local vUnk1 = bUnk1:Buffer()

            local bUnk2 = DataView.ArrayBuffer(8);
            local vUnk2 = bUnk2:Buffer()

            local bUnk3 = DataView.ArrayBuffer(8);
            local vUnk3 = bUnk3:Buffer()

            local success = Citizen.InvokeNative(0x63342C50EC115CE8, shopitemHash, 0, 0, N_0xec9a1261bf0ce510(ped), 1, vDrawable, vAlbedo, vNormal, vMaterial, vUnk0, vUnk1, vUnk2, vUnk3)

            if success ~= 1 then
                print("Não foi possível encontrar as textures para o componente " .. tostring(shopitemName))
                return
            end

            local albedoHash = bAlbedo:GetInt32(0);
            local normalHash = bNormal:GetInt32(0);
            local materialHash = bMaterial:GetInt32(0);

            -- local albedoHash = DataView.ArrayBuffer(32)
            -- print(" bAlbedo :: ", bAlbedo, json.encode(bAlbedo))
            -- albedoHash:SetInt32(0, bAlbedo.blob)
            -- print("albedoHash", albedoHash, albedoHash:Buffer())

            -- local normalHash = DataView.ArrayBuffer(32)
            -- print(" bNormal :: ", bNormal, json.encode(bNormal))
            -- normalHash:SetInt32(0,bNormal.blob)

            -- local materialHash = DataView.ArrayBuffer(32)
            -- print(" bMaterial :: ", bMaterial, json.encode(bMaterial))
            -- materialHash:SetInt32(0,bMaterial.blob)

            -- print(" UpdateBaseOverlayLayer ================== ")

            -- print("albedoHash", albedoHash)
            -- print("normalHash", normalHash)
            -- print("materialHash", materialHash)

            clothingSystemPushRequest(ped, 'UpdateBaseOverlayLayer', {
                albedo = albedoHash,
                normal = normalHash,
                material = materialHash
            })

            requestChangeApparatus(ped, { component = 'HEADS_COLOR', data = bodyApparatusStyleId, type = 'appearance' })
        end
    end

    handleApparatusChangeAnimation(ped, apparatusType)

    return equippedMetapedClothing
end
exports('requestChangeApparatus', requestChangeApparatus)
