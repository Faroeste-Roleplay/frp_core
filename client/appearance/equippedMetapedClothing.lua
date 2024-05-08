local equippedMetapedClothing 

AddEventHandler("appearance:update:equippedMetapedClothing", function(map, method, type, data)
    if not equippedMetapedClothing[map] then
        return
    end

    if method == "delete" then
        equippedMetapedClothing[map][type] = nil
    elseif method == "set" then
        equippedMetapedClothing[map][type] = data
    end
end)