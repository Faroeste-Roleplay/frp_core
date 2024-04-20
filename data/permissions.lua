config_file_GROUPS = {
    -- ["none"] = 0,        -- 0
    ["admin"] =     1 << 0, -- 1
    ["moderator"] = 1 << 1, -- 2
    ["sheriff"] =   1 << 2, -- 4
    ["trooper"] =   1 << 3, -- 8
    ["medic"] =     1 << 4, -- 16
}

config_file_INHERITANCE = {
    ["admin"] = "moderator",
    ["sheriff"] = "trooper"
}