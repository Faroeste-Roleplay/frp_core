
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

