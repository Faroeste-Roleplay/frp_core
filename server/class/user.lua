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
    self.CharId = nil
    self.ipAddress = ipAddress or "0.0.0.0"
    self.numMaxSlots = 1
    self.name = "Unknown"
    self.identifiers = identifiers or MapIdentifiers( GetPlayerIdentifiers(self.source) )
    self.primaryIdentifier = nil
    self.groups = {}
    self.createdAt = nil

    self.loggedIn = nil
    self.isNewbie = false

    self.Initialize = function(this)
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

        self.createdAt = res.createdAt / 1000

        self.numMaxSlots = res?.numCharSlots or Config.DefaultCharsSlotsAmount

        TriggerEvent("FRP:onUserStarted", self)

        local daysAtCreation, hoursAtCreation = self:sinceCreation()
        
        self.isNewbie = daysAtCreation <= 7
        self.isSteakFresh = hoursAtCreation <= 3

        Player(self.source).state:set('isNewbie', self.isNewbie, true)
        Player(self.source).state:set('isSteakFresh', self.isSteakFresh, true)

        self:UpdateName( GetPlayerName(self.source) )
    end

    self.UpdateName = function( this, name )
        self.name = name
        -- API_Database.query("FRP/SetUsername", {id = self.id, name = name})
    end

    -- @return The source or player server id
    self.GetSource = function(this)
        return self.source
    end

    -- @return The user name
    self.GetName = function(this)
        return self.name
    end

    -- @return the userId
    self.GetId = function(this)
        return self.id
    end

    self.GetCharacterId = function(this)
        return self.CharId
        -- local Character = self:GetCharacter()
        -- if not Character then
        --     return
        -- end

        -- return Character:GetId()
    end

    self.GetMaxCharSlotsAvailable = function(this)
        return self.numMaxSlots
    end

    self.UpdateMaxCharSlots = function( this, slots )

        local affectedRows = MySQL.update.await([[
            UPDATE `user` 
            SET `numCharSlots` = ? 
            WHERE `id` = ?
        ]], {   
            slots,
            self.id,
        })

        if affectedRows ~= nil then
            self.numMaxSlots = slots
        end
    
    end

    self.GetIpAddress = function(this)
        return ipAddress
    end

    self.GetIdentifiers = function(this)
        local num = GetNumPlayerIdentifiers(self.source)

        local identifiers = {}
        for i = 1, num do
            table.insert(identifiers, GetPlayerIdentifier(self.source, i))
        end

        return identifiers
    end

    self.GetCharacters = function(this)
        local rows = API_Database.query("FRP/GetCharacters", {userId = self.id})

        if #rows > 0 then
            return rows
        end

        return false
    end

    self.GetCharactersAppearance = function(this)
        local rows = API_Database.query("FRP/GetCharacters", {userId = self.id})
        local resData = {}

        if #rows <= 0 then
            return resData
        end

        for _, char in pairs(rows) do 
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
            resData[_] = characterData
        end

        return resData
    end

    self.CreateCharacter = function(this, firstName, lastName, birthDate, playerProfileCreation, equippedApparelsByType, metadata)
        local Character = nil

        if not metadata then
            metadata = { }
        end

        metadata.fingerprint = API.GenerateCharFingerPrint()

        local citizenId = API.CreateCitizenId()

        local rows = API_Database.query("FRP/CreateCharacter", {
            userId = self:GetId(),
            citizenId = citizenId,
            firstName = firstName,
            lastName = lastName,
            birthDate = birthDate,
            metaData = json.encode(metadata)
        })

        local charId = rows?.insertId

        if rows.affectedRows == 1 and rows.insertId then

            Character = API.Character(
                charId,
                citizenId,
                firstName,
                lastName,
                birthDate,
                metadata,
                nil, 
                'Alive',
                nil
            )

            MySQL.insert.await([[
                INSERT INTO character_inventory 
                    (charId)
                VALUES( ? )
            ]], {
                charId,
            })
            -- playerProfileCreation.components.expressions = playerProfileCreation.faceFeatures
            Character:SetCharacterAppearance(   playerProfileCreation.components    )
            Character:SetCharacterAppearanceCustomizable(    playerProfileCreation.componentsCustomizable    )
            Character:SetCharacterAppearanceOverlays(    playerProfileCreation.overlays    )
            Character:SetCharacterAppearanceOverlaysCustomizable(    playerProfileCreation.overlaysCustomizable    )

            if equippedApparelsByType then
                local outfitId = Character:CreateCharacterOutfit( equippedApparelsByType, i18n.translate("initial"))
                if outfitId then
                    Character:SetCurrentOutfit(outfitId)
                end
            end

            API_Database.execute("FRP/CreateCharStatus", {
                charId = charId,

                hunger = 100,
                thirst = 100,
                health = 200,
                health_core = 100,
                stamina = 200,
                stamina_core = 100,
                drunk = 0,
                fatigue = 100,
                drugs = 0,
                sick = 0,
            })
        end
        
        lib.logger(self.source, 'User', ("Criou Personagem (%s): %s %s"):format(self.userId, firstName, lastName))

        return charId
    end

    self.DeleteCharacter = function(this, id)
        API_Database.execute("FRP/DeleteCharacter", {charId = id, userId = self.id})
    end

    self.SetCharacter = function(this, id)
        local charRow = API_Database.query("FRP/GetCharacter", {charId = id})

        if #charRow > 0 then
            API.chars[id] = self:GetId()

            local charData = charRow[1]

            self.Character = API.Character(
                id,
                charData.citizenId,
                charData.firstName,
                charData.lastName,
                charData.birthDate,
                charData.metaData,
                charData.favoriteReserveType, 
                charData.deathState,
                charData.favouriteHorseTransportId
            )

            local memberDiscordId = self.identifiers['discord']

            -- API.GetDiscordMemberName( memberDiscordId )

            API.DefineDiscordMemberName( memberDiscordId, ("#%s - %s %s"):format(self.id, charData.firstName, charData.lastName) )
            API.DefineDiscordMemberRole( memberDiscordId, Config.LoggedInDiscordRole )

            self.Character:Initialize(self.id, self.source)
            TriggerEvent("FRP:onCharacterLoaded", self, id)
            TriggerClientEvent("FRP:onCharacterLoaded", self.source, id)
            cAPI.SetCharacterId(self:GetSource(), id)

            API.citizen[charData.citizenId] = self:GetId()
            self.CharId = id

            self.loggedIn = os.time(os.date("*t"))
            Player(self.source).state:set('loggedIn', os.time(), true)

            
            local isStaff = API.IsPlayerAceAllowedGroup( self.source, 'staff' )
            Player(playerId).state:set('staff', isStaff, true)
            
            lib.logger(self.source, 'User', ("Logou - %s[%s] : %s %s"):format(self.userId, self.name, charData.firstName, charData.lastName))

            return self.Character
        end
    end

    self.GetCharacter = function(this)
        return self.Character
    end

    self.DrawCharacter = function(this, newPosition)
        local Character = self:GetCharacter()

        -- local character_model = Character:GetModel()

        local characters_appearence =  {}-- Character:GetCharacterAppearence()

        --local character_clothing = Character:GetClothes()

        local character_lastposition = Character:GetLastPosition()

        -- local character_stats = Character:GetCachedStats()

        if characters_appearence ~= nil then
            cAPI.Initialize(self:GetSource(), character_model, newPosition or character_lastposition, Character:GetMetadata())
        end

        -- cAPI.CWanted(Character:GetWanted())
    end

    self.Notify = function(this, type, text, quantity)
        -- Notify(self:GetSource(), v)
        if type ~= nil and text == nil and quantity == nil then
            text = type
            type = "dev"
        end

        TriggerClientEvent("FRP:TOAST:New", self:GetSource(), type, text, quantity)
    end

    self.Logout = function(this)
        local character = self.Character

        if character then
            character:Release()
    
            API.citizen[character.citizenId] = nil
            API.chars[character.id] = nil
        end

        if self.loggedIn then
            local sessionTime, sessionTimeInMillisec = self:calculeSessionTime()
            self:UpdatePlayedTime(sessionTimeInMillisec)

            self.loggedIn = nil
        end
        
        local memberDiscordId = self.identifiers['discord']

        API.DefineDiscordMemberName( memberDiscordId )
        API.RemoveDiscordMemberRole( memberDiscordId, Config.LoggedInDiscordRole )

        self.Character = nil
        TriggerClientEvent("FRP:onCharacterLogout", self.source, self.CharId)
        TriggerEvent("FRP:onCharacterLogout", self, self.CharId)
    end

    self.UpdatePlayedTime = function(this, playedTime)
        local query = "UPDATE user SET sessionDuration = IFNULL(SEC_TO_TIME(TIME_TO_SEC(sessionDuration) + SEC_TO_TIME(@tempo)), '00:00:00') WHERE id = @id"
        local params = {
            ['@tempo'] = playedTime,
            ['@id'] = self.id
        }
        
        MySQL.execute(query, params)
    end

    self.Drop = function(this, reason)
        local currentPosition = GetEntityCoords( GetPlayerPed( self.source ))

        DropPlayer(self.source, reason)

        cAPI.ForceLightningFlashAtCoords( -1, currentPosition.x, currentPosition.y, currentPosition.z + 10 )

        print(#GetPlayers() .. "/".. GetConvarInt('sv_maxclients', 32) .."| " .. self.name .. " (" .. self.ipAddress .. ") desconectou (motivo = " .. reason .. ")")
    end
    
    self.GetGroups = function(this)
        return self.groups
    end

    self.GetGroupByName = function(this, groupName)
        for _, group in ipairs(self.groups) do 
            if group.name == groupName then
                return self.groups[_]
            end
        end
    end

    self.HasGroup = function(this, groupName)
        for _, group in ipairs(self.groups) do 
            if group.name == groupName then
                return true
            end
        end

        return false
    end

    self.JoinGroup = function(this, group, addPrincipal)
        local groupName = group:GetName()
        
        if self:HasGroup(groupName) then
            return false
        end

        table.insert(self.groups, { name = groupName, id = group:GetId() })

        if addPrincipal then
            local playerPrincipal = string.format('player.%s', self.source)
            ACL.AddPrincipal(playerPrincipal, group:GetPrincipal())
        end

        TriggerClientEvent("FRP:JoinedGroup", self.source, groupName)
        TriggerEvent("FRP:JoinedGroup", self.source, groupName)
    end

    self.LeaveGroup = function(this, group)
        local groupName = group:GetName()

        if not self:HasGroup(groupName) then
            return false
        end

        for idx, gpName in pairs(self.groups) do 
            if gpName == groupName then
                table.remove(self.groups, groupName)
            end
        end

        local playerPrincipal = string.format('player.%s', self.source)
        ACL.RemovePrincipal(playerPrincipal, group:GetPrincipal())

        TriggerClientEvent("FRP:LeftGroup", self.source, groupName)
        TriggerEvent("FRP:LeftGroup", self.source, groupName)
    end

    self.SetGroupFlagState = function(this, group, flag, enabled) 
        local groupName = group:GetName()
        local flags = self:GetGroupByName( groupName )?.flags;

        if not flags then
            return false
        end

        if enabled then 
            for _, fg in ipairs(flags) do 
                if fg == flag then
                    return false
                end
            end
            table.insert(flags, flag)
        else
            for _, fg in ipairs(flags) do 
                if fg == flag then
                    table.remove(flags, _)
                    goto nextStep 
                end
            end
            return false
        end

        ::nextStep::

        local playerId = self.source
        local flagAce = group:GetAceForFlag(flag)
        local playerPrincipal = string.format("player.%s", playerId)

        if enabled then
            ACL.AddAce(playerPrincipal, flagAce, true)
        else
            ACL.RemoveAce(playerPrincipal, flagAce, true)
        end

        TriggerClientEvent("FRP:onGroupFlagsChanged", playerId, groupName, flag, enabled)
        TriggerEvent("FRP:onGroupFlagsChanged", playerId, groupName, flag, enabled)
    
        return true
    end

    self.SetGroupFlagEnabled = function(this, group, flag)
        return self:SetGroupFlagState(group, flag, true)
    end

    self.SetGroupFlagDisabled = function(this, group, flag)
        return self:SetGroupFlagState(group, flag, false)
    end

    self.GetEnabledGroupFlags = function(this, group, flag)
        local groupName = group:GetName();

        for _, group in pairs(self.groups) do 
            if group.name == groupName then
                return group?.flags or {}
            end
        end

        return {}
    end

    self.calculeSessionTime = function(this)
        local date = os.date("*t")
        local tempoAtual = os.time(date) -- Timestamp atual
        local tempoDeSessao = tempoAtual - self.loggedIn  -- Tempo jogado em segundos
    
        -- Converte segundos para o formato TIME
        local horas = math.floor(tempoDeSessao / 3600)
        local minutos = math.floor((tempoDeSessao % 3600) / 60)
        local segundos = tempoDeSessao % 60
    
        -- Formata como "HH:MM:SS"
        return string.format("%02d:%02d:%02d", horas, minutos, segundos), tempoDeSessao
    end

    self.sinceCreation = function(this)
        local createdAt = self.createdAt

        -- Converter 'createdAt' para timestamp, se for uma string
        if type(createdAt) == "string" then
            local pattern = "(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)"
            local year, month, day, hour, min, sec = createdAt:match(pattern)
            createdAt = os.time({year = year, month = month, day = day, hour = hour, min = min, sec = sec})
        end
    
        -- Obter o timestamp atual
        local date = os.date("*t")
        local currentTime = os.time(date)
    
        -- Calcular a diferença em segundos
        local diffInSeconds = currentTime - createdAt
    
        -- Converter segundos para dias
        local diffInDays = math.floor(diffInSeconds / (24 * 60 * 60))
        local diffInHours = math.floor(diffInSeconds / (60 * 60))
    
        return diffInDays, diffInHours
    end

    return self
end
