API_Database = {}
local API = MySQL

---------------------------------------------
---------------DATABASE SYSTEM---------------
---------------------------------------------
DBConnect = {
	driver = "oxmysql",
	host = GetConvar("db_host", "localhost"),
	database = GetConvar("db_name", "faroeste"),
	user = GetConvar("db_username", "root"),
	password = GetConvar("db_password", "")
}

local db_drivers = {}
local db_driver
local cached_prepares = {}
local cached_queries = {}
local prepared_queries = {}
local db_initialized = false

-- Função para registrar o driver de banco de dados
function API_Database.registerDBDriver(name, on_init, on_prepare, on_query)
    if db_drivers[name] then
        error("Banco de dados já registrado.")
        return
    end

    db_drivers[name] = {on_init, on_prepare, on_query}

    if name == DBConnect.driver then
        db_driver = db_drivers[name]

        local ok = on_init(DBConnect)
        if not ok then
            error("Conexão com o banco de dados falhou.")
            return
        end

        db_initialized = true
        for _, prepare in ipairs(cached_prepares) do
            on_prepare(prepare[1], prepare[2])
        end

        for _, query in ipairs(cached_queries) do
            async(function()
                query[2](on_query(query[1], query[2], query[3]))
            end)
        end

        cached_prepares = nil
        cached_queries = nil
    end
end

-- Função para formatar números
function API_Database.format(n)
    local left, num, right = string.match(n, "^([^%d]*%d)(%d*)(.-)$")
    return left .. (num:reverse():gsub("(%d%d%d)", "%1."):reverse()) .. right
end

-- Função para preparar uma query
function API_Database.prepare(name, query)
    prepared_queries[name] = true

    if db_initialized then
        db_driver[2](name, query)
    else
        table.insert(cached_prepares, {name, query})
    end
end

-- Função para realizar a query
function API_Database.query(name, params, mode)
    if not prepared_queries[name] then
        error("Query " .. name .. " não existe.")
    end

    mode = mode or "query"

    if db_initialized then
        return db_driver[3](name, params or {}, mode)
    else
        local r = async()
        table.insert(cached_queries, {{name, params or {}, mode}, r})
        return r:wait()
    end
end

-- Função para executar uma query
function API_Database.execute(name, params)
    return API_Database.query(name, params, "execute")
end

---------------------------------------------
---------------EXECUTE SYSTEM---------------
---------------------------------------------
local queries = {}

-- Função de inicialização do driver
local function on_init(cfg)
    return API ~= nil
end

-- Função de preparação da query
local function on_prepare(name, query)
    queries[name] = query
end

-- Função para executar a query no banco
local function on_query(name, params, mode)
    local query = queries[name]
    local _params = {_ = true}

    for k, v in pairs(params) do
        _params["@" .. k] = v
    end

    local r = async()

    if mode == "execute" then
        API.query(query, _params, function(affected)
            r(affected or 0)
        end)
    elseif mode == "scalar" then
        API.scalar(query, _params, function(scalar)
            r(scalar)
        end)
    else
        API.query(query, _params, function(rows)
            r(rows, #rows)
        end)
    end

    return r:wait()
end

-- Inicia a conexão e registra o driver
Citizen.CreateThread(function()
    API.query("SELECT 1")
    API_Database.registerDBDriver("oxmysql", on_init, on_prepare, on_query)
end)

----------	USER QUERIES -------------
API_Database.prepare("FRP/CreateUser", "INSERT INTO `user` (identifier, name, createdAt, banned) VALUES(@identifier, @name, @createdAt, 0)")
-- API_Database.prepare("FRP/SelectUser", "SELECT * from user WHERE identifier = @identifier")

-- API_Database.prepare("FRP/SetUsername", "UPDATE user SET name = @name, WHERE id = @userId")

-- API_Database.prepare("FRP/BannedUser", "SELECT banned from user WHERE userId = @userId")
-- API_Database.prepare("FRP/SetBanned", "UPDATE user SET banned = 1, reason = @reason WHERE userId = @userId")
-- API_Database.prepare("FRP/UnBan", 'UPDATE user SET banned = 0, reason = "" WHERE userId = @userId')
-- API_Database.prepare("FRP/Whitelisted", "SELECT whitelist from user WHERE identifier = @identifier")

-- API_Database.prepare("AddIdentifierWhitelist", "UPDATE user SET whitelist = 1 where userId = @userId")
-- API_Database.prepare("RemoveIdentifierWhitelist", "UPDATE user SET whitelist = 0 where userId = @userId")

-------- CHARACTER QUERIES -----------
API_Database.prepare("FRP/CreateCharacter", "INSERT INTO `character` (userId, citizenId, firstName, lastName, metaData) VALUES(@userId, @citizenId, @firstName, @lastName, @metaData)")
API_Database.prepare("FRP/CharacterAppearence", "INSERT INTO characters_appearence (charId, isMale, model, enabledComponents, faceFeatures, overlays, clothes, pedHeight) VALUES (@charId, @isMale, @model, '{}', '{}', '{}', '{}', 1.0)")

API_Database.prepare("FRP/CreateCharStatus", "INSERT INTO `character_rpg_stats` (charId, hunger, thirst, health, health_core, stamina, stamina_core, drunk, fatigue, drugs, sick) VALUES(@charId, @hunger, @thirst, @health, @health_core, @stamina, @stamina_core, @drunk, @fatigue, @drugs, @sick)")

API_Database.prepare("FRP/GetCharacters", "SELECT * FROM `character` WHERE `userId` = @userId")
API_Database.prepare("FRP/GetCharacter", "SELECT * FROM `character` WHERE `id` = @charId")
API_Database.prepare("FRP/GetCharacterAppearence", "SELECT * from characters_appearence WHERE id = @charId")
API_Database.prepare("FRP/DeleteCharacter", "DELETE FROM `character` WHERE id = @charId and userId = @userId")
API_Database.prepare("FRP/GetUserIdByCharId", "SELECT userId from `character` WHERE id = @charId")
API_Database.prepare("FRP/GetUserIdFromUserId", "SELECT * from `user` WHERE id = @userId")
API_Database.prepare("FRP/GetCharNameByCharId", "SELECT characterName from `character` WHERE id = @charId")
API_Database.prepare("FRP/UpdateLevel", "UPDATE `character` SET level = @level WHERE id = @charId")
API_Database.prepare("FRP/UpdateXP", "UPDATE `character` SET xp = @xp WHERE id = @charId")
API_Database.prepare("UPDATE:character_data_role", "UPDATE `character` SET groups = @role WHERE id = @charId")
API_Database.prepare("UPDATE:character_data_clothing", "UPDATE `character` SET clothes = @clothing WHERE id = @charId")


API_Database.prepare("FRP/GetCharMetadata", "SELECT `metaData` from `character` WHERE id = @charId")
API_Database.prepare("FRP/UpdateCharMetadata", "UPDATE `character` SET metaData = @metaData WHERE id = @charId")


API_Database.prepare("FRP/SetComponentsPed", "UPDATE characters_appearence SET enabledComponents = @value WHERE charId = @charId")
API_Database.prepare("FRP/SetfaceFeaturePeds", "UPDATE characters_appearence SET faceFeatures = @value WHERE charId = @charId")
API_Database.prepare("FRP/SetOverlayPeds", "UPDATE characters_appearence SET overlays = @value WHERE charId = @charId")
API_Database.prepare("FRP/SetPlayerPedModel", "UPDATE characters_appearence SET model = @model AND isMale = @isMale WHERE charId = @charId")
API_Database.prepare("FRP/SetPedHeight", "UPDATE characters_appearence SET pedHeight = @value WHERE charId = @charId")
API_Database.prepare("FRP/SetPedWeight", "UPDATE characters_appearence SET pedWeight = @value WHERE charId = @charId")

API_Database.prepare("FRP/GetCharModel", "SELECT model from characters_appearence WHERE charId = @charId")

API_Database.prepare("FRP/SetCWeaponData", "UPDATE `character` SET weapons = @weapons WHERE charId = @charId")
API_Database.prepare("FRP/SetPlayerDeath", "UPDATE `character` SET is_dead = @is_dead WHERE charId = @charId")
API_Database.prepare("FRP/GetPlayerDeath", "SELECT is_dead from `character` WHERE charId = @charId")
