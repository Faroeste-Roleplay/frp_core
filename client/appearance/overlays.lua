MetapedClothingSystemOverlayHandler = {}

function MetapedClothingSystemOverlayHandler.createPlayer()
    local self = {
        LAYER_POOL_MAX = 22,
        metapedClothingSystem = nil,
        baseLayer = nil,
        layers = nil
    }

    self.initTextureBlend = function()
        if not self.baseLayer or not self.baseLayer.textureId then
            self.baseLayer = {
                textureId = -1,
                numLayers = 0,
                nextLayerId = 0
            }
            self.layers = {}
        end

        self.baseLayer.albedo = GetHashKey('mp_head_mr1_sc08_c0_000_ab')
        self.baseLayer.normal = GetHashKey('mp_head_mr1_003_nm')
        self.baseLayer.material = 1352973225
        self.baseLayer.tag = GetHashKey('heads')
    end

    self.findLayerByType = function(layerType)
        print(" setBaseLayerTextureData :: ", layerType)
        local index = -1
        local matchingLayer = nil

        for i, layer in ipairs(self.layers) do
            if layer.type == layerType then
                index = i
                matchingLayer = layer
                break
            end
        end

        return index, matchingLayer
    end

    self.setBaseLayerTextureData = function(albedo, normal, material)
        print(" setBaseLayerTextureData :: ", albedo, normal, material)
        self.baseLayer.albedo = albedo
        self.baseLayer.normal = normal
        self.baseLayer.material = material

        local textureId = self.baseLayer.textureId

        -- SetTextureLayerTextureMap
        N_0x253a63b5badbc398(textureId, 0, albedo, normal, material)
    end

    self.createTextureBlend = function()
        print("createTextureBlend")

        print(" SELF :: ", json.encode(self.baseLayer))

        if not self.baseLayer then
            self:initTextureBlend()
        end

        local textureId = self.baseLayer.textureId
        local albedo = self.baseLayer.albedo
        local normal = self.baseLayer.normal
        local material = self.baseLayer.material

        print("createTextureBlend - Texture Info:", textureId, albedo, normal, material)

        if textureId ~= -1 then
            -- SetTextureLayerTextureMap
            N_0x253a63b5badbc398(textureId, 0, albedo, normal, material)
        else
            -- RequestTexture
            local newTextureId = N_0xc5e7204f322e49eb(albedo, normal, material)

            print("REQUEST TEXTURE: ", newTextureId)

            if newTextureId == -1 then
                error("Failed to create overlay texture - albedo: " .. albedo .. ", normal: " .. normal .. ", material: " .. material)
            end

            self.baseLayer.textureId = newTextureId

            -- Game.onResourceStop.connect(() =>
            -- {
            --     // ClearPedTexture
            --     N_0xb63b9178d0f58d82(textureId);
            -- 
            --     // ReleaseTexture
            --     N_0x6befaa907b076859(textureId);
            -- });

            AddEventHandler("onResourceStop", function(resName)
                if resName == GetCurrentResourceName() then
                    -- ClearPedTexture
                    N_0xb63b9178d0f58d82(newTextureId)

                    -- ReleaseTexture
                    N_0x6befaa907b076859(newTextureId)
                end
            end)

            while not N_0x31dc8d3f216d8509(newTextureId) do 
                Wait(100)
                print(" N_0x31dc8d3f216d8509 ")
            end

        end

        return true
    end


    -- Define other methods similarly


    self.updateLayerData = function(layer, updateTextureMap)
        print(" updateLayerData :: ")
        local textureId = self.baseLayer.textureId

        local layerId = layer.layerId
        local albedo = layer.albedo
        local normal = layer.normal
        local material = layer.material
        local pallete = layer.pallete
        local tint0 = layer.tint0
        local tint1 = layer.tint1
        local tint2 = layer.tint2
        local modTexture = layer.modTexture
        local modTexAlpha = layer.modTexAlpha
        local modChannel = layer.modChannel
        local texRough = layer.texRough
        local texAlpha = layer.texAlpha
        local sheetGridIndex = layer.sheetGridIndex

        if updateTextureMap and (albedo or normal or material) then
            print(string.format("updateLayerData :: albedo(%s) normal(%s) material(%s)", albedo, normal, material))

            -- SetTextureLayerTextureMap
            N_0x253a63b5badbc398(textureId, layerId, albedo or 0, normal or 0, material or 0)
        end

        if pallete then
            print(string.format("updateLayerData :: pallete(%s) tint0(%s) tint1(%s) tint1(%s)", pallete, tint0, tint1, tint1))

            -- SetTextureLayerPallete
            N_0x1ed8588524ac9be1(textureId, layerId, pallete)

            -- SetTextureLayerTint
            N_0x2df59ffe6ffd6044(textureId, layerId, tint0, tint1, tint2)
        end

        if modTexture then
            print(string.format("updateLayerData :: modTexture(%s) modTexAlpha(%s) modChannel(%s)", modTexture, modTexAlpha, modChannel))

            -- SetTextureLayerMod
            N_0xf2ea041f1146d75b(textureId, layerId, modTexture, modTexAlpha + 0.0001, modChannel)
        end

        if texRough then
            print(string.format("updateLayerData :: texRough(%s)", texRough))

            -- SetTextureLayerRoughness
            N_0x057c4f092e2298be(textureId, layerId, texRough)
        end

        print(string.format("updateLayerData :: sheetGridIndex(%s)", sheetGridIndex))

        -- SetTextureLayerSheetGridIndex
        N_0x3329aae2882fc8e4(textureId, layerId, sheetGridIndex or 0)

        print(string.format("updateLayerData :: texAlpha(%s)", texAlpha))

        -- SetTextureLayerAlpha
        N_0x6c76bc24f8bb709a(textureId, layerId, texAlpha + 0.0001)
    end

    self.addLayerToTextureBlend = function(layer)
        print(" addLayerToTextureBlend :: ", json.encode(layer))
        local textureId = self.baseLayer.textureId

        local albedo = layer.albedo
        local normal = layer.normal
        local material = layer.material
        local blendType = layer.blendType
        local texAlpha = layer.texAlpha
        local sheetGridIndex = layer.sheetGridIndex

        -- AddTextureLayer
        local layerId = N_0x86bb5ff45f193a02(textureId, albedo or 0, normal or 0, material or 0, blendType, texAlpha + 0.0001, sheetGridIndex)

        print('adding layer to texture blend', textureId, layerId, layer)

        if layerId == -1 then
            -- throw new ApplicationException(`Ocorreu um error ao criar uma nova layer do para o nosso texture blend. Type(${eOverlayToStr[layer.type]}) Albedo(${albedo}) Normal(${normal}) Material(${material}) BlendType(${blendType})`);
        end

        layer.layerId = layerId

        self:updateLayerData(layer, false)
    end

    self.getBlendType = function(layerType)
        print(" getBlendType :: ", layerType)
        if layerType == eOverlayLayer.MPC_OVERLAY_LAYER_FACIAL_HAIR or
            layerType == eOverlayLayer.MPC_OVERLAY_LAYER_FOUNDATION or
            layerType == eOverlayLayer.MPC_OVERLAY_LAYER_HEAD_HAIR or
            layerType == eOverlayLayer.MPC_OVERLAY_LAYER_EYESHADOW or
            layerType == eOverlayLayer.MPC_OVERLAY_LAYER_LIPSTICK or
            layerType == eOverlayLayer.MPC_OVERLAY_LAYER_FACE_PAINT or
            layerType == eOverlayLayer.MPC_OVERLAY_LAYER_EYELINER or
            layerType == eOverlayLayer.MPC_OVERLAY_LAYER_INVALID or
            layerType == eOverlayLayer.MPC_OVERLAY_LAYER_BLUSHER or
            layerType == eOverlayLayer.MPC_OVERLAY_LAYER_EYEBROWS or
            layerType == eOverlayLayer.MPC_OVERLAY_LAYER_GRIME then
            return 0
        elseif layerType == eOverlayLayer.MPC_OVERLAY_LAYER_COMPLEXION or
            layerType == eOverlayLayer.MPC_OVERLAY_LAYER_COMPLEXION_2 or
            layerType == eOverlayLayer.MPC_OVERLAY_LAYER_ROOT or
            layerType == eOverlayLayer.MPC_OVERLAY_LAYER_FRECKLES or
            layerType == eOverlayLayer.MPC_OVERLAY_LAYER_SKIN_MOTTLING or
            layerType == eOverlayLayer.MPC_OVERLAY_LAYER_AGEING or
            layerType == eOverlayLayer.MPC_OVERLAY_LAYER_SPOTS or
            layerType == eOverlayLayer.MPC_OVERLAY_LAYER_MOLES or
            layerType == eOverlayLayer.MPC_OVERLAY_LAYER_SCAR then
            return 1
        else
            return 0
        end
    end

    self.updateOrCreateLayer = function(layer)
        print(" updateOrCreateLayer :: ", json.encode(layer))
        local baseLayer = self.baseLayer

        if layer.type == eOverlayLayer.MPC_OVERLAY_LAYER_ROOT then
            self.baseLayer = layer
            self:setBaseLayerTextureData(layer.albedo, layer.normal, layer.material)
        else
            local matchingLayerIndex, matchingLayer = self:findLayerByType(layer.type)

            if not matchingLayer then
                -- create
                if baseLayer.numLayers >= self.LAYER_POOL_MAX then
                    -- throw new CustomException('Atingiu o limite de layers possíveis.');]
                    error('Atingiu o limite de layers possíveis.')
                end

                local basicLayer = {
                    priority = 0,
                    albedo = 0,
                    normal = 0,
                    material = 0,
                    sheetGridIndex = 0,
                    tint0 = 0,
                    tint1 = 0,
                    tint2 = 0,
                    texAlpha = 0.0,
                    blendType = self:getBlendType(layer.type)
                }

                local newLayer = exports.frp_core:mergeObjectData(basicLayer, layer)
                self.layers[baseLayer.numLayers] = newLayer
                baseLayer.numLayers = baseLayer.numLayers + 1
                self:addLayerToTextureBlend(newLayer)
            else
                local updatedLayer = exports.frp_core:mergeObjectData(matchingLayer, layer)
                self.layers[matchingLayerIndex] = updatedLayer
                self:updateLayerData(updatedLayer, true)
            end
        end
    end

    self.applyTextureBlend = function(pedId)
        print(" applyTextureBlend :: ", pedId)
        if not NetworkGetEntityIsNetworked(pedId) then
            -- throw CustomException('Ped não é networked')
            error('Ped não é networked', pedId)
        end

        local baseLayerTextureId = self.baseLayer.textureId

        local timeOut = 0
        while true do 
            if N_0x31dc8d3f216d8509(baseLayerTextureId) then
                break
            else
                N_0x92daaba2c1c10b0e(self.baseLayer.textureId)
            end
            timeOut += 1

            if timeOut >= 3000 then
                break
            end

            Wait(1)
        end

        N_0x0b46e25761519058(pedId, self.baseLayer.tag, baseLayerTextureId)
        N_0x92daaba2c1c10b0e(baseLayerTextureId)
        N_0xcc8ca3e88256e58f(pedId, 0, 1, 1, 1, false)
    end


    return self
end
