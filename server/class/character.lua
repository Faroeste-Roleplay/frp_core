function API.Character(id, firstName, lastName, birthDate, metaData, favoriteReserveType, deathState)
    local self = {}

    self.id = id
    self.firstName = firstName
    self.lastName = lastName
    self.birthDate = birthDate
    self.Inventory = {}
    self.favoriteReserveType = favoriteReserveType
    self.deathState = deathState
    self.metaData = metaData or {}
    self.outfitId = 0
	self.session = {}

    self.level = level or 1
    self.xp = xp or 0
    self.role = role or 0

    self.Initialize = function(this, userId, source)
        self:SetSource(source)
        self:SetUserId(userId)

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

        self:GetCurrentOutfit()

        self:GetMetadata()

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

    self.GetBirthDate = function()
        return self.birthDate
    end

    self.GetMetadata = function(this, key)
        if not self.metaData[key] then
            local rows = API_Database.query("FRP/GetCharMetadata", {charId = self.id})

            if rows and rows[1] then
                local rowDecoded = rows[1]
                self.metaData = json.decode(rowDecoded.metaData)
            end
        end

        if key then
            return self.metaData[key]
        end

        return self.metaData
    end

    function self.SetMetadata(this, meta, val)
        if not meta or type(meta) ~= 'string' then return end
        self.metaData[meta] = val;
        local rows = API_Database.query("FRP/UpdateCharMetadata", {charId = self.id, metaData = json.encode(self.metaData)})
        return rows
    end

    self.SavePosition = function(this, position)
        self:SetMetadata("position", position)
    end

    self.GetLastPosition = function(this)
        local lastPositionFromDb = self:GetMetadata("position")
        return lastPositionFromDb ~= nil and vector3(lastPositionFromDb.x, lastPositionFromDb.y, lastPositionFromDb.z) or vector3(-329.9, 775.11, 121.74)
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
                mustacheApparatusStyleId)
            VALUES( ?, ?, ?, ?, ?, ?, ?, ? )
        ]], {
            self.id,
            characterAppearance.overridePedModel, characterAppearance.overridePedIsMale, characterAppearance.equippedOutfitId,
            characterAppearance.hairApparatusId or 0, characterAppearance.hairApparatusStyleId or 0, characterAppearance.mustacheApparatusId or 0, 
            characterAppearance.mustacheApparatusStyleId or 0
        })

        return res
    end

    self.GetCurrentOutfit = function( this )
        local res = MySQL.single.await([[
            SELECT equippedOutfitId 
            FROM character_appearance_customizable 
            WHERE charId = ?
        ]], {
            self.id
        })

        self.outfitId = res.equippedOutfitId
        return res.equippedOutfitId
    end

    self.SetCurrentOutfit = function( this, outfitId )
        local affectedRows = MySQL.update.await('UPDATE character_appearance_customizable SET equippedOutfitId = ? WHERE charId = ?', {
            outfitId,
            self.id, 
        })

        if affectedRows then
            self.outfitId = outfitId
        end

        return affectedRows ~= nil
    end

    self.CreateCharacterOutfit = function( this, outfitData, name ) 
        local res = MySQL.insert.await([[
            INSERT INTO character_outfit 
                (charId, apparels, name)
            VALUES( ?, ?, ? )
        ]], {
            self.id,
            json.encode(outfitData),
            name
        })
        return res
    end

    self.UpdateCharacterOutfitData = function( this, outfitId, outfitData ) 
        local res = MySQL.insert.await([[
            UPDATE character_outfit 
            SET apparels = ?
            WHERE id = ?
        ]], {
            json.encode(outfitData),
            outfitId
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
            json.encode(characterAppearanceOverlays)
        })

        return res
    end

    self.SetCharacterAppearanceOverlaysCustomizable = function( this, characterAppearanceOverlays )
        local res = MySQL.insert.await([[
            INSERT INTO `character_appearance_overlays_customizable` 
                (   `charId`, 
                    `hasFacialHair`,
                    `headHairStyle`,
                    `headHairOpacity`,
                    `foundationColor`,
                    `foundationOpacity`,
                    `lipstickColor`,
                    `lipstickOpacity`,
                    `facePaintColor`,
                    `facePaintOpacity`,
                    `eyeshadowColor`,
                    `eyeshadowOpacity`,
                    `eyelinerColor`,
                    `eyelinerOpacity`,
                    `eyebrowsStyle`,
                    `eyebrowsColor`,
                    `eyebrowsOpacity`,
                    `blusherStyle`,
                    `blusherColor`,
                    `blusherOpacity` )
            VALUES( ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ? )
        ]], {
            self.id,
            characterAppearanceOverlays?.hasFacialHair or 0,
            characterAppearanceOverlays?.headHairStyle or 0,
            characterAppearanceOverlays?.headHairOpacity or 0,
            characterAppearanceOverlays?.foundationColor or 0,
            characterAppearanceOverlays?.foundationOpacity or 0,
            characterAppearanceOverlays?.lipstickColor or 0,
            characterAppearanceOverlays?.lipstickOpacity or 0,
            characterAppearanceOverlays?.facePaintColor or 0,
            characterAppearanceOverlays?.facePaintOpacity or 0,
            characterAppearanceOverlays?.eyeshadowColor or 0,
            characterAppearanceOverlays?.eyeshadowOpacity or 0,
            characterAppearanceOverlays?.eyelinerColor or 0,
            characterAppearanceOverlays?.eyelinerOpacity or 0,
            characterAppearanceOverlays?.eyebrowsStyle or 0,
            characterAppearanceOverlays?.eyebrowsColor or 0,
            characterAppearanceOverlays?.eyebrowsOpacity or 0,
            characterAppearanceOverlays?.blusherStyle or 0,
            characterAppearanceOverlays?.blusherColor or 0,
            characterAppearanceOverlays?.blusherOpacity or 0,
        })

        return res
    end

    self.SetCharacterExpessions = function( this, expressions )
        local res = MySQL.insert.await([[
            INSERT INTO character_appearance 
                (charId, expressions)
            VALUES( ?, ? )
        ]], {
            self.id,
            json.encode(expressions)
        })

        return res
    end

    self.SetCharacterWhistle = function(this, whistle)
        local whistleShape, whistlePitch, whistleClarity = table.unpack( whistle )
    end

    self.Release = function(this)
        TriggerEvent("FRP:ReleaseCharacter", self.source)
    end

    self.GetAppearance = function(this)
        local characterData = {}

        -- Adiciona os resultados de cada tabela ao objeto characterData
        characterData.appearance = MySQL.single.await("SELECT * FROM character_appearance WHERE charId = ?", { char.id })
        characterData.appearanceCustomizable = MySQL.single.await("SELECT * FROM character_appearance_customizable WHERE charId = ?", { char.id })
        characterData.appearanceOverlays = MySQL.single.await("SELECT * FROM character_appearance_overlays WHERE charId = ?", { char.id })
        characterData.appearanceOverlaysCustomizable = MySQL.single.await("SELECT * FROM character_appearance_overlays_customizable WHERE charId = ?", { char.id })
    
        local outfitRes = MySQL.single.await("SELECT * FROM character_outfit WHERE id = ?", { characterData.appearanceCustomizable.equippedOutfitId })
        
        if outfitRes then
            characterData.appearanceCustomizable.equippedOutfitApparels = json.decode(outfitRes.apparels)
        end
        
        characterData.appearanceOverlays.data =  json.decode(characterData.appearanceOverlays.data)
        characterData.appearance.expressions = json.decode(characterData.appearance.expressions)

        return characterData
    end

    self.SetGameAppearance = function(this)
        local data = self:GetAppearance()
        cAPI.ApplyCharacterAppearance(self.source, data)
    end

	-- Session variables, handy for temporary variables attached to a player
	self.SetSessionVar = function(this, key, value)
		self.session[key] = value
	end

	-- Session variables, handy for temporary variables attached to a player
	self.GetSessionVar = function(this, k)
		return self.session[k]
	end

    return self
end
