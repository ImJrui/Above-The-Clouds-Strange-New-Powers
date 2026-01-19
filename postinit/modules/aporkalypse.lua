local AddComponentPostInit = AddComponentPostInit
local GetModConfigData = GetModConfigData
GLOBAL.setfenv(1, GLOBAL)

TUNING.APORKALYPSE_PERIOD_LENGTH = GetModConfigData("APORKALYPSE_PERIOD_LENGTH") * TUNING.TOTAL_DAY_TIME
