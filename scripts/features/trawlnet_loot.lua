local AddComponentPostInit = AddComponentPostInit

GLOBAL.setfenv(1, GLOBAL)

--trawling

local LOOT_DEFS = require("prefabs/trawlnet_loot_defs")
local _GetLootTable = LOOT_DEFS.GetLootTable
local LILYPOND_LOOT = LOOT_DEFS.LILYPOND_LOOT

local chance_verylow  = 1
local chance_low      = 2
local chance_medium   = 4
local chance_high     = 8

local NewLootTable = {
	{ "saltrock", chance_medium },
	{ "messagebottleempty", chance_low },
}

for _, entry in ipairs(NewLootTable) do
    table.insert(LILYPOND_LOOT, entry)
end

local WURT_COIREPLACE = {
	["coi"] = "pondcoi",
}

local WURT_LILYPOND = {}

for i = 1, #LILYPOND_LOOT do
	local repl = WURT_COIREPLACE[LILYPOND_LOOT[i][1]]
	WURT_LILYPOND[i] = LILYPOND_LOOT[i]
	if repl then WURT_LILYPOND[i][1] = repl end
end

function LOOT_DEFS.GetLootTable(inst)

	local owner = inst.components.inventoryitem.owner
    local sailor = nil

    if owner and owner.components.sailable then
        sailor = owner.components.sailable.sailor
    end
	
	if sailor ~= nil and sailor.prefab == "wurt" then return WURT_LILYPOND end
	
    return _GetLootTable(inst)
end