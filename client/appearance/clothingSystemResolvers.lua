local requestQueue = {}
local requestHandlerMap

CreateThread(function()
    requestHandlerMap = {
        ["UpdateBaseOverlayLayer"] = HANDLER_UPDATE_BASE_OVERLAY_LAYER,
        ["UpdateOverlayLayer"] = HANDLER_UPDATE_OVERLAY_LAYER,
        ["UpdateCurrentBodyWeightOutfit"] = HANDLER_UPDATE_CURRENT_BODY_WEIGHT_OUTFIT,
        ["CreateHeadOverlay"] = HANDLER_CREATE_HEAD_OVERLAY,
        ["UpdateCurrentHeadBlend"] = HANDLER_UPDATE_CURRENT_HEAD_BLEND,
        ["UpdateCurrentExpression"] = HANDLER_UPDATE_CURRENT_EXPRESION,
        ["RemoveCurrentApparatusByType"] = HANDLER_REMOVE_CURRENT_APPARATUS_BY_TYPE,
        ["UpdateCurrentBody"] = HANDLER_UPDATE_CURRENT_BODY,
        ["UpdateCurrentApparatus"] = HANDLER_UPDATE_CURRENT_APPARATUS
    }
end)


function clothingSystemPushRequest(ped, reqType, reqData)
	local d = promise.new()

    table.insert(requestQueue, {
        reqType = reqType,
        reqData = reqData,
        reqPed = ped,
        resolve = d.resolve,
        reject = d.reject,
    })

    manageQueue()
end
exports('clothingSystemPushRequest', clothingSystemPushRequest)


local isRequestQueueOccupied = false

function manageQueue()
    -- print(" manageQueue :: isRequestQueueOccupied ", isRequestQueueOccupied)
    if isRequestQueueOccupied then
        return
    end

    local numRequestsOnQueue = #requestQueue

    if numRequestsOnQueue <= 0 then
        return
    end

    isRequestQueueOccupied = true

    local entry = requestQueue[1]

    local reqType = entry.reqType

    local handler = requestHandlerMap[reqType]

    if not handler then
        -- throw new Error(`UNHANDLED REQUEST ${reqType}`);
        return ""
    end

    -- deferred.first({
    --     handler(entry.reqPed, entry.reqData)
    -- }):next(function(result)
        
    -- end, function(err)
        
    -- end)

	local d = promise.new()
    local success = handler(entry.reqPed, entry.reqData)

    local function timeout(milisec)
        Citizen.SetTimeout( milisec , function()
            isRequestQueueOccupied = false

            if not success then
                d:reject(error('Demorou demais para completar o request'))
            else
                d:resolve(success)
            end
        end)
    end

    d:resolve(success)
    timeout(10000)

    -- local timeoutPromise = newPromise(function(resolve, reject)
    --     setTimeout(function()
    --         reject(new Error("Demorou demais para completar o request"))
    --     end, 10000)
    -- end)

    -- exports.frp_core:setManagedPromiseTick(function(rr)
    --     print(" setManagedPromiseTick 1 ")
    --     if not not N_0xa0bc8faed8cfeb3c(entry.reqPed) then
    --         print(" setManagedPromiseTick 2 ")
    --         rr()
    --     end
    --     print(" setManagedPromiseTick 3 ")
    -- end, 3000)

    local timeOut = 0

    while true do
        Wait(1)

        timeOut += 1

        if Citizen.InvokeNative(0xA0BC8FAED8CFEB3C, entry.reqPed) then
            -- print(" ^1 PRONTO PARA APLICAR ")
            break
        end

        if timeOut >= 4000 then
            -- print(" ^1 DEU MERDA ")
            break
        end
    end

    entry:resolve( Citizen.Await(d) )

    local index = indexOf(requestQueue, entry)

    if index ~= -1 then
        table.remove(requestQueue, index)
    end

    -- print(" isRequestQueueOccupied:: ", isRequestQueueOccupied)
    isRequestQueueOccupied = false

    manageQueue()
end

function HANDLER_UPDATE_OVERLAY_LAYER(ped, data)
    -- print(" HANDLER_UPDATE_OVERLAY_LAYER :: ", json.encode(data))
    local layerType = data.layerType
    local styleIndex = data.styleIndex
    local palleteIndex = data.palleteIndex or 1
    local tint0 = data.tint0
    local alpha = data.alpha

    -- print("HANDLER_UPDATE_OVERLAY_LAYER(" .. eOverlayToStr[layerType] .. ")")

    local mpOverlayLayersDataFile = gMpOverlayLayers

    local overlayLayerDataFileEntry = nil
    for _, entry in pairs(mpOverlayLayersDataFile) do
        if entry.type == eOverlayToStr[layerType] then
            overlayLayerDataFileEntry = entry
            break
        end
    end

    -- print(" layerType :: ", type(layerType), layerType)

    if not overlayLayerDataFileEntry then
        error("HANDLER_UPDATE_OVERLAY_LAYER(" .. eOverlayToStr[layerType] .. ") Overlay does not exist in the data file")
    end

    local overlayLayerStyles = overlayLayerDataFileEntry.styles
    local overlayLayerStyle = overlayLayerStyles[styleIndex]

    if styleIndex and not overlayLayerStyle then
        error("HANDLER_UPDATE_OVERLAY_LAYER(" .. eOverlayToStr[layerType] .. ") Style(" .. styleIndex .. ") does not exist, max(" .. #overlayLayerStyles .. ")")
    end

    local albedo, normal, material
    if overlayLayerStyle then
        albedo = overlayLayerStyle.albedo
        normal = overlayLayerStyle.normal
        material = overlayLayerStyle.material
    end

    local pallete = nil
    if palleteIndex ~= nil then
        pallete = colorPalettes[palleteIndex].hash
    end

    if palleteIndex and not pallete then
        error("HANDLER_UPDATE_OVERLAY_LAYER(" .. eOverlayToStr[layerType] .. ") :: Palette by index(" .. palleteIndex .. ") is not valid")
    end

    local blendType
    if layerType == eOverlayLayer.MPC_OVERLAY_LAYER_FACIAL_HAIR
        or layerType == eOverlayLayer.MPC_OVERLAY_LAYER_FOUNDATION
        or layerType == eOverlayLayer.MPC_OVERLAY_LAYER_HEAD_HAIR
        or layerType == eOverlayLayer.MPC_OVERLAY_LAYER_EYESHADOW
        or layerType == eOverlayLayer.MPC_OVERLAY_LAYER_LIPSTICK
        or layerType == eOverlayLayer.MPC_OVERLAY_LAYER_FACE_PAINT
        or layerType == eOverlayLayer.MPC_OVERLAY_LAYER_EYELINER
        or layerType == eOverlayLayer.MPC_OVERLAY_LAYER_INVALID
        or layerType == eOverlayLayer.MPC_OVERLAY_LAYER_BLUSHER
        or layerType == eOverlayLayer.MPC_OVERLAY_LAYER_EYEBROWS
        or layerType == eOverlayLayer.MPC_OVERLAY_LAYER_GRIME then
        blendType = 0
    elseif layerType == eOverlayLayer.MPC_OVERLAY_LAYER_COMPLEXION
        or layerType == eOverlayLayer.MPC_OVERLAY_LAYER_COMPLEXION_2
        or layerType == eOverlayLayer.MPC_OVERLAY_LAYER_ROOT
        or layerType == eOverlayLayer.MPC_OVERLAY_LAYER_FRECKLES
        or layerType == eOverlayLayer.MPC_OVERLAY_LAYER_SKIN_MOTTLING
        or layerType == eOverlayLayer.MPC_OVERLAY_LAYER_AGEING
        or layerType == eOverlayLayer.MPC_OVERLAY_LAYER_SPOTS
        or layerType == eOverlayLayer.MPC_OVERLAY_LAYER_MOLES
        or layerType == eOverlayLayer.MPC_OVERLAY_LAYER_SCAR then
        blendType = 1
    else
        blendType = 0
    end

    -- print("HANDLER_UPDATE_OVERLAY_LAYER(" .. eOverlayToStr[layerType] .. ") :: blendType(" .. blendType .. ")")
    -- print("HANDLER_UPDATE_OVERLAY_LAYER(" .. eOverlayToStr[layerType] .. ") :: pallete(" .. (blendType == 0 and pallete or "nil") .. ")")
    -- print("HANDLER_UPDATE_OVERLAY_LAYER(" .. eOverlayToStr[layerType] .. ") :: albedo: ", albedo, albedo ~= nil and tonumber(albedo))
    -- print("HANDLER_UPDATE_OVERLAY_LAYER(" .. eOverlayToStr[layerType] .. ") :: normal: ", normal, normal ~= nil and tonumber(normal))
    -- print("HANDLER_UPDATE_OVERLAY_LAYER(" .. eOverlayToStr[layerType] .. ") :: material:", material, material ~= nil and tonumber(material))

    gMetapedClothingSystemOverlayHandler.updateOrCreateLayer(
        {
            type = layerType,
            
            albedo = albedo,
            normal =  normal,
            material = material,

            blendType = blendType,
            pallete = blendType == 0 and pallete or nil, -- Palette is only used for blendType 0
            tint0 = blendType == 0 and tint0 or nil, -- Only used for blendType 0

            texAlpha = alpha,
        }
    )

    gMetapedClothingSystemOverlayHandler.applyTextureBlend(ped)

    return true
end

function HANDLER_UPDATE_BASE_OVERLAY_LAYER(ped, data)
    local albedo = data.albedo
    local normal = data.normal
    local material = data.material

    gMetapedClothingSystemOverlayHandler.updateOrCreateLayer(
    {
        type = eOverlayLayer.MPC_OVERLAY_LAYER_ROOT,
        
        albedo = albedo,
        normal = normal,
        material = material,
    })

    gMetapedClothingSystemOverlayHandler.applyTextureBlend(ped)

    return true
end


function HANDLER_UPDATE_CURRENT_HEAD_BLEND (ped, data)
    SetPedHeadBlendData(ped, data.shapeFirst, data.shapeSecond, 0, data.skinFirst, data.skinSecond, 0, data.shapeMix, data.skinMix, 0, false)
    
    -- FinalizeHeadBlend
    N_0x4668d80430d6c299(ped)

    while not HasPedHeadBlendFinished(ped) do
        Wait(100)
    end

    return true
end

function HANDLER_CREATE_HEAD_OVERLAY(ped, data)
    return gMetapedClothingSystemOverlayHandler.createTextureBlend();
end

function HANDLER_UPDATE_CURRENT_EXPRESION (pedId, data)

    local  expressionType, expressionValue  = data.expressionType, data.expressionValue;

    expressionValue = expressionValue + 0.0001;

    expressionValue = Math.min(1.0, expressionValue);

    expressionValue = Math.max(-1.0, expressionValue);
    local expressionTypeHash = MetapedExpressionToHash[expressionType];

    -- print(" expressionTypeHash :: 4 ", expressionTypeHash, expressionValue)

    -- SetPedFaceFeature
    N_0x5653ab26c82938cf(pedId, expressionTypeHash, expressionValue);

    -- UpdatePedVariation
    N_0xcc8ca3e88256e58f(pedId, false, true, true, true, true);

    return true;
end

function HANDLER_REMOVE_CURRENT_APPARATUS_BY_TYPE(pedId, data)
    local apparatusType = data;
    
    local shopItemCategory = exports.frp_core:camelToSnakeCase(eMetapedBodyApparatusTypeToStr[apparatusType]);
    local shopItemCategoryHash = GetHashKey(shopItemCategory);

    -- RemoveTagFromMetaPed
    N_0xd710a5007c2ac539(pedId, shopItemCategoryHash, 0);
    
    -- _UPDATE_PED_VARIATION
    N_0xcc8ca3e88256e58f(pedId, 0, 1, 1, 1, 0);

    return true;
end

function HANDLER_UPDATE_CURRENT_BODY (ped, data)
    local  useTempPath = data.useTempPath;

    HANDLER_UPDATE_CURRENT_APPARATUS(ped, 
    {
        apparatusId = data.id,
        apparatusStyleId = data.styleId,
        apparatusType = eMetapedBodyApparatusType.BodiesLower,
        useTempPath = useTempPath,
    });

    HANDLER_UPDATE_CURRENT_APPARATUS(ped, 
    {
        apparatusId = data.id,
        apparatusStyleId = data.styleId,
        apparatusType = eMetapedBodyApparatusType.BodiesUpper,
        useTempPath = useTempPath,
    });

    return true;
end

function HANDLER_UPDATE_CURRENT_BODY_WEIGHT_OUTFIT (pedId, data)
    local WAIST_TYPES =
    {
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

    local type = data.type
    local outfitHash = WAIST_TYPES[type]

    if not outfitHash then
        return
        -- throw new Error(`Nenhum BodyWeightOutfit do tipo(${type})`)
    end
    
    -- EquipMetaPedOutfit
    N_0x1902c4cfcc5be57c(pedId, outfitHash)

    -- _UPDATE_PED_VARIATION
    N_0xcc8ca3e88256e58f(pedId, false, true, true, true, true)

    return true
end


function HANDLER_UPDATE_CURRENT_APPARATUS(ped, data)
    -- print(" HANDLER_UPDATE_CURRENT_APPARATUS ")
    -- Caso o ped esteja usando um componente temporário
    -- a gente deve remover o componente temporario completamente a aplica esse novo
    -- ou só alterar o componente que está em cache?
    local pedId = ped;
    local isMale = IsPedMale(ped);

    local apparatusType = data.apparatusType;
    local apparatusId      = data.apparatusId or 0;
    local apparatusStyleId = data.apparatusStyleId or 1;


    local apparatus =
    {
        id = apparatusId,
        styleId = apparatusStyleId,
        type = apparatusType,
        gender = isMale and eMetapedBodyApparatusGender.Male or eMetapedBodyApparatusGender.Female,
    }

    -- print(" apparatus :: ", json.encode(apparatus))

    -- const isUsingTempOfThisApparatusType = this.metapedClothingSystem.hasCachedMetapedBodyApparatus(ped, apparatusType);
    -- O ped está com um componente igual e não está usando um componente temporário
    -- então a gente não vai satisfazer o request.
    -- print(" isMetapedUsingApparatusRDR3 ", isMetapedUsingApparatusRDR3(ped, apparatus))
    if isMetapedUsingApparatusRDR3(ped, apparatus) then
        -- O ped está usando um apparatus igual e a gente tá usando
        -- o caminho temporário, então a gente ignora e retorna true.
        if data.useTempPath then
            return true;
        else
            -- O ped está usango um apparatus igual e a gente
            -- está usando o caminho permanente, só vamos
            -- ignorar se o apparatus atual não for temporario
            -- porque isso quer dizer que a gente não precisa liberar o cache.
            -- if not isUsingTempOfThisApparatusType then
            --     return true;
            -- else
            --     this.metapedClothingSystem.flushCachedMetapedBodyApparatus(ped, apparatusType);
            -- end
        end
    end

    -- A gente está usando o caminho temporario
    -- então a gente vai salvar o apparatus atual em cache :)
    if data.useTempPath then
        local apparatus;

        -- Aqui a gente precisa achar qual é o componente atual do ped
        -- a partir da categoria do componente :)
        local function findShopItemByApparatusType()
            -- Converte o nome da categoria para hash a partir de eMetapedBodyApparatusType
            --
            -- ex: JewelryRingsRight -> JEWLRY_RINGS_RIGHT
            local rdr3ShopItemCategory = exports.frp_core:camelToSnakeCase(eMetapedBodyApparatusTypeToStr[apparatusType]);      
            
            -- print(" rdr3ShopItemCategory :: ", rdr3ShopItemCategory, apparatusType)

            local rdr3ShopItemCategoryHash = GetHashKey(rdr3ShopItemCategory);

            -- Numero de componentes que o ped está usando atualmente.
            local numMetaAssets = N_0x90403e8107b60e81(pedId); 

            -- O ped não tem nenhum componente equipado, abortar...
            if numMetaAssets <= 0 then
                return nil;
            end

            -- GetMetaPedType
            local metapedType = N_0xec9a1261bf0ce510(pedId);
    
            local buffer = DataView.ArrayBuffer(8 * 5);
            local view = buffer:Buffer()
    
            -- Iterar por todos os componentes que ped tem equipado
            for i = 0, numMetaAssets - 1 do
                -- GetPedComponentAtIndex
                local itShopitemHash = N_0x77ba37622e22023b(pedId, i, true, view, view);

                local itShopitemCategoryHash = N_0x5ff9a878c3d115b8(itShopitemHash, metapedType, true); -- GetPedComponentCategory GetPedComponentCategory(

                -- Comparar a hash da categoria do component equipado com a hash que a gente tá procurando
                if itShopitemCategoryHash == rdr3ShopItemCategoryHash then
                    return itShopitemHash;
                end
            end

            return nil;
        end

        local shopitemHash = findShopItemByApparatusType();

        if shopitemHash then
            -- Popular a estrutura do apparatus a partir do tipo e da hash do componente.
            apparatus = getMetapedBodyApparatusFromShopitemAny(apparatusType, nil, nil, nil, shopitemHash);
        end

        -- if apparatus then
        --     this.metapedClothingSystem.cacheMetapedBodyApparatus(ped, apparatus);
        -- end
    end

    local shopitem = getShopitemAnyByMetapedBodyApparatus(apparatus);
    -- print(" shopItemHash :: ", shopitem,  type(shopitem));

    if not shopitem then
        return false;
    end
    
    local shopItemHash = type(shopitem) == 'string' and GetHashKey(shopitem) or shopitem;

    -- print(" shopItemHash :: ", shopitem, type(shopitem));

    local isNoneHair = shopItemHash == GetHashKey('CLOTHING_ITEM_HAIR_NONE');
    local isNoneBeard = shopItemHash == GetHashKey('CLOTHING_ITEM_BEARD_NONE');

    if isNoneHair or isNoneBeard then
        HANDLER_REMOVE_CURRENT_APPARATUS_BY_TYPE(ped, isNoneHair and eMetapedBodyApparatusType.Hair or eMetapedBodyApparatusType.BeardsComplete);
        
        return true;
    end

    -- ApplyShopItemToPed
    N_0xd3a7b003ed343fd9(pedId, shopItemHash, false, true, false);

    -- ?
    N_0xaab86462966168ce(pedId, true);
    -- print(" N_0xaab86462966168ce(pedId, true)  ::", N_0xaab86462966168ce(pedId, true))

    -- UpdatePedVariation
    N_0xcc8ca3e88256e58f(pedId, false, true, true, true, true);

    -- Aguardar o componente realmente ser aplicado no ped
    -- e assim então passar para o proximo request da fila.
    
    --[[local interval = setInterval(() =>
    --{
        --if (this.metapedClothingSystem.isMetapedUsingApparatus(ped, apparatus))
        --{
            --clearInterval(interval);

            --return resolve(true);
        --}
    --}, 0);]]

    return true;
end
