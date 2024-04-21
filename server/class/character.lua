function API.Character(id, firstName, lastName, birthDate, metaData, favoriteReserveType, deathState)
    local self = {}

    self.id = id
    self.firstName = firstName
    self.lastName = lastName
    self.birthDate = birthDate
    -- self.inventoryId = 0
    self.Inventory = {}
    self.favoriteReserveType = favoriteReserveType
    self.deathState = deathState
    self.metaData = metaData or {}

    self.level = level or 1
    self.xp = xp or 0
    self.role = role or 0

    self.Initialize = function(this, userId, source)
        self:setSource(source)
        self:setUserId(userId)

        local res = MySQL.single.await([[
            SELECT * 
            FROM character_inventory 
            WHERE charId = ?
        ]], {
            self.id
        })

        if res.items then
            res.items = json.decode(res.items)
        end

        self.Inventory = res
    end

    self.SetUserId = function(this, v)
        self.userId = v
    end

    self.SetSource = function(this, v)
        self.source = v
    end

    self.GetUserId = function()
        return self.userId
    end

    self.GetSource = function()
        return self.source
    end

    self.GetInventory = function()
        return self.Inventory
    end

    self.GetId = function()
        return self.id
    end

    self.GetFullName = function()
        return string.format("%s %s", self.firstName, self.lastName)
    end

    self.GetAge = function()
        return self.charAge
    end

    self.GetMetadata = function(key)
        local rows = API_Database.query("FRP/GetCharMetadata", {charId = self.id})
        if rows and rows[1] then
            self.metaData = rows[1]
        end

        if key then
            return rows[1][key]
        end

        return rows[1]
    end

    function self.SetMetadata(meta, val)
        if not meta or type(meta) ~= 'string' then return end
        self.metaData[meta] = val;

        local rows = API_Database.query("FRP/UpdateCharMetadata", {charId = self.id, metaData = self.metaData})
        return rows
    end

    self.SavePosition = function(this, x, y, z)
        local encoded = vector3(x, y, z)
        self:SetMetadata("position", encoded)
    end

    self.GetLastPosition = function(this)
        local lastPositionFromDb = self:GetMetadata("position")
        return lastPositionFromDb ~= nil and json.decode(lastPositionFromDb) or vector3(-329.9, 775.11, 121.74)
    end

    self.SetCharacterAppearance = function( this, characterAppearance )
        local res = MySQL.insert.await([[
            INSERT INTO character_appearance 
                (charId, isMale, expressions, bodyApparatusId, bodyApparatusStyleId,
                headApparatusId, teethApparatusStyleId, eyesApparatusId, 
                whistleShape, whistlePitch, whistleClarity,
                eyesApparatusStyleId, height, bodyWeightOufitType, bodyKindType)
            VALUES( ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ? )
        ]], {
            self.id,
            characterAppearance.isMale, json.encode(characterAppearance.expressions), characterAppearance.bodyApparatusId, characterAppearance.bodyApparatusStyleId,
            characterAppearance.headApparatusId, characterAppearance.teethApparatusStyleId, characterAppearance.eyesApparatusId, 
            characterAppearance.whistleShape or 0, characterAppearance.whistlePitch or 0, characterAppearance.whistleClarity or 0,
            characterAppearance.eyesApparatusStyleId, characterAppearance.height, characterAppearance.bodyWeightOufitType, characterAppearance.bodyKindType
        })

        return res
    end

    self.SetCharacterAppearanceCustomizable = function( this, characterAppearance )
        local res = MySQL.insert.await([[
            INSERT INTO character_appearance_customizable 
                (charId, overridePedModel, overridePedIsMale, equippedOutfitId,
                hairApparatusId, hairApparatusStyleId, mustacheApparatusId, 
                mustacheApparatusStyleId, weightPercentage)
            VALUES( ?, ?, ?, ?, ?, ?, ?, ?, ? )
        ]], {
            self.id,
            characterAppearance.overridePedModel, characterAppearance.overridePedIsMale, characterAppearance.equippedOutfitId,
            characterAppearance.hairApparatusId, characterAppearance.hairApparatusStyleId, characterAppearance.mustacheApparatusId, 
            characterAppearance.mustacheApparatusStyleId, characterAppearance.weightPercentage or 0
        })

        return res
    end

    self.SetCharacterAppearanceOverlays = function( this, characterAppearanceOverlays )
        local res = MySQL.insert.await([[
            INSERT INTO character_appearance_overlays 
                (charId, data)
            VALUES( ?, ? )
        ]], {
            self.id,
            characterAppearanceOverlays
        })

        return res
    end

    self.SetCharacterExpessions = function( this, expressions )
        
    end

    self.SetCharacterWhistle = function(this, whistle)
        local whistleShape, whistlePitch, whistleClarity = table.unpack( whistle )
    end

    self.Release = function(this)
        TriggerEvent("API:ReleaseCharacter", self.source)
    end

    return self
end
