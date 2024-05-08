

// async function clothingSystemPushRequest(ped, type, data) {

//     if (type == "UpdateCurrentApparatus") {
//         HANDLER_UPDATE_CURRENT_APPARATUS(ped, data);
//     }

//     if (type == "UpdateTempApparatus") {
//         // HANDLER_UPDATE_TEMP_APPARATUS(ped, data);
//     }

//     if (type == "UpdateCurrentBody") {
//         HANDLER_UPDATE_CURRENT_APPARATUS(ped, data)
//     }

//     if (type == "RemoveCurrentApparatusByType") {
//         HANDLER_REMOVE_CURRENT_APPARATUS_BY_TYPE(ped, data)
//     }

//     if (type == "UpdateCurrentExpression") {
//         HANDLER_UPDATE_CURRENT_EXPRESION(ped, data)
//     }

//     if (type == "UpdateCurrentHeadBlend") {
//         HANDLER_UPDATE_CURRENT_HEAD_BLEND(ped, data)
//     }

//     if (type == "CreateHeadOverlay") {
//         HANDLER_CREATE_HEAD_OVERLAY(ped, data)
//     }

//     if (type == "UpdateCurrentBodyWeightOutfit") {
//         HANDLER_UPDATE_CURRENT_BODY_WEIGHT_OUTFIT(ped, data)
//     }

//     if ( type == "UpdateOverlayLayer" ) {
//         HANDLER_UPDATE_OVERLAY_LAYER(ped, data)
//     }

//     if ( type == "UpdateBaseOverlayLayer" ) {
//         HANDLER_UPDATE_BASE_OVERLAY_LAYER(ped, data)
//     }
//     // console.log(" clothingSystemPushRequest :: ", ped, type, data);
// }


const requestQueue = [];
const requestHandlerMap = new Map([
    ['UpdateBaseOverlayLayer', HANDLER_UPDATE_BASE_OVERLAY_LAYER],
    ['UpdateOverlayLayer', HANDLER_UPDATE_OVERLAY_LAYER],
    ['UpdateCurrentBodyWeightOutfit', HANDLER_UPDATE_CURRENT_BODY_WEIGHT_OUTFIT],
    ['CreateHeadOverlay', HANDLER_CREATE_HEAD_OVERLAY],
    ['UpdateCurrentHeadBlend', HANDLER_UPDATE_CURRENT_HEAD_BLEND],
    ['UpdateCurrentExpression', HANDLER_UPDATE_CURRENT_EXPRESION],
    ['RemoveCurrentApparatusByType', HANDLER_REMOVE_CURRENT_APPARATUS_BY_TYPE],
    ['UpdateCurrentBody', HANDLER_UPDATE_CURRENT_APPARATUS],
    // ['UpdateTempApparatus', HANDLER_UPDATE_TEMP_APPARATUS],
    ['UpdateCurrentApparatus', HANDLER_UPDATE_CURRENT_APPARATUS],
]);


let metapedClothingSystemOverlayHandler = new MetapedClothingSystemOverlayHandler(this);

async function clothingSystemPushRequest(ped, reqType, reqData) {
    try
    {
        await new Promise(async (resolve, reject) =>
        {
            requestQueue.push(
            {
                reqType: reqType,
                reqData: reqData,
                reqPed: ped,

                resolve,
                reject,
            });
    
            manageQueue();
        })
    }
    catch(e)
    {
        console.log('ERROR NO PUSH REQUEST', e);
        // throw new Error(`Ocorreu um error no request(${reqType}) data(${JSON.stringify(reqData)}), error: ${e}`);
    }
}
exports('clothingSystemPushRequest', clothingSystemPushRequest)

var isRequestQueueOccupied = false

async function manageQueue()
{
    if (isRequestQueueOccupied)
    {
        return;
    }

    let numRequestsOnQueue = requestQueue.length;

    if (numRequestsOnQueue <= 0)
    {
        return;
    }

    isRequestQueueOccupied = true;

    const entry = requestQueue[0];

    const reqType = entry.reqType;

    const handler = requestHandlerMap.get(reqType);

    if (!handler)
    {
        // throw new Error(`UNHANDLED REQUEST ${reqType}`);
        return ""
    }

    const resolverPromise = new Promise(async (resolve, reject) =>
    {
        try
        {
            const success = await handler(entry.reqPed, entry.reqData);
            
            resolve(success);
        }
        catch(e)
        {
            reject(e);
        }
    });

    const timeoutPromise = new Promise(async (resolve, reject) =>
    {
        setTimeout(() => reject(new Error(`Demorou demais para completar o request`)), 10000);
    });
    
    try
    {
        try
        {
            await setManagedPromiseTick(resolve =>
            {
                if (!!N_0xa0bc8faed8cfeb3c(entry.reqPed))
                {
                    resolve();
                }
            }, 3000);
            
        }
        catch(e)
        {
            throw new Error(`Demorou demais para renderizar o ped. ${e}`);
        }

        const success = await Promise.race([ resolverPromise, timeoutPromise ]);

        entry.resolve(success);
    }
    catch(e)
    {
        entry.reject(e);
    }
    finally
    {

        let index = requestQueue.findIndex(v => v == entry);

        if (index !== -1)
        {
            requestQueue.splice(index, 1);
        }

        isRequestQueueOccupied = false;

        manageQueue();
    }
}

async function HANDLER_UPDATE_CURRENT_APPARATUS(ped, data)
{
    console.log(" HANDLER_UPDATE_CURRENT_APPARATUS ")
    // Caso o ped esteja usando um componente temporário
    // a gente deve remover o componente temporario completamente a aplica esse novo
    // ou só alterar o componente que está em cache?
    const pedId = ped;
    const isMale = IsPedMale(ped);

    const apparatusType = data.apparatusType;
    const apparatusId      = data.apparatusId;
    const apparatusStyleId = data.apparatusStyleId ?? 0;


    const apparatus =
    {
        id: apparatusId,
        styleId: apparatusStyleId,
        type: apparatusType,
        gender: isMale ? eMetapedBodyApparatusGender.Male : eMetapedBodyApparatusGender.Female,
    }

    // const isUsingTempOfThisApparatusType = this.metapedClothingSystem.hasCachedMetapedBodyApparatus(ped, apparatusType);
    
    // O ped está com um componente igual e não está usando um componente temporário
    // então a gente não vai satisfazer o request.
    if (isMetapedUsingApparatusRDR3(ped, apparatus))
    {
        // O ped está usando um apparatus igual e a gente tá usando
        // o caminho temporário, então a gente ignora e retorna true.
        if (data.useTempPath)
        {
            return true;
        }
        else
        {
            // O ped está usango um apparatus igual e a gente
            // está usando o caminho permanente, só vamos
            // ignorar se o apparatus atual não for temporario
            // porque isso quer dizer que a gente não precisa liberar o cache.
            // if (!isUsingTempOfThisApparatusType)
            // {
            //     return true;
            // }
            // else
            // {
            //     this.metapedClothingSystem.flushCachedMetapedBodyApparatus(ped, apparatusType);
            // }
        }
    }

    // A gente está usando o caminho temporario
    // então a gente vai salvar o apparatus atual em cache :)
    if (data.useTempPath)
    {
        let apparatus;

        // Aqui a gente precisa achar qual é o componente atual do ped
        // a partir da categoria do componente :)
        const findShopItemByApparatusType = () =>
        {
            // Converte o nome da categoria para hash a partir de eMetapedBodyApparatusType
            //
            // ex: JewelryRingsRight -> JEWLRY_RINGS_RIGHT
            const rdr3ShopItemCategory = camelToSnakeCase(eMetapedBodyApparatusTypeToStr[apparatusType]);      
            
            console.log(" rdr3ShopItemCategory :: ", rdr3ShopItemCategory, apparatusType)

            const rdr3ShopItemCategoryHash = GetHashKey(rdr3ShopItemCategory);

            // Numero de componentes que o ped está usando atualmente.
            const numMetaAssets = N_0x90403e8107b60e81(pedId); 

            // O ped não tem nenhum componente equipado, abortar...
            if (numMetaAssets <= 0)
            {
                return undefined;
            }

            // GetMetaPedType
            const metapedType = N_0xec9a1261bf0ce510(pedId);
    
            const buffer = new ArrayBuffer(8 * 5);
            const view = new DataView(buffer);
    
            // Iterar por todos os componentes que ped tem equipado
            for (let i = 0; i < numMetaAssets; i++)
            {
                // GetPedComponentAtIndex
                const itShopitemHash = N_0x77ba37622e22023b(pedId, i, true, view, view);

                const itShopitemCategoryHash = N_0x5ff9a878c3d115b8(itShopitemHash, metapedType, true); // GetPedComponentCategory GetPedComponentCategory(

                // Comparar a hash da categoria do component equipado com a hash que a gente tá procurando
                if (itShopitemCategoryHash == rdr3ShopItemCategoryHash)
                {
                    return itShopitemHash;
                }
            }

            return undefined;
        }

        const shopitemHash = findShopItemByApparatusType();

        if (shopitemHash)
        {
            // Popular a estrutura do apparatus a partir do tipo e da hash do componente.
            apparatus = getMetapedBodyApparatusFromShopitemAny(apparatusType, undefined, undefined, undefined, shopitemHash);
        }

        // if (apparatus)
        // {
        //     this.metapedClothingSystem.cacheMetapedBodyApparatus(ped, apparatus);
        // }
    }

    const shopitem = await getShopitemAnyByMetapedBodyApparatus(apparatus);
    // console.log(" shopItemHash :: ", shopitem, typeof shopitem);

    if (!shopitem)
    {
        return false;
    }
    
    const shopItemHash = typeof shopitem == 'string' ? GetHashKey(shopitem) : shopitem;

    // console.log(" shopItemHash :: ", shopitem, typeof shopitem);

    const isNoneHair = shopItemHash == GetHashKey('CLOTHING_ITEM_HAIR_NONE');
    const isNoneBeard = shopItemHash == GetHashKey('CLOTHING_ITEM_BEARD_NONE');

    if (isNoneHair || isNoneBeard)
    {
        await HANDLER_REMOVE_CURRENT_APPARATUS_BY_TYPE(ped, isNoneHair ? eMetapedBodyApparatusType.Hair : eMetapedBodyApparatusType.BeardsComplete);
        
        return true;
    }

    // ApplyShopItemToPed
    N_0xd3a7b003ed343fd9(pedId, shopItemHash, false, true, false);

    // ?
    N_0xaab86462966168ce(pedId, true);

    // UpdatePedVariation
    N_0xcc8ca3e88256e58f(pedId, false, true, true, true, true);

    // Aguardar o componente realmente ser aplicado no ped
    // e assim então passar para o proximo request da fila.
    
    /*
    const interval = setInterval(() =>
    {
        if (this.metapedClothingSystem.isMetapedUsingApparatus(ped, apparatus))
        {
            clearInterval(interval);

            return resolve(true);
        }
    }, 0);
    */

    return true;
}


async function HANDLER_UPDATE_OVERLAY_LAYER(ped, data)
{
    const {
        layerType,

        styleIndex,

        palleteIndex = 0, // Sempre a primeira paleta é usada.
        tint0,

        alpha,
    } = data;

    console.log(`HANDLER_UPDATE_OVERLAY_LAYER(${eOverlayToStr[layerType]})`);

    const mpOverlayLayersDataFile = global.exports.frp_core.mp_overlay_layers()

    const overlayLayerDataFileEntry = mpOverlayLayersDataFile.find(entry => entry.type == eOverlayToStr[layerType]);

    if (!overlayLayerDataFileEntry)
    {
        throw new Error(`HANDLER_UPDATE_OVERLAY_LAYER(${eOverlayToStr[layerType]}) Overlay nao existe no data file`);;
    }

    const overlayLayerStyles = overlayLayerDataFileEntry.styles;

    const overlayLayerStyle = overlayLayerStyles[styleIndex];
    
    if (styleIndex && !overlayLayerStyle)
    {
        throw new Error(`HANDLER_UPDATE_OVERLAY_LAYER(${eOverlayToStr[layerType]}) Style(${styleIndex}) não existe, máximo(${overlayLayerStyles.length})`);
    }

    const {
        albedo,
        normal,
        material,
    } = overlayLayerStyle || { };

    const pallete = palleteIndex === undefined
        ? undefined
        : colorPalettes[palleteIndex]?.hash;

    if (palleteIndex && !pallete)
    {
        throw new Error(`HANDLER_UPDATE_OVERLAY_LAYER(${eOverlayToStr[layerType]}) :: Paleta pelo index(${palleteIndex}) não é valida`);
    }

    const blendType = (() =>
    {
        switch(layerType)
        {
            case eOverlayLayer.MPC_OVERLAY_LAYER_FACIAL_HAIR:
            case eOverlayLayer.MPC_OVERLAY_LAYER_FOUNDATION:
            case eOverlayLayer.MPC_OVERLAY_LAYER_HEAD_HAIR:
            case eOverlayLayer.MPC_OVERLAY_LAYER_EYESHADOW:
            case eOverlayLayer.MPC_OVERLAY_LAYER_LIPSTICK:
            case eOverlayLayer.MPC_OVERLAY_LAYER_FACE_PAINT:
            case eOverlayLayer.MPC_OVERLAY_LAYER_EYELINER:
            case eOverlayLayer.MPC_OVERLAY_LAYER_INVALID:
            case eOverlayLayer.MPC_OVERLAY_LAYER_BLUSHER:
            case eOverlayLayer.MPC_OVERLAY_LAYER_EYEBROWS:
            case eOverlayLayer.MPC_OVERLAY_LAYER_GRIME:
                return 0;
            case eOverlayLayer.MPC_OVERLAY_LAYER_COMPLEXION:
            case eOverlayLayer.MPC_OVERLAY_LAYER_COMPLEXION_2:
            case eOverlayLayer.MPC_OVERLAY_LAYER_ROOT:
            case eOverlayLayer.MPC_OVERLAY_LAYER_FRECKLES: 
            case eOverlayLayer.MPC_OVERLAY_LAYER_SKIN_MOTTLING:
            case eOverlayLayer.MPC_OVERLAY_LAYER_AGEING: 
            case eOverlayLayer.MPC_OVERLAY_LAYER_SPOTS:
            case eOverlayLayer.MPC_OVERLAY_LAYER_MOLES:
            case eOverlayLayer.MPC_OVERLAY_LAYER_SCAR: 
                return 1;
            default:
                return 0;
        }
    })();

    console.log(`HANDLER_UPDATE_OVERLAY_LAYER(${eOverlayToStr[layerType]}) :: blendType(${blendType})`);
    console.log(`HANDLER_UPDATE_OVERLAY_LAYER(${eOverlayToStr[layerType]}) :: pallete(${blendType === 0 ? pallete : undefined})`);
    console.log(`HANDLER_UPDATE_OVERLAY_LAYER(${eOverlayToStr[layerType]}) :: albedo: `, albedo, albedo == undefined ? undefined : Number(albedo));
    console.log(`HANDLER_UPDATE_OVERLAY_LAYER(${eOverlayToStr[layerType]}) :: normal: `, normal, normal == undefined ? undefined : Number(normal));
    console.log(`HANDLER_UPDATE_OVERLAY_LAYER(${eOverlayToStr[layerType]}) :: material:`, material, material == undefined ? undefined : Number(material));

    try
    {
        metapedClothingSystemOverlayHandler.updateOrCreateLayer(
            {
                type: layerType,
                
                albedo: albedo == undefined ? undefined : Number(albedo),
                normal: normal == undefined ? undefined : Number(normal),
                material: material == undefined ? undefined : Number(material),

                blendType: blendType,
                pallete: blendType === 0 ? pallete : undefined, // Palleta só é usada para o blendtype 0
                tint0: blendType === 0 ? tint0 : undefined, // Só é usado para o blendtype 0

                texAlpha: alpha,
            }
        );
    }
    catch(e)
    {
        throw console.log(`HANDLER_UPDATE_OVERLAY_LAYER :: err on create layer :: (${e.message})`);
    }
    
    await metapedClothingSystemOverlayHandler.applyTextureBlend(ped);

    return true;
};



async function HANDLER_UPDATE_BASE_OVERLAY_LAYER(ped, data)
{
    const {
        albedo,
        normal,
        material,
    } = data;

    try
    {
        metapedClothingSystemOverlayHandler.updateOrCreateLayer(
        {
            type: eOverlayLayer.MPC_OVERLAY_LAYER_ROOT,
            
            albedo: albedo,
            normal: normal,
            material: material,
        });
    }
    catch(e)
    {
        throw new ApplicationException(`HANDLER_UPDATE_BASE_OVERLAY_LAYER :: err on create layer :: (${e.message})`);
    }
    
    await metapedClothingSystemOverlayHandler.applyTextureBlend(ped);

    return true;
}


async function HANDLER_UPDATE_CURRENT_HEAD_BLEND (ped, data)
{
    SetPedHeadBlendData(ped, data.shapeFirst, data.shapeSecond, 0, data.skinFirst, data.skinSecond, 0, data.shapeMix, data.skinMix, 0, false);
    
    // FinalizeHeadBlend
    N_0x4668d80430d6c299(ped);
    
    await setManagedPromiseTick((resolve) =>
    {
        if (HasPedHeadBlendFinished(ped)) resolve();
    }, 2000);

    return true;
}

async function HANDLER_CREATE_HEAD_OVERLAY(ped, data)
{
    return await metapedClothingSystemOverlayHandler.createTextureBlend();
}

async function HANDLER_UPDATE_CURRENT_EXPRESION (pedId, data)
{
    console.log(" data :: ", JSON.stringify( data ))

    let { expressionType, expressionValue } = data;
    console.log(" expressionTypeHash :: 1 ", expressionValue)

    expressionValue = expressionValue + 0.0001;
    console.log(" expressionTypeHash :: 2 ", expressionValue)

    expressionValue = Math.min(1.0, expressionValue);
    console.log(" expressionTypeHash :: 3 ", expressionValue)

    expressionValue = Math.max(-1.0, expressionValue);
    const expressionTypeHash = MetapedExpressionToHash[expressionType];

    console.log(" expressionTypeHash :: 4 ", expressionTypeHash, expressionValue)

    // SetPedFaceFeature
    N_0x5653ab26c82938cf(pedId, expressionTypeHash, expressionValue);

    // UpdatePedVariation
    N_0xcc8ca3e88256e58f(pedId, false, true, true, true, true);

    return true;
};

async function HANDLER_REMOVE_CURRENT_APPARATUS_BY_TYPE(pedId, data)
{
    const apparatusType = data;

    const shopItemCategory = camelToSnakeCase(eMetapedBodyApparatusTypeToStr[apparatusType]);
    const shopItemCategoryHash = GetHashKey(shopItemCategory);

    // RemoveTagFromMetaPed
    N_0xd710a5007c2ac539(pedId, shopItemCategoryHash, 0);
    
    // _UPDATE_PED_VARIATION
    N_0xcc8ca3e88256e58f(pedId, 0, 1, 1, 1, 0);

    return true;
}


async function HANDLER_UPDATE_CURRENT_BODY (ped, data)
{
    const { useTempPath } = data;

    const lowerBodyPromise = HANDLER_UPDATE_CURRENT_APPARATUS(ped, 
    {
        apparatusId: data.id,
        apparatusStyleId: data.styleId,
        apparatusType: eMetapedBodyApparatusType.BodiesLower,
        useTempPath,
    });

    const upperBodyPromise = HANDLER_UPDATE_CURRENT_APPARATUS(ped, 
    {
        apparatusId: data.id,
        apparatusStyleId: data.styleId,
        apparatusType: eMetapedBodyApparatusType.BodiesUpper,
        useTempPath,
    });

    try
    {
        await Promise.all([ lowerBodyPromise, upperBodyPromise ]);
    }
    catch(e)
    {
        console.log("Err :: ", e)
        // throw new CustomException(`Falha ao carregar uma das partes do corpo successLower(${'successLower'}) successUpper(${'successUpper'}), error: ${e}`);
    }

    return true;
}

async function HANDLER_UPDATE_CURRENT_BODY_WEIGHT_OUTFIT (pedId, data)
{
    const WAIST_TYPES =
    [
        -2045421226,    // smallest
        -1745814259,
        -325933489,
        -1065791927,
        -844699484,
        -1273449080,
        927185840,
        149872391,
        399015098,
        -644349862,
        1745919061,      // default
        1004225511,
        1278600348,
        502499352,
        -2093198664,
        -1837436619,
        1736416063,
        2040610690,
        -1173634986,
        -867801909,
        1960266524,      // biggest    
    ];

    const { type } = data;

    const outfitHash = WAIST_TYPES[type];

    if (!outfitHash)
        return
        // throw new Error(`Nenhum BodyWeightOutfit do tipo(${type})`);
    
    // EquipMetaPedOutfit
    N_0x1902c4cfcc5be57c(pedId, outfitHash);

    // _UPDATE_PED_VARIATION
    N_0xcc8ca3e88256e58f(pedId, false, true, true, true, true);

    return true;
}