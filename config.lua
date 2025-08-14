Config = {}

Config.Allowlist = true
Config.RevealMap = true
Config.SkyCamSpawnEffect = false

Config.DefaultSpawnPosition = vector3(-1099.470, -1839.129, 60.327)
Config.DisableAutoSpawn = true

Config.fivemRequired = false

Config.CoordsToIgnoreCoords = vec3(-561.3221, -5697.16, 74.108841)

-- in-game role
Config.LoggedInDiscordRole = 1359900362500346007

-- Config.DefaultFirstSpawnCoords = { -- saint denis
--     vector3(2695.72, -1444.99, 45.30),
--     vector3(2696.68, -1447.11, 45.30),
--     vector3(2698.41, -1450.62, 45.30),
--     vector3(2699.35, -1453.15, 45.30)
-- }

Config.DefaultFirstSpawnCoords = {
    vector3(-302.92, 782.45, 117.78),
    vector3(-332.32, 776.93, 116.44),
    vector3(-164.59, 634.97, 113.08),
    vector3(-171.1, 625.68, 113.08),
    vector3(-171.72, 630.57, 113.08)
}

-- [[ steam or discord or fivem]]
Config.PrimaryIdentifier = "steam"

Config.DefaultCharsSlotsAmount = 1

Config.DiscordGuildId = GetConvar("discord_guild_id", 412627639380213760)
Config.DiscordInvite = GetConvar("discord", '')

Config.EnablePlayerSelectLanguage = true