function applyCharacterAppearance(pedId, data)
    gMetapedClothingSystemOverlayHandler = MetapedClothingSystemOverlayHandler.createPlayer()

    setDefaultComponentsForPed(pedId);

    -- print(" =========================================== ")
    -- print(" data :: ", json.encode(data, {indent=true}))

    local 
        appearance,
        appearanceCustomizable,
        appearanceOverlays,
        appearanceOverlaysCustomizable
        = data.appearance, data.appearanceCustomizable, data.appearanceOverlays, data.appearanceOverlaysCustomizable;

    assert(appearance, "appearance não definida");
    assert(appearanceCustomizable, "appearanceCustomizable não definida");
    assert(appearanceOverlays, "appearanceOverlays não definida");
    assert(appearanceOverlaysCustomizable, "appearanceOverlaysCustomizable não definida");

    local
        isMale,

        bodyApparatusId,
        bodyApparatusStyleId,

        headApparatusId,

        eyesApparatusId,
        eyesApparatusStyleId,

        whistleShape,
        whistlePitch,
        whistleClarity,

        teethApparatusStyleId,

        expressions,

        height,
        bodyWeightOufitType,
        bodyKindType
        =   appearance.isMale, appearance.bodyApparatusId, appearance.bodyApparatusStyleId, appearance.headApparatusId, appearance.eyesApparatusId, 
            appearance.eyesApparatusStyleId, appearance.whistleShape, appearance.whistlePitch, appearance.whistleClarity, appearance.teethApparatusStyleId, 
            appearance.expressions, appearance.height, appearance.bodyWeightOufitType, appearance.bodyKindType;

        
    local
        hairApparatusId,
        hairApparatusStyleId,

        mustacheApparatusId,
        mustacheApparatusStyleId,

        equippedOutfitApparels
        =   appearanceCustomizable.hairApparatusId, appearanceCustomizable.hairApparatusStyleId, appearanceCustomizable.mustacheApparatusId, 
            appearanceCustomizable.mustacheApparatusStyleId, appearanceCustomizable.equippedOutfitApparels;

    -- SetWhistleConfigForPed
    N_0x9963681a8bc69bf3(pedId, 'Ped.WhistlePitch', whistlePitch);
    N_0x9963681a8bc69bf3(pedId, 'Ped.WhistleClarity', whistleClarity);
    N_0x9963681a8bc69bf3(pedId, 'Ped.WhistleShape', whistleShape);

    -- console.log('applyCharacterAppearance :: body');

    applyCharacterAppearanceHandleBody(pedId, bodyApparatusId or 1, bodyApparatusStyleId or 1, height, bodyWeightOufitType, bodyKindType);

    -- console.log('applyCharacterAppearance :: head');

    applyCharacterAppearanceHandleHead(pedId, headApparatusId or 1, bodyApparatusStyleId or 1);

    -- console.log('applyCharacterAppearance :: eyes');

    applyCharacterAppearanceHandleEyes(pedId, eyesApparatusId or 1, eyesApparatusStyleId or 1);

    -- console.log('applyCharacterAppearance :: teeth');

    applyCharacterAppearanceHandleTeeth(pedId, teethApparatusStyleId or 1);

    -- console.log('applyCharacterAppearance :: expressions');

    applyCharacterAppearanceHandleExpressions(pedId, expressions);

    -- console.log('applyCharacterAppearance :: hair');

    applyCharacterAppearanceHandleHair(pedId, hairApparatusId, hairApparatusStyleId);

    -- console.log('applyCharacterAppearance :: mustache');

    if isMale then
        applyCharacterAppearanceHandleMustache(pedId, mustacheApparatusId, mustacheApparatusStyleId);
    end

    -- console.log('applyCharacterAppearance :: outfit');

    applyCharacterAppearanceHandleOutfit(pedId, equippedOutfitApparels);

    -- console.log('applyCharacterAppearance :: ended');

    -- Os overlays só funcionam em peds networked.
    if NetworkGetNetworkIdFromEntity(pedId) ~= 0 then
        applyCharacterAppearanceHandleOverlays(pedId, headApparatusId, bodyApparatusStyleId, appearanceOverlays, appearanceOverlaysCustomizable);
    end
end

cAPI.ApplyCharacterAppearance = applyCharacterAppearance

function applyCharacterAppearanceHandleExpressions(ped, expressions)
    assert(expressions, " ERRO expressions")

    local entries = {}

    for expressionType, expressionValue in pairs(expressions) do
        table.insert(entries, { expressionType, expressionValue })
    end

    for _, entry in ipairs(entries) do
        local expressionType, expressionValue = entry[1], entry[2]

        clothingSystemPushRequest(ped, 'UpdateCurrentExpression',
        {
            expressionType = expressionType,
            expressionValue = expressionValue,
        })
    end
end

function applyCharacterAppearanceHandleBody(ped, bodyApparatusId, bodyApparatusStyleId, height, bodyWeightOufitType, bodyKindType)
    assert(bodyApparatusId, "bodyApparatusId empty")
    assert(bodyApparatusStyleId, "bodyApparatusStyleId empty")

    clothingSystemPushRequest(ped, 'UpdateCurrentBody',
    {
        id = bodyApparatusId,
        styleId = bodyApparatusStyleId,
    })

    local isPositive = height > 185
    local variation = math.abs(185 - height) * 0.005333

    if not isPositive then
        variation = -variation
    end

    SetPedScale(ped, 1.0 + variation)

    clothingSystemPushRequest(
        ped,
        'UpdateCurrentBodyWeightOutfit',
        { type = bodyWeightOufitType }
    )

    Citizen.InvokeNative(0xA5BAE410B03E7371, ped, bodyKindType, false, true)
    Citizen.InvokeNative(0xCC8CA3E88256E58F, ped, 0, 1, 1, 1, 0)
end

function applyCharacterAppearanceHandleHead(ped, headApparatusId, headApparatusStyleId)
    assert(headApparatusId, "headApparatusId empty")

    clothingSystemPushRequest(ped, 'UpdateCurrentApparatus',
    {
        apparatusType = eMetapedBodyApparatusType.Heads,
        apparatusId = headApparatusId,
        apparatusStyleId = headApparatusStyleId,
    })
end

function applyCharacterAppearanceHandleEyes(ped, eyesApparatusId, eyesApparatusStyleId)
    assert(eyesApparatusId, "eyesApparatusId empty")
    assert(eyesApparatusStyleId, "eyesApparatusStyleId empty")

    clothingSystemPushRequest(ped, 'UpdateCurrentApparatus',
    {
        apparatusType = eMetapedBodyApparatusType.Eyes,
        apparatusId = eyesApparatusId,
        apparatusStyleId = eyesApparatusStyleId,
    })
end


function applyCharacterAppearanceHandleTeeth(ped, teethApparatusStyleId)
    assert(teethApparatusStyleId, "teethApparatusStyleId empty")

    clothingSystemPushRequest(ped, 'UpdateCurrentApparatus',
    {
        apparatusType = eMetapedBodyApparatusType.Teeth,
        apparatusId = 0,
        apparatusStyleId = teethApparatusStyleId,
    })
end

function applyCharacterAppearanceHandleHair(ped, hairApparatusId, hairApparatusStyleId)
    assert(hairApparatusId, "hairApparatusId empty")
    assert(hairApparatusStyleId, "hairApparatusStyleId empty")

    if hairApparatusId <= 0 then
        clothingSystemPushRequest(ped, 'RemoveCurrentApparatusByType', eMetapedBodyApparatusType.Hair)
    else
        clothingSystemPushRequest(ped, 'UpdateCurrentApparatus',
        {
            apparatusType = eMetapedBodyApparatusType.Hair,
            apparatusId = hairApparatusId,
            apparatusStyleId = hairApparatusStyleId,
        })
    end
end

function applyCharacterAppearanceHandleMustache(ped, mustacheApparatusId, mustacheApparatusStyleId)
    assert(mustacheApparatusId, "mustacheApparatusId empty")
    assert(mustacheApparatusStyleId, "mustacheApparatusStyleId empty")

    if mustacheApparatusId <= 0 then
        clothingSystemPushRequest(ped, 'RemoveCurrentApparatusByType', eMetapedBodyApparatusType.BeardsComplete)
    else
        clothingSystemPushRequest(ped, 'UpdateCurrentApparatus',
        {
            apparatusType = eMetapedBodyApparatusType.BeardsComplete,
            apparatusId = mustacheApparatusId,
            apparatusStyleId = mustacheApparatusStyleId,
        })
    end
end

function applyCharacterAppearanceHandleOutfit(ped, equippedOutfitApparels)
    -- assert(equippedOutfitApparels, "equippedOutfitApparels empty")

    if not equippedOutfitApparels then 
        return
    end

    for t, apparelData in pairs(equippedOutfitApparels) do
        local type = tonumber(t)
        local id = apparelData.id
        local styleId = apparelData.styleId

        clothingSystemPushRequest(ped, 'UpdateCurrentApparatus',
        {
            apparatusType = type,
            apparatusId = id,
            apparatusStyleId = styleId,
        })
    end
end


function applyCharacterAppearanceHandleOverlays(ped, headApparatusId, headApparatusStyleId, appearanceOverlays, appearanceOverlaysCustomizable)
    -- Criar a layer principal.
    clothingSystemPushRequest(ped, 'CreateHeadOverlay', { })

    local isPedMale = IsPedMale(ped)
    -- Alterar as texturas da layer principal.
    local headApparatus = 
    {
        type = eMetapedBodyApparatusType.Heads,
        gender = isPedMale and eMetapedBodyApparatusGender.Male or eMetapedBodyApparatusGender.Female,
        id = headApparatusId,
        styleId = headApparatusStyleId,
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

    clothingSystemPushRequest(ped, 'UpdateBaseOverlayLayer', {
        albedo = albedoHash,
        normal = normalHash,
        material = materialHash
    })

    -- Alterar as texturas da layer principal.
    for layerTypeUncast, overlayData in pairs(appearanceOverlays.data) do
        local layerType = tonumber(layerTypeUncast)

        clothingSystemPushRequest(ped, 'UpdateOverlayLayer',
        {
            layerType = layerType,
            styleIndex = overlayData.styleIndex or 0,
            tint0 = overlayData.colorIndex,
            alpha = overlayData.opacity,
        })
    
    end

    local hasFacialHair = appearanceOverlaysCustomizable.hasFacialHair
    local headHairStyle = appearanceOverlaysCustomizable.headHairStyle
    local headHairOpacity = appearanceOverlaysCustomizable.headHairOpacity
    local foundationColor = appearanceOverlaysCustomizable.foundationColor
    local foundationOpacity = appearanceOverlaysCustomizable.foundationOpacity
    local lipstickColor = appearanceOverlaysCustomizable.lipstickColor
    local lipstickOpacity = appearanceOverlaysCustomizable.lipstickOpacity
    local facePaintColor = appearanceOverlaysCustomizable.facePaintColor
    local facePaintOpacity = appearanceOverlaysCustomizable.facePaintOpacity
    local eyeshadowColor = appearanceOverlaysCustomizable.eyeshadowColor
    local eyeshadowOpacity = appearanceOverlaysCustomizable.eyeshadowOpacity
    local eyelinerColor = appearanceOverlaysCustomizable.eyelinerColor
    local eyelinerOpacity = appearanceOverlaysCustomizable.eyelinerOpacity
    local eyebrowsStyle = appearanceOverlaysCustomizable.eyebrowsStyle
    local eyebrowsColor = appearanceOverlaysCustomizable.eyebrowsColor
    local eyebrowsOpacity = appearanceOverlaysCustomizable.eyebrowsOpacity
    local blusherStyle = appearanceOverlaysCustomizable.blusherStyle
    local blusherColor = appearanceOverlaysCustomizable.blusherColor
    local blusherOpacity = appearanceOverlaysCustomizable.blusherOpacity

    if hasFacialHair then
        clothingSystemPushRequest(ped, 'UpdateOverlayLayer', { layerType = eOverlayLayer.MPC_OVERLAY_LAYER_FACIAL_HAIR, styleIndex = 0, alpha = 1.0 })
    end

    if headHairStyle or headHairOpacity then
        clothingSystemPushRequest(ped, 'UpdateOverlayLayer', { layerType = eOverlayLayer.MPC_OVERLAY_LAYER_HEAD_HAIR, styleIndex = headHairStyle or 0, alpha = headHairOpacity })
    end

    if foundationColor or foundationOpacity then
        clothingSystemPushRequest(ped, 'UpdateOverlayLayer', { layerType = eOverlayLayer.MPC_OVERLAY_LAYER_FOUNDATION, styleIndex = 0, tint0 = foundationColor, alpha = foundationOpacity })
    end

    if lipstickColor or lipstickOpacity then
        clothingSystemPushRequest(ped, 'UpdateOverlayLayer', { layerType = eOverlayLayer.MPC_OVERLAY_LAYER_LIPSTICK, styleIndex = 0, tint0 = lipstickColor, alpha = lipstickOpacity })
    end

    if facePaintColor or facePaintOpacity then
        clothingSystemPushRequest(ped, 'UpdateOverlayLayer', { layerType = eOverlayLayer.MPC_OVERLAY_LAYER_FACE_PAINT, styleIndex = 0, tint0 = facePaintColor, alpha = facePaintOpacity })
    end

    if eyeshadowColor or eyeshadowOpacity then
        clothingSystemPushRequest(ped, 'UpdateOverlayLayer', { layerType = eOverlayLayer.MPC_OVERLAY_LAYER_EYESHADOW, styleIndex = 0, tint0 = eyeshadowColor, alpha = eyeshadowOpacity })
    end

    if eyelinerColor or eyelinerOpacity then
        clothingSystemPushRequest(ped, 'UpdateOverlayLayer', { layerType = eOverlayLayer.MPC_OVERLAY_LAYER_EYELINER, styleIndex = 0, tint0 = eyelinerColor, alpha = eyelinerOpacity })
    end

    if eyebrowsStyle or eyebrowsColor or eyebrowsOpacity then
        clothingSystemPushRequest(ped, 'UpdateOverlayLayer', { layerType = eOverlayLayer.MPC_OVERLAY_LAYER_EYEBROWS, styleIndex = eyebrowsStyle or 0, tint0 = eyebrowsColor, alpha = eyebrowsOpacity })
    end

    if blusherStyle or blusherColor or blusherOpacity then
        clothingSystemPushRequest(ped, 'UpdateOverlayLayer', { layerType = eOverlayLayer.MPC_OVERLAY_LAYER_BLUSHER, styleIndex = blusherStyle or 0, tint0 = blusherColor, alpha = blusherOpacity })
    end
end