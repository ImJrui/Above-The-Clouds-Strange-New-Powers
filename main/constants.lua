local GetModConfigData = GetModConfigData
GLOBAL.setfenv(1, GLOBAL)

local function GetCfg(newkey, oldkey)
    local v = GetModConfigData(newkey)
    if v ~= nil then
        return v
    end
    return GetModConfigData(oldkey)
end

PL_CONFIG = {
    PUGALISK_HP_MULTIPLIER = GetCfg("PUGALISK_HP_MULTIPLIER", "rate_pugalisk_health"),
    ANCIENT_HERALD_HP_MULTIPLIER = GetCfg("ANCIENT_HERALD_HP_MULTIPLIER", "rate_ancient_herald_health"),
    ANCIENT_HULK_HP_MULTIPLIER = GetCfg("ANCIENT_HULK_HP_MULTIPLIER", "rate_ancient_hulk_health"),
    ANTQUEEN_HP_MULTIPLIER = GetCfg("ANTQUEEN_HP_MULTIPLIER", "rate_antqueen_health"),
    ENABLE_SKILLTREE = GetCfg("ENABLE_SKILLTREE", "EnableSkilltree"),
    ENABLE_TERRARIUM = GetCfg("ENABLE_TERRARIUM", "Terrarium"),
    ENABLE_TOUCHSTONE = GetCfg("ENABLE_TOUCHSTONE", "TouchStone"),
    ENABLE_CRITTERLAB = GetCfg("ENABLE_CRITTERLAB", "Critterlab"),
    APORKALYPSE_PERIOD_LENGTH = GetCfg("APORKALYPSE_PERIOD_LENGTH", "AporkalypsePeriod"),
    ENABLE_SKYWORTHY = GetCfg("ENABLE_SKYWORTHY", "EnableSkyworthy"),
}

PL_WORLDTYPE = { -- 键对应它们的levels.location的大写，值对应世界tag的大写
    FOREST = "FOREST",
    CAVE = "CAVE",
    SHIPWRECKED = "ISLAND",
    VOLCANOWORLD = "VOLCANO",
    PORKLAND = "PORKLAND",
    UNKNOWN = "UNKNOWN",
}

PL_WORLD_SEASONS = {
    temperate = "autumn",
    humid = "spring",
    lush = "summer",
}


