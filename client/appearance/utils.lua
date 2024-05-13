
function handleApparatusChangeAnimation(ped, type)
    if (type == eMetapedBodyApparatusType.Teeth) then
        lib.requestAnimDict('FACE_HUMAN@GEN_MALE@BASE', 500)

        TaskPlayAnim(ped, 'FACE_HUMAN@GEN_MALE@BASE', 'Face_Dentistry_Loop',  8.0, -8.0, -1, 16, 0.0, false, 0, false, 0, false);
        return;
    end

    ClearPedTasks(ped, 0, 0);
end

function indexOf(array, value)
    for i, v in pairs(array) do
        if v == value then
            return i
        end
    end
    return nil
end

function removeDecimalZero(number)
    local strNumber = tostring(number)
    local strippedNumber = strNumber

    -- Verifica se o número tem um ponto decimal e termina com .0
    if string.match(strNumber, "%.%d*") then
        strippedNumber = string.match(strNumber, "%.%d+") == ".0" and string.match(strNumber, "%d+") or strNumber
    end

    return tonumber(strippedNumber)
end


function UpdatePedVariation(ped)
    Citizen.InvokeNative("0x704C908E9C405136", ped)
    Citizen.InvokeNative("0xCC8CA3E88256E58F", ped, false, true, true, true, false)
end

function SetPedComponentEnabled(ped, componentHash, immediately, isMp)
    Citizen.InvokeNative("0xD3A7B003ED343FD9", ped, componentHash, immediately, isMp, true)
    
    -- Não deveria estar aqui, mas tá, só pra garantir que será executado toda vez...
    UpdatePedVariation(ped)
end


function setDefaultComponentsForPed(ped)
    local isMale = IsPedMale(ped) == true
    local defaultComponents = {}

    if isMale then
        defaultComponents = {
            'CLOTHING_ITEM_M_HAIR_013_jet_black',
            'CLOTHING_ITEM_M_HEAD_012_V_006'
        }
    else
        defaultComponents = {
            'CLOTHING_ITEM_f_HAIR_021_jet_black',
            'CLOTHING_ITEM_F_HEAD_028_V_005'
        }
    end

    for _, componentHashName in ipairs(defaultComponents) do
        local componentHash = GetHashKey(componentHashName)
        SetPedComponentEnabled(ped, componentHash, true, true)
    end
end
