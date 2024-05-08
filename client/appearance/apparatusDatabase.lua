
function getHumanDatabase()
    if gMpPedsComponents then
        return gMpPedsComponents
    end

    return {}
end
    

function getMetapedBodyApparatusFromShopitemAny(apparatusType, apparatusGender, apparatusId, apparatusStyleId, shopitemHash)
    local dbLayerRoot = getHumanDatabase()

    local function found(type, gender, id, styleId)
        return {
            id = tonumber(id),
            styleId = tonumber(styleId),
            type = tonumber(type),
            gender = tonumber(gender)
        }
    end

    if shopitemHash == nil then
        return
    end

    if apparatusType ~= nil then
        local dbLayerType = dbLayerRoot[apparatusType]

        if apparatusGender ~= nil then
            local dbLayerGender = dbLayerType[apparatusGender]

            if apparatusId ~= nil then
                local dbLayerStyle = dbLayerGender[apparatusId]

                if apparatusStyleId ~= nil then
                    local shopitemAny = dbLayerStyle[apparatusStyleId]
                    return found(apparatusType, apparatusGender, apparatusId, apparatusStyleId)
                else
                    for itApparatusStyleId, itShopitemAny in pairs(dbLayerStyle) do
                        if itShopitemAny == shopitemHash or GetHashKey(itShopitemAny) == shopitemHash then
                            return found(apparatusType, apparatusGender, apparatusId, itApparatusStyleId)
                        end
                    end
                end
            else
                for itApparatusId, itDbLayerStyle in pairs(dbLayerGender) do
                    if apparatusStyleId ~= nil then
                        if itDbLayerStyle[apparatusStyleId] == shopitemHash then
                            return found(apparatusType, apparatusGender, itApparatusId, apparatusStyleId)
                        end
                    else
                        for itApparatusStyleId, itShopitemAny in pairs(itDbLayerStyle) do
                            if itShopitemAny == shopitemHash or GetHashKey(itShopitemAny) == shopitemHash then
                                return found(apparatusType, apparatusGender, itApparatusId, itApparatusStyleId)
                            end
                        end
                    end
                end
            end
        else
            for itApparatusGender, itDbLayerGender in pairs(dbLayerType) do
                if apparatusId ~= nil then
                    local dbLayerStyle = itDbLayerGender[apparatusId]

                    if apparatusStyleId ~= nil then
                        local shopitemAny = dbLayerStyle[apparatusStyleId]

                        if shopitemAny == shopitemHash then
                            return found(apparatusType, itApparatusGender, apparatusId, apparatusStyleId)
                        end
                    else
                        for itApparatusStyleId, itShopitemAny in pairs(dbLayerStyle) do
                            if itShopitemAny == shopitemHash or GetHashKey(itShopitemAny) == shopitemHash then
                                return found(apparatusType, itApparatusGender, apparatusId, itApparatusStyleId)
                            end
                        end
                    end
                else
                    for itApparatusId, itDbLayerStyle in pairs(itDbLayerGender) do
                        if apparatusStyleId ~= nil then
                            if itDbLayerStyle[apparatusStyleId] == shopitemHash then
                                return found(apparatusType, itApparatusGender, itApparatusId, apparatusStyleId)
                            end
                        else
                            for itApparatusStyleId, itShopitemAny in pairs(itDbLayerStyle) do
                                if itShopitemAny == shopitemHash or GetHashKey(itShopitemAny) == shopitemHash then
                                    return found(apparatusType, itApparatusGender, itApparatusId, itApparatusStyleId)
                                end
                            end
                        end
                    end
                end
            end
        end
    else
        for itApparatusType, itDbLayerType in pairs(dbLayerRoot) do
            if apparatusGender ~= nil then
                local dbLayerGender = itDbLayerType[apparatusGender]

                if apparatusId ~= nil then
                    local dbLayerStyle = dbLayerGender[apparatusId]

                    if apparatusStyleId ~= nil then
                        return found(itApparatusType, apparatusGender, apparatusId, apparatusStyleId)
                    else
                        for itApparatusStyleId, itShopitemAny in pairs(dbLayerStyle) do
                            if itShopitemAny == shopitemHash or GetHashKey(itShopitemAny) == shopitemHash then
                                return found(itApparatusType, apparatusGender, apparatusId, itApparatusStyleId)
                            end
                        end
                    end
                else
                    for itApparatusId, itDbLayerStyle in pairs(dbLayerGender) do
                        if apparatusStyleId ~= nil then
                            if itDbLayerStyle[apparatusStyleId] == shopitemHash then
                                return found(itApparatusType, apparatusGender, itApparatusId, apparatusStyleId)
                            end
                        else
                            for itApparatusStyleId, itShopitemAny in pairs(itDbLayerStyle) do
                                if itShopitemAny == shopitemHash or GetHashKey(itShopitemAny) == shopitemHash then
                                    return found(itApparatusType, apparatusGender, itApparatusId, itApparatusStyleId)
                                end
                            end
                        end
                    end
                end
            else
                for itApparatusGender, itDbLayerGender in pairs(itDbLayerType) do
                    if apparatusId ~= nil then
                        local dbLayerStyle = itDbLayerGender[apparatusId]

                        if apparatusStyleId ~= nil then
                            return found(itApparatusType, itApparatusGender, apparatusId, apparatusStyleId)
                        end
                    else
                        for itApparatusId, itDbLayerStyle in pairs(itDbLayerGender) do
                            if apparatusStyleId ~= nil then
                                local itShopitemAny = itDbLayerStyle[itApparatusId]

                                if itShopitemAny == shopitemHash or GetHashKey(itShopitemAny) == shopitemHash then
                                    return found(itApparatusType, itApparatusGender, itApparatusId, apparatusStyleId)
                                end
                            else
                                for itApparatusStyleId, itShopitemAny in pairs(itDbLayerStyle) do
                                    if itShopitemAny == shopitemHash or GetHashKey(itShopitemAny) == shopitemHash then
                                        return found(itApparatusType, itApparatusGender, itApparatusId, itApparatusStyleId)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

function getShopitemAnyByMetapedBodyApparatus(metapedBodyApparatus)
    local dbLayerRoot = getHumanDatabase()
    -- print(" dbLayerRoot :: ", dbLayerRoot)

    local type = metapedBodyApparatus.type
    local gender = metapedBodyApparatus.gender
    local id = metapedBodyApparatus.id
    local styleId = metapedBodyApparatus.styleId

    -- print("  metapedBodyApparatus ", type, gender, id, styleId)
    local success, errorMessage

    local dbLayerType = dbLayerRoot[type + 1]

    if dbLayerType ~= nil then
        local dbLayerGender = dbLayerType[gender]

        if dbLayerGender ~= nil then
            local dbLayerStyle = dbLayerGender[id]

            if dbLayerStyle ~= nil then
                local shopitem = dbLayerStyle[styleId]

                if shopitem ~= nil then
                    return shopitem
                end
            end
        end
    end

end


function isMetapedUsingApparatusRDR3(pedId, apparatus)
    local shopitem = getShopitemAnyByMetapedBodyApparatus(apparatus);

    if not shopitem then
        return false;
    end

    local shopitemHash = type(shopitem) == 'string' and GetHashKey(shopitem) or shopitem;

    -- Não funciona por algum motivo :/ talvez só funcione com componentGroups.
    -- IsMetapedUsingComponent
    -- return !!N_0xfb4891bd7578cdc1(pedId, shopitemHash);

    -- GetNumComponentsInPed | _GetNumMetapedAssets
    local numMetaAssets = N_0x90403e8107b60e81(pedId); 

    if numMetaAssets <= 0 then
        return false;
    end

    local buffer = DataView.ArrayBuffer(8 * 5);
    local view = buffer:Buffer()

    for i = 0, numMetaAssets - 1 do
        -- GetPedComponentAtIndex
        local itShopitemHash = N_0x77ba37622e22023b(pedId, i, true, view, view);

        if shopitemHash == itShopitemHash then
            return true;
        end
    end

    return false;
end
