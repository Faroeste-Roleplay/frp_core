const definedProps = obj => Object.fromEntries(
    Object.entries(obj).filter(([k, v]) => v !== undefined)
);

class MetapedClothingSystemOverlayHandler
{
    constructor(){
        // Limite definido pelo próprio jogo.
        this.LAYER_POOL_MAX = 22;    
        this.metapedClothingSystem;

        this.baseLayer = undefined
        this.layers = undefined


        this.registerCommands();
    }

    initTextureBlend()
    {
        if (!this.baseLayer?.textureId)
        {
            this.baseLayer =
            {
                textureId: -1,
                numLayers: 0,
                nextLayerId: 0,
            }

            this.layers = [ ];
        }

        {
            this.baseLayer.albedo = GetHashKey('mp_head_mr1_sc08_c0_000_ab');
            this.baseLayer.normal = GetHashKey('mp_head_mr1_003_nm');
            this.baseLayer.material = 1352973225;

            this.baseLayer.tag = GetHashKey('heads');
        }

        console.log(" initTextureBlend :: ")
    }

    findLayerByType(layerType)
    {
        const index = this.layers.findIndex(l => l.type === layerType);

        return [ index, index ? this.layers[index] : undefined];
    }

    setBaseLayerTextureData(albedo, normal, material)
    {
        this.baseLayer.albedo = albedo;
        this.baseLayer.normal = normal;
        this.baseLayer.material = material;

        const { textureId } = this.baseLayer;

        // SetTextureLayerTextureMap
        N_0x253a63b5badbc398(textureId, 0, albedo, normal, material);
    }

    async createTextureBlend()
    {
        console.log( " createTextureBlend :: ")
        if (!this.baseLayer)
        {
            this.initTextureBlend();
        }

        const {
            textureId,

            albedo,
            normal,
            material,
        } = this.baseLayer;

        console.log( " createTextureBlend :: TT ", textureId, albedo, normal, material)

        if (textureId !== -1)
        {
            // SetTextureLayerTextureMap
            N_0x253a63b5badbc398(textureId, 0, albedo, normal, material);
        }
        else
        {
            // RequestTexture
            const textureId = N_0xc5e7204f322e49eb(albedo, normal, material);

            console.log(" REQUEST TEXTURE : ", textureId)

            if (textureId === -1)
            {
                throw new Error(`Falha o criar a textura do overlay albedo(${albedo}) normal(${normal}) material(${material})`)
            }

            this.baseLayer.textureId = textureId;

            // Game.onResourceStop.connect(() =>
            // {
            //     // ClearPedTexture
            //     N_0xb63b9178d0f58d82(textureId);

            //     // ReleaseTexture
            //     N_0x6befaa907b076859(textureId);
            // });

            on("onResourceStop", (resName) => {
                if (resName == GetCurrentResourceName() ) {
                    // ClearPedTexture
                    N_0xb63b9178d0f58d82(textureId);

                    // ReleaseTexture
                    N_0x6befaa907b076859(textureId);
                }
            })

            return await new Promise(resolve =>
            {
                const tick = setTick(() =>
                {
                    // IsTextureValid
                    if (N_0x31dc8d3f216d8509(textureId))
                    {
                        clearTick(tick);
    
                        resolve(true);
                    }
                });
            });
        }

        return true;
    }

    updateLayerData(layer, updateTextureMap)
    {
        const textureId = this.baseLayer.textureId;

        const {
            layerId,

            albedo,
            normal,
            material,

            pallete,
            tint0,
            tint1,
            tint2,

            modTexture,
            modTexAlpha,
            modChannel,

            texRough,

            texAlpha,

            sheetGridIndex,
        } = layer;

        if (updateTextureMap && (albedo != undefined || normal != undefined || material != undefined))
        {
            console.log(`updateLayerData :: albedo(${albedo}) normal(${normal}) material(${material})`);

            // SetTextureLayerTextureMap
            N_0x253a63b5badbc398(textureId, layerId, albedo ?? 0, normal ?? 0, material ?? 0);
        }

        if (pallete)
        {
            console.log(`updateLayerData :: pallete(${pallete}) tint0(${tint0}) tint1(${tint1}) tint1(${tint1})`);

            // SetTextureLayerPallete
            N_0x1ed8588524ac9be1(textureId, layerId, pallete);

            // SetTextureLayerTint
            N_0x2df59ffe6ffd6044(textureId, layerId, tint0, tint1, tint2);
        }

        if (modTexture)
        {
            console.log(`updateLayerData :: modTexture(${modTexture}) modTexAlpha(${modTexAlpha}) modChannel(${modChannel})`);

            // SetTextureLayerMod
            N_0xf2ea041f1146d75b(textureId, layerId, modTexture, modTexAlpha + 0.0001, modChannel);
        }

        if (texRough)
        {
            console.log(`updateLayerData :: texRough(${texRough})`);

            // SetTextureLayerRoughness
            N_0x057c4f092e2298be(textureId, layerId, texRough);
        }

        console.log(`updateLayerData :: sheetGridIndex(${sheetGridIndex})`);

        // SetTextureLayerSheetGridIndex
        N_0x3329aae2882fc8e4(textureId, layerId, sheetGridIndex ?? 0);

        console.log(`updateLayerData :: texAlpha(${texAlpha})`);

        // SetTextureLayerAlpha
        N_0x6c76bc24f8bb709a(textureId, layerId, texAlpha + 0.0001);
    }

    addLayerToTextureBlend(layer)
    {
        const {
            albedo,
            normal,
            material,

            blendType,
            
            texAlpha,
            sheetGridIndex
        } = layer;

        // AddTextureLayer

        const layerId = N_0x86bb5ff45f193a02(this.baseLayer.textureId, albedo || 0, normal || 0, material || 0, blendType, texAlpha + 0.0001, sheetGridIndex);

        console.log('adding layer to texture blend', this.baseLayer.textureId, layerId, layer);

        if (layerId == -1)
        {
            // throw new ApplicationException(`Ocorreu um error ao criar uma nova layer do para o nosso texture blend. Type(${eOverlayToStr[layer.type]}) Albedo(${albedo}) Normal(${normal}) Material(${material}) BlendType(${blendType})`);
        }

        layer.layerId = layerId;

        this.updateLayerData(layer, false);
    }

    getBlendType(layerType)
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
    };

    updateOrCreateLayer(layer)
    {
        const baseLayer = this.baseLayer;

        if (layer.type == eOverlayLayer.MPC_OVERLAY_LAYER_ROOT)
        {
            this.baseLayer = Object.assign(this.baseLayer, definedProps(layer));

            this.setBaseLayerTextureData(this.baseLayer.albedo, this.baseLayer.normal, this.baseLayer.material);
        }
        else
        {
            const [ matchingLayerIndex, matchingLayer ] = this.findLayerByType(layer.type);

            console.log('matchingLayer', matchingLayer !== undefined);

            if (!matchingLayer)
            {
                // create

                if (baseLayer.numLayers >= this.LAYER_POOL_MAX)
                {
                    // throw new CustomException('Atingiu o limite de layers possíveis.');
                }

                const basicLayer =
                {
                    // layerIndex?: number;

                    priority: 0,
                
                    albedo: 0,
                    normal: 0,
                    material: 0,
                
                    sheetGridIndex: 0,
                
                    // modTexture: number;
                    // modChannel: number;
                
                    // pallete: number;
                    tint0: 0,
                    tint1: 0,
                    tint2: 0,
                
                    texAlpha: 0.0,
                    // modTexAlpha?: number;
                
                    // texRough?: number;
                    blendType: this.getBlendType(layer.type),
                }

                // Marge
                const newLayer = Object.assign(basicLayer, definedProps(layer));

                this.layers[baseLayer.numLayers] = newLayer;

                baseLayer.numLayers++;

                // const layerId = baseLayer.numLayers - 1;

                this.addLayerToTextureBlend(newLayer);
            }
            else
            {
                const updatedLayer = Object.assign(matchingLayer, definedProps(layer));

                this.layers[matchingLayerIndex] = updatedLayer

                this.updateLayerData(updatedLayer, true);
            }
        }
    }

    async applyTextureBlend(pedId)
    {
        if (!NetworkGetEntityIsNetworked(pedId))
        {
            throw new CustomException('Ped não é networked');
        }

        const baseLayerTextureId = this.baseLayer.textureId;

        await new Promise(resolve =>
        {
            const tick = setTick(() =>
            {
                // IsTextureValid
                if (N_0x31dc8d3f216d8509(baseLayerTextureId))
                {
                    clearTick(tick);

                    resolve(true);
                }
                else
                {
                    // UpdatePedTexture
                    N_0x92daaba2c1c10b0e(this.baseLayer.textureId);
                }
            });
        });

        N_0x0b46e25761519058(pedId, this.baseLayer.tag, baseLayerTextureId);

        N_0x92daaba2c1c10b0e(baseLayerTextureId);
        N_0xcc8ca3e88256e58f(pedId, 0, 1, 1, 1, false);

        // console.log('applied texture blend', baseLayerTextureId);
    }

    registerCommands()
    {
        RegisterCommand('over', (source, args, raw) =>
        {
            const localPed = PlayerPedId()

            console.log('mp_u_faov_lipstick_000_ab', (GetHashKey('mp_u_faov_lipstick_000_ab') >>> 0).toString(16));

            const [
                albedo,
                normal,
                material,

                pallete,
                tint0,
                tint1,
                tint2,
            ] = args;
        
            // A gente não sabe qual paleta e quais tints o jogo original usa
            // então a gente vai usar uma paleta qualquer
            // e liberar o uso de 0-255 da 'tint0'
            //
            // Banco de dados
            //
            // LipstickTint0
            // 

            global.exports.frp_core.clothingSystemPushRequest(localPed, 'CreateHeadOverlay', { })
            .then(() =>
            {
                this.updateOrCreateLayer(
                    {
                        type: eOverlayLayer.MPC_OVERLAY_LAYER_LIPSTICK,
                        
                        albedo: Number(albedo), // tx_id
                        normal: Number(normal), // tx_normal
                        material: Number(material), // tx_material
        
                        texAlpha: 1.0,
                        sheetGridIndex: 0,
        
                        pallete: Number(pallete),
                        tint0: Number(tint0),
                        tint1: Number(tint1),
                        tint2: Number(tint2),
        
                        blendType: 0,
                    }
                );
        
                this.applyTextureBlend(localPed);
            });
        }, false);
    }
}