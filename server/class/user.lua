-- User Object
-- Inherits: ?
--

-- IsPrincipalAceAllowed('identifier.aaa', 'group.admin')
-- (IsPlayerAceAllowed(player.id, `group.${groupName}`) as number | boolean) == 1; 


function API.User(playerId, id, ipAddress, identifiers)
    local self = {}

    self.source = playerId
    self.id = id
    self.Character = nil
    self.ipAddress = ipAddress or "0.0.0.0"
    self.numMaxSlots = 1
    self.name = "Unknown"
    self.identifiers = identifiers or MapIdentifiers( GetPlayerIdentifiers(self.source) )
    self.primaryIdentifier = nil

    self.initialize = function()
        local mappedIdentifiers =  self.identifiers
        self.primaryIdentifier = mappedIdentifiers[Config.PrimaryIdentifier]

        API.sources[self.source] = self.id
        API.identifiers[self.primaryIdentifier] = mappedIdentifiers

        self.identifiers = mappedIdentifiers

        local res = MySQL.single.await([[
            SELECT * 
            FROM user 
            WHERE id = ?
        ]], {
            self.id
        })

        self.numMaxSlots = res.numCharSlots
    end

    self.userLoadded = function(this)
        self:updateName( GetPlayerName(self.source) )
    end

    self.updateName = function( this, name )
        self.name = name
        API_Database.query("FRP/SetUsername", {id = self.id, name = name})
    end

    -- @return The source or player server id
    self.getSource = function()
        return self.source
    end

    -- @return the userId
    self.getId = function()
        return self.id
    end

    self.getIpAddress = function()
        return ipAddress
    end

    self.getIdentifiers = function()
        local num = GetNumPlayerIdentifiers(self.source)

        local identifiers = {}
        for i = 1, num do
            table.insert(identifiers, GetPlayerIdentifier(self.source, i))
        end

        return identifiers
    end

    self.getCharacters = function()
        local rows = API_Database.query("FRP/GetCharacters", {userId = self.id})

        if #rows > 0 then
            return rows
        end

        return false
    end

    self.createCharacter = function(this, firstName, lastName, birthDate, playerProfileCreation)
        local Character = nil

        local metaData = { position = Config.DefaultSpawnPosition }

        local rows = API_Database.query("FRP/CreateCharacter", {
            userId = self:getId(),
            firstName = firstName,
            lastName = lastName,
            -- birthDate = birthDate,
            metaData = json.encode(metaData)
        })

        local charId = rows?.insertId

        if rows.affectedRows == 1 and rows.insertId then

            Character = API.Character(
                charId,
                firstName,
                lastName,
                birthDate,
                metaData,
                nil, 
                'Alive'
            )

            MySQL.insert.await([[
                INSERT INTO character_inventory 
                    (charId)
                VALUES( ? )
            ]], {
                charId,
            })
            playerProfileCreation.components.expressions = playerProfileCreation.faceFeatures
            Character:setCharacterAppearance(   playerProfileCreation.components    )
            Character:setCharacterAppearanceCustomizable(    playerProfileCreation.componentsCustomizable    )
            Character:setCharacterAppearanceOverlays(    playerProfileCreation.overlays    )
            
            API_Database.execute("FRP/CreateCharStatus", {
                charId = charId,
                statHunger = 0,
                statThirst = 0,
                statHealth = 200,
                statHealthCore = 100,
                statStamina = 200,
                statStaminaCore = 100,
                statDrunk = 0,
                statStress = 0,
                statDrugs = 0,
            })
        end

        return charId
    end

    self.deleteCharacter = function(this, id)
        API_Database.execute("FRP/DeleteCharacter", {charId = id})
    end

    self.setCharacter = function(this, id)
        local charRow = API_Database.query("FRP/GetCharacter", {charId = id})

        if #charRow > 0 then
            API.chars[id] = self:getId()

            local charData = charRow[1]

            self.Character = API.Character(
                id,
                charData.firstName,
                charData.lastName,
                charData.birthDate,
                charData.metaData,
                charData.favoriteReserveType, 
                charData.deathState
            )

            self.Character:initialize(self.id, self.source)
            TriggerEvent("API:OnUserSelectCharacter", self, id)

            return self.Character
        end
    end

    -- getCharacter()
    --
    -- @return Character Object of the actual selected character

    self.getCharacter = function()
        return self.Character
    end

    self.saveCharacter = function()
        -- if self.Character ~= nil then
        --     self.Character:savePosition(Character:getLastPosition())
        -- end
    end

    self.drawCharacter = function()
        local Character = self:getCharacter()

        -- local character_model = Character:getModel()

        local characters_appearence =  {}-- Character:getCharacterAppearence()

        --local character_clothing = Character:getClothes()

        local character_lastposition = Character:getLastPosition()

        -- local character_stats = Character:getCachedStats()

        if characters_appearence ~= nil then
            cAPI.Initialize(self:getSource(), character_model, characters_appearence, character_lastposition, character_stats)
        end

        -- cAPI.CWanted(Character:getWanted())
    end

    self.disconnect = function(this, reason)
        DropPlayer(self:getSource(), reason)
    end

    self.notify = function(this, type, text, quantity)
        -- Notify(self:getSource(), v)
        if type ~= nil and text == nil and quantity == nil then
            text = type
            type = "dev"
        end

        TriggerClientEvent("FRP:TOAST:New", self:getSource(), type, text, quantity)
    end

    self.Logout = function()
        self.Character:release()
        self.Character = nil
        TriggerClientEvent("API:UserLogout", self.source)
    end
    
    self.save = function()
        
    end

    self.drop = function(reason)
        User:clearCache()

        DropPlayer(self.source, reason)

        print(#GetPlayers() .. "/".. GetConvarInt('sv_maxclients', 32) .."| " .. self.name .. " (" .. self.ipAddress .. ") desconectou (motivo = " .. reason .. ")")
    end

    self.clearCache = function() 
        TriggerClientEvent("FRP:_CORE:SetServerIdAsUserId", -1, self.source, nil)

        API.sources[self.source] = nil
        API.users[self.id] = nil
        API.identifiers[self.primaryIdentifier] = nil

        self = nil
    end

    return self
end
