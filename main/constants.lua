local GetModConfigData = GetModConfigData
GLOBAL.setfenv(1, GLOBAL)

PL_CONFIG = {
    PUGALISK_HP_MULTIPLIER = GetModConfigData("PUGALISK_HP_MULTIPLIER") or GetModConfigData("rate_pugalisk_health"),
    ANCIENT_HERALD_HP_MULTIPLIER = GetModConfigData("ANCIENT_HERALD_HP_MULTIPLIER") or GetModConfigData("rate_ancient_herald_health"),
    ANCIENT_HULK_HP_MULTIPLIER = GetModConfigData("ANCIENT_HULK_HP_MULTIPLIER") or GetModConfigData("rate_ancient_hulk_health"),
    ANTQUEEN_HP_MULTIPLIER = GetModConfigData("ANTQUEEN_HP_MULTIPLIER") or GetModConfigData("rate_antqueen_health"),
    ENABLE_SKILLTREE = GetModConfigData("ENABLE_SKILLTREE") or GetModConfigData("EnableSkilltree"),
    ENABLE_TERRARIUM = GetModConfigData("ENABLE_TERRARIUM") or GetModConfigData("Terrarium"),
    ENABLE_TOUCHSTONE = GetModConfigData("ENABLE_TOUCHSTONE") or GetModConfigData("TouchStone"),
    ENABLE_CRITTERLAB = GetModConfigData("ENABLE_CRITTERLAB") or GetModConfigData("Critterlab"),
    APORKALYPSE_PERIOD_LENGTH = GetModConfigData("APORKALYPSE_PERIOD_LENGTH" or GetModConfigData("APORKALYPSE_PERIOD_LENGTH")),
    ENABLE_SKYWORTHY = GetModConfigData("ENABLE_SKYWORTHY" or GetModConfigData("EnableSkyworthy")),
}

PL_WORLDTYPE = { -- 键对应它们的levels.location的大写，值对应世界tag的大写
    FOREST = "FOREST",
    CAVE = "CAVE",
    SHIPWRECKED = "ISLAND",
    VOLCANOWORLD = "VOLCANO",
    PORKLAND = "PORKLAND",
    UNKNOWN = "UNKNOWN",
}
