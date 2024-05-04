let equippedMetapedClothing;

async function handleStartEditor(ped)
{   
    const isMale = IsPedMale(ped);

    const numMetaAssets = N_0x90403e8107b60e81(ped); 

    const boolBuffer = new ArrayBuffer(8 * 5);
    const boolView = new DataView(boolBuffer);
    
    const dataBuffer = new ArrayBuffer(8 * 5);
    const dataView = new DataView(dataBuffer);

    // console.log(`numMetaAssets(${numMetaAssets})`);

    const equippedApparelsHash = new Array(numMetaAssets).fill(null).map((_, index) =>
    {
        const hash = N_0x77ba37622e22023b(ped, index, 1, boolView, dataView);

        console.log(`(${index}) hash(${hash})`);
        console.log(`(${index}) boolBuffer`, new Int32Array(boolBuffer));
        console.log(`(${index}) dataBuffer`, new Int32Array(dataBuffer));

        return hash;
    });

    const apparelsGender = isMale ? eMetapedBodyApparatusGender.Male : eMetapedBodyApparatusGender.Female;

    const equippedApparels = await Promise.all(equippedApparelsHash.map(async (hash) =>
    {
        const apparel = await getMetapedBodyApparatusFromShopitemAny(undefined, apparelsGender, undefined, undefined, hash[0]);
        return apparel;
    }))
    console.log(" equippedApparels:: ", JSON.stringify(equippedApparels))

    const newEquippedMetapedClothing =
    {
        bodyApparatusId: undefined,
        bodyApparatusStyleId: undefined,
    
        isMale: undefined,
    
        whistleShape: undefined,
        whistlePitch: undefined,
        whistleClarity: undefined,
    
        expressionsMap: new Map(),
    
        overlayLayersMap: new Map(),
    
        equippedApparelsByType: new Map(equippedApparels.filter(v => !!v).map(e => [ e.type, { id: e.id, styleId: e.styleId } ])),
    
        height: undefined,
    
        bodyWeightOufitType: undefined,
    
        bodyKindType: undefined,
    };

    equippedMetapedClothing = newEquippedMetapedClothing

    // equippedMetapedClothing.equippedApparelsByType.forEach(({ id, styleId }, type) =>
    // {
    //     console.log(`apparel :: type(${eMetapedBodyApparatusTypeToStr[type]}, ${type}[${typeof type}]) id(${id}) styleId(${styleId})`)
    // });

    return equippedMetapedClothing
}

exports('getPedEquippedApparels', (pedId, pedIsMale) => {
    const numMetaAssets = N_0x90403e8107b60e81(pedId); 

    const boolBuffer = new ArrayBuffer(8 * 5);
    const boolView = new DataView(boolBuffer);

    const dataBuffer = new ArrayBuffer(8 * 5);
    const dataView = new DataView(dataBuffer);

    const equippedApparelsHash = new Array(numMetaAssets).fill(null).map((_, index) =>
    {
        const hash = N_0x77ba37622e22023b(pedId, index, 1, boolView, dataView);

        // this.log.debug(`(${index}) hash(${hash})`);
        // this.log.debug(`(${index}) boolBuffer`, new Int32Array(boolBuffer));
        // this.log.debug(`(${index}) dataBuffer`, new Int32Array(dataBuffer));

        return hash;
    });

    
    const apparelsGender = pedIsMale ? 1 : 0;

    const equippedApparels = equippedApparelsHash.map(hash =>
    {
        const apparel = global.exports.frp_core.getMetapedBodyApparatusFromShopitemAny(undefined, apparelsGender, undefined, undefined, hash);

        return apparel;
    });

    return new Map(equippedApparels.filter(v => !!v).map(e => [ e.type, { id: e.id, styleId: e.styleId } ]))
})

exports('handleStartEditor', handleStartEditor);
on('appearance:handleStartEditor', handleStartEditor);

async function requestChangeApparatus(ped, request)
{
    const requestType = request.type;
    const requestSubtype = request.component;

    // console.log(`requestType(${requestType})`);
    // console.log(`requestSubtype(${requestSubtype})`);

    // SHIRTS_FULL -> ShirtsFull || SHIRTS_FULL_COLOR -> ShirtsFull
    const apparatusTypeName = snakeToPascal(requestSubtype.replace('_COLOR', ''));

    // console.log(`apparatusTypeName(${apparatusTypeName})`);

    const apparatusType = eMetapedBodyApparatusType[apparatusTypeName];

    // console.log(`apparatusType(${apparatusType})`);

    const isChangeApparatusStyleRequest = requestSubtype.includes('COLOR');

    // console.log(`isChangeApparatusStyleRequest(${isChangeApparatusStyleRequest})`);

    const apparatusId = isChangeApparatusStyleRequest ? undefined : request.data;
    const apparatusStyleId = isChangeApparatusStyleRequest ? request.data : undefined;

    const {
        equippedApparelsByType,
        bodyApparatusId: equippedBodyApparatusId,
        bodyApparatusStyleId: equippedBodyApparatusStyleId,
    } = equippedMetapedClothing;

    if (apparatusType !== undefined)
    {
        const equippedApparatus = equippedApparelsByType.get(apparatusType);

        let equipApparatusId      = apparatusId      ?? equippedApparatus?.id     ;
        let equipApparatusStyleId = apparatusStyleId ?? equippedApparatus?.styleId;

        // Valores padrões
        equipApparatusId      = equipApparatusId      ?? 0;
        equipApparatusStyleId = equipApparatusStyleId ?? 0;

        // console.log(`equipApparatusId(${equipApparatusId})`);
        // console.log(`equipApparatusStyleId(${equipApparatusStyleId})`);

        // Só atualizar os valores caso 'id' seja maior que zero
        // caso contrário, deletar esse apparatus do store totalmente.
        const hasValidApparatus = equipApparatusId >= 0;

        if (hasValidApparatus)
        {
            await clothingSystemPushRequest(ped, 'UpdateCurrentApparatus',
            {
                apparatusType,
                apparatusId     : equipApparatusId,
                apparatusStyleId: equipApparatusStyleId,
            });

            // Atualizar os valores do apparatus.
            equippedMetapedClothing.equippedApparelsByType.set(apparatusType,
            {
                id     : equipApparatusId,
                styleId: equipApparatusStyleId,
            });

            emit("appearance:update:equippedMetapedClothing", "equippedApparelsByType", "set", apparatusType, {
                id     : equipApparatusId,
                styleId: equipApparatusStyleId,
            })
        }
        else
        {
            await clothingSystemPushRequest(ped, 'RemoveCurrentApparatusByType', apparatusType);

            // Remover a entrada do apparatus totalmente.
            equippedMetapedClothing.equippedApparelsByType.delete(apparatusType);
            emit("appearance:update:equippedMetapedClothing", "equippedApparelsByType", "delete", apparatusType);
        }
    }
    else
    {
        // Extras e estranhos.

        if (requestSubtype == 'BODY_TYPE' || requestSubtype == 'SKIN_COLOR')
        {
            const bodyApparatusId      = apparatusId      ?? equippedBodyApparatusId      ?? 0;
            const bodyApparatusStyleId = apparatusStyleId ?? equippedBodyApparatusStyleId ?? 0;

            // console.log(`bodyApparatusId(${bodyApparatusId})`);
            // console.log(`bodyApparatusStyleId(${bodyApparatusStyleId})`);

            equippedMetapedClothing.bodyApparatusId      = bodyApparatusId;
            equippedMetapedClothing.bodyApparatusStyleId = bodyApparatusStyleId;

            clothingSystemPushRequest(ped, 'UpdateCurrentBody',
            {
                id     : bodyApparatusId,
                styleId: bodyApparatusStyleId,
            })
            .then(async () =>
            {
                const isPedMale = IsPedMale(ped);

                const headApparatus =
                {
                    type: eMetapedBodyApparatusType.Heads,
                    gender: isPedMale ? eMetapedBodyApparatusGender.Male : eMetapedBodyApparatusGender.Female,
                    id: equippedMetapedClothing.equippedApparelsByType.get(eMetapedBodyApparatusType.Heads).id,
                    styleId: bodyApparatusStyleId,
                }

                const shopitemName = await getShopitemAnyByMetapedBodyApparatus(headApparatus);

                const shopitemHash = typeof shopitemName === 'string' ? GetHashKey(shopitemName) : shopitemName;

                const bDrawable = new ArrayBuffer(8);
                const vDrawable = new DataView(bDrawable);
            
                const bAlbedo = new ArrayBuffer(8);
                const vAlbedo = new DataView(bAlbedo);
            
                const bNormal = new ArrayBuffer(8);
                const vNormal = new DataView(bNormal);
            
                const bMaterial = new ArrayBuffer(8);
                const vMaterial = new DataView(bMaterial);
                
                const bUnk0 = new ArrayBuffer(8);
                const vUnk0 = new DataView(bUnk0);
            
                const bUnk1 = new ArrayBuffer(8);
                const vUnk1 = new DataView(bUnk1);
            
                const bUnk2 = new ArrayBuffer(8);
                const vUnk2 = new DataView(bUnk2);
            
                const bUnk3 = new ArrayBuffer(8);
                const vUnk3 = new DataView(bUnk3);
            
                const success = Citizen.invokeNative('0x63342C50EC115CE8', shopitemHash, 0, 0, /* GetMetaPedType */ N_0xec9a1261bf0ce510(ped), 1, vDrawable, vAlbedo, vNormal, vMaterial, vUnk0, vUnk1, vUnk2, vUnk3);                

                if (success != 1)
                {
                    throw new Error(`Não foi possivel encontrar as textures para componente o '${shopitemName}' `);
                }

                const albedoHash = new Int32Array(bAlbedo)[0];
                const normalHash = new Int32Array(bNormal)[0];
                const materialHash = new Int32Array(bMaterial)[0];

                console.log(`albedoHash(${albedoHash})`);
                console.log(`normalHash(${normalHash})`);
                console.log(`materialHash(${materialHash})`);

                clothingSystemPushRequest(ped, 'UpdateBaseOverlayLayer',
                {
                    albedo: albedoHash,
                    normal: normalHash,
                    material: materialHash,
                });
            });

            // Gambiarra...? forçar a atualização da cor/estilo da cabeça para a mesma cor/estilo do corpo.
            requestChangeApparatus(ped, { component: 'HEADS_COLOR', data: bodyApparatusStyleId, type: 'appearance' });
        }
    }
    handleApparatusChangeAnimation(ped, apparatusType);

    return equippedMetapedClothing
}
exports('requestChangeApparatus', requestChangeApparatus);
on('appearance:requestChangeApparatus', requestChangeApparatus);
