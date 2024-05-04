// RegisterCommand("startPed", (_, args) => {
//     const playerPed = PlayerPedId();
//     handleStartEditor(playerPed);
// }, false);
// RegisterCommand("cc", (_, args) => {
//     const id1 = args[0];
//     const id2 = args[1];
//     const id3 = args[2];

//     const playerPed = PlayerPedId();

//     requestChangeApparatus(playerPed, {
//         component: id1,
//         data: Number(id2),
//         type: id3
//     });
// }, false);

async function getHumanDatabase()
{
    const dataFile = global.exports.frp_core.mp_peds_components();
    if (dataFile)
    {
        return dataFile
    }
}

// console.log(`equippedApparels`, equippedApparels);
async function getShopitemAnyByMetapedBodyApparatus(metapedBodyApparatus)
{
    const dbLayerRoot = await getHumanDatabase();
    // console.log(" dbLayerRoot :: ", dbLayerRoot);

    const { type, gender, id, styleId } = metapedBodyApparatus;

    // console.log("  metapedBodyApparatus ", type, gender, id, styleId)
    try
    {
        const dbLayerType   = dbLayerRoot[type];

        // if (!dbLayerType) throw new ApplicationException('Type');

        const dbLayerGender = dbLayerType[gender];

        // if (!dbLayerGender) throw new ApplicationException('Gender');

        const dbLayerStyle  = dbLayerGender[id];

        // if (!dbLayerStyle) throw new ApplicationException('Style');

        const shopitem = dbLayerStyle[styleId];

        return shopitem;
    }
    catch(e)
    {
        // throw new ApplicationException(`Não foi possível entrar um Shopitem para o Apparatus: Tipo(${eMetapedBodyApparatusType[type] ?? type}) Genêro(${eMetapedBodyApparatusGender[gender] ?? gender}) Id(${id}) Style(${styleId}) Layer(${e.message})`);
    }
};

async function getMetapedBodyApparatusFromShopitemAny(apparatusType, apparatusGender, apparatusId, apparatusStyleId, shopitemHash)
{
    const dbLayerRoot = await getHumanDatabase();

    const found = (type, gender, id, styleId) =>
    {
        return {
            id: Number(id),
            styleId: Number(styleId),
            type: Number(type),
            gender: Number(gender),
        };
    };

    if (shopitemHash == null)
    {
        return;
    }
    
    if (apparatusType != null)
    {
        const dbLayerType = dbLayerRoot[apparatusType];

        if (apparatusGender != null)
        {
            const dbLayerGender = dbLayerType[apparatusGender]

            if (apparatusId != null)
            {
                const dbLayerStyle = dbLayerGender[apparatusId];

                // console.log('apparatusStyleId', apparatusStyleId);

                if (apparatusStyleId != null)
                {
                    const shopitemAny = dbLayerStyle[apparatusStyleId];

                    // return [ 'yes', -1 ];

                    return found(apparatusType, apparatusGender, apparatusId, apparatusStyleId);
                }
                else
                {
                    for (const [itApparatusStyleId, itShopitemAny] of Object.entries(dbLayerStyle))
                    {
                        if (itShopitemAny == shopitemHash || GetHashKey(itShopitemAny) == shopitemHash)
                        {
                            // return [ 'yes', 0 ];

                            return found(apparatusType, apparatusGender, apparatusId, itApparatusStyleId);
                        }
                    }
                }
            }
            else
            {
                for (const [itApparatusId, itDbLayerStyle] of Object.entries(dbLayerGender))
                {
                    if (apparatusStyleId != null)
                    {
                        if (itDbLayerStyle[apparatusStyleId] == shopitemHash)
                        {
                            // return [ 'yes', 1 ];

                            return found(apparatusType, apparatusGender, itApparatusId, apparatusStyleId);
                        }
                    }
                    else
                    {
                        for (const [itApparatusStyleId, itShopitemAny] of Object.entries(itDbLayerStyle))
                        {
                            if (itShopitemAny == shopitemHash || GetHashKey(itShopitemAny ) == shopitemHash)
                            {
                                // return [ 'yes', 2 ];

                                return found(apparatusType, apparatusGender, itApparatusId, itApparatusStyleId);
                            }
                        } 
                    }
                }
            }
        }
        else
        {
            for (const [ítApparatusGender, itDbLayerGender] of Object.entries(dbLayerType))
            {
                if (apparatusId != null)
                {
                    const dbLayerStyle = itDbLayerGender[apparatusId];

                    if (apparatusStyleId != null)
                    {
                        const shopitemAny = dbLayerStyle[apparatusStyleId]

                        if (shopitemAny == shopitemHash)
                        {
                            // return [ 'yes', 3 ];

                            return found(apparatusType, ítApparatusGender, apparatusId, apparatusStyleId);
                        }
                    }
                    else
                    {
                        for (const [itApparatusStyleId, itShopitemAny] of Object.entries(dbLayerStyle))
                        {
                            if (itShopitemAny == shopitemHash || GetHashKey(itShopitemAny ) == shopitemHash)
                            {
                                // return [ 'yes', 4 ];

                                return found(apparatusType, ítApparatusGender, apparatusId, itApparatusStyleId);
                            }
                        }
                    }
                }
                else
                {
                    for (const [itApparatusId, itDbLayerStyle] of Object.entries(itDbLayerGender))
                    {
                        if (apparatusStyleId != null)
                        {
                            const shopitemAny = itDbLayerStyle[apparatusStyleId];

                            if (shopitemAny == shopitemHash)
                            {
                                // return [ 'yes', 5 ];

                                return found(apparatusType, ítApparatusGender, itApparatusId, apparatusStyleId);
                            }
                        }
                        else
                        {
                            for (const [itApparatusStyleId, itShopitemAny] of Object.entries(itDbLayerStyle))
                            {
                                if (itShopitemAny == shopitemHash || GetHashKey(itShopitemAny) == shopitemHash)
                                {
                                    // return [ 'yes', 6 ];

                                    return found(apparatusType, ítApparatusGender, itApparatusId, itApparatusStyleId);
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    else
    {
        for (const [itApparatusType, itDbLayerType] of Object.entries(dbLayerRoot))
        {
            if (apparatusGender != null)
            {
                const dbLayerGender = itDbLayerType[apparatusGender];

                if (apparatusId != null)
                {
                    const dbLayerStyle = dbLayerGender[apparatusId];

                    if (apparatusStyleId != null)
                    {
                        // shopitemAny = dbLayerStyle[apparatusStyleId]

                        // return [ 'yes', 7 ];

                        return found(itApparatusType, apparatusGender, apparatusId, apparatusStyleId);
                    }
                    else
                    {
                        for (const [itApparatusStyleId, itShopitemAny] of Object.entries(dbLayerStyle))
                        {
                            if (itShopitemAny == shopitemHash || GetHashKey(itShopitemAny) == shopitemHash)
                            {
                                // return [ 'yes', 8 ];

                                return found(itApparatusType, apparatusGender, apparatusId, itApparatusStyleId);
                            }
                        }
                    }
                }
                else
                {
                    for (const [itApparatusId, itDbLayerStyle] of Object.entries(dbLayerGender))
                    {
                        if (apparatusStyleId != null)
                        {
                            if (itDbLayerStyle[apparatusStyleId] == shopitemHash)
                            {
                                // return [ 'yes', 9 ];

                                return found(itApparatusType, apparatusGender, itApparatusId, apparatusStyleId);
                            }
                        }
                        else
                        {
                            for (const [itApparatusStyleId, itShopitemAny] of Object.entries(itDbLayerStyle))
                            {
                                if (itShopitemAny == shopitemHash || GetHashKey(itShopitemAny) == shopitemHash)
                                {
                                    // return [ 'yes', 10 ];

                                    return found(itApparatusType, apparatusGender, itApparatusId, itApparatusStyleId);
                                }
                            }
                        }
                    }
                }
            }
            else
            {
                for (const [itApparatusGender, itDbLayerGender] of Object.entries(itDbLayerType))
                {
                    if (apparatusId != null)
                    {
                        const dbLayerStyle = itDbLayerGender[apparatusId];

                        if (apparatusStyleId != null)
                        {
                            // shopitemAny = dbLayerStyle[apparatusStyleId];

                            // return [ 'yes', 11 ];

                            return found(itApparatusType, itApparatusGender, apparatusId, apparatusStyleId);
                        }
                    }
                    else
                    {
                        for (const [itApparatusId, itDbLayerStyle] of Object.entries(itDbLayerGender))
                        {
                            if (apparatusStyleId != null)
                            {
                                const itShopitemAny = itDbLayerStyle[itApparatusId];

                                if (itShopitemAny == shopitemHash || GetHashKey(itShopitemAny ) == shopitemHash)
                                {
                                    // return [ 'yes', 12 ];

                                    return found(itApparatusType, itApparatusGender, itApparatusId, apparatusStyleId);
                                }
                            }
                            else
                            {
                                for (const [itApparatusStyleId, itShopitemAny] of Object.entries(itDbLayerStyle))
                                {
                                    if (itShopitemAny == shopitemHash || GetHashKey(itShopitemAny ) == shopitemHash)
                                    {
                                        // return [ 'yes', 13 ];

                                        return found(itApparatusType, itApparatusGender, itApparatusId, itApparatusStyleId);
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
exports('getMetapedBodyApparatusFromShopitemAny', getMetapedBodyApparatusFromShopitemAny)

async function isMetapedUsingApparatusRDR3(pedId, apparatus)
{
    const shopitem = await getShopitemAnyByMetapedBodyApparatus(apparatus);

    if (!shopitem)
    {
        return false;
    }

    const shopitemHash = typeof shopitem == 'string' ? GetHashKey(shopitem) : shopitem;

    // Não funciona por algum motivo :/ talvez só funcione com componentGroups.
    // IsMetapedUsingComponent
    // return !!N_0xfb4891bd7578cdc1(pedId, shopitemHash);

    // GetNumComponentsInPed | _GetNumMetapedAssets
    const numMetaAssets = N_0x90403e8107b60e81(pedId); 

    if (numMetaAssets <= 0)
    {
        return false;
    }

    const buffer = new ArrayBuffer(8 * 5);
    const view = new DataView(buffer);

    for (let i = 0; i < numMetaAssets; i++)
    {
        // GetPedComponentAtIndex
        const itShopitemHash = N_0x77ba37622e22023b(pedId, i, true, view, view);

        if (shopitemHash == itShopitemHash)
        {
            return true;
        }
    }

    return false;
};