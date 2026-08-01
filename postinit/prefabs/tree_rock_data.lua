local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

local TREE_ROCK_DATA = require("prefabs/tree_rock_data")

local WEIGHTED_VINE_LOOT = TREE_ROCK_DATA.WEIGHTED_VINE_LOOT
local VINE_LOOT_DATA = TREE_ROCK_DATA.VINE_LOOT_DATA
local TASKS_TO_LOOT_KEY = TREE_ROCK_DATA.TASKS_TO_LOOT_KEY
local ROOMS_TO_LOOT_KEY = TREE_ROCK_DATA.ROOMS_TO_LOOT_KEY
local STATIC_LAYOUTS_TO_LOOT_KEY = TREE_ROCK_DATA.STATIC_LAYOUTS_TO_LOOT_KEY
local EXTRA_LOOT_MODIFIERS = TREE_ROCK_DATA.EXTRA_LOOT_MODIFIERS
local AREA_MODIFIER_FNS = TREE_ROCK_DATA.AREA_MODIFIER_FNS

local CheckModifyLootArea = TREE_ROCK_DATA.CheckModifyLootArea

WEIGHTED_VINE_LOOT["BEACH_AREA"] = {
    seashell = 15,
    rocks = 10,
    flint = 8,
    nitre = 8,
    limestonenugget = 8,
    coconut = 5,
}

WEIGHTED_VINE_LOOT["SLOTMACHINE_AREA"] = {
    dubloon = 20,
    seashell = 15,
    rocks = 10,
    flint = 8,
    nitre = 8,
    limestonenugget = 8,
    coconut = 5,
}

WEIGHTED_VINE_LOOT["JUNGLE_AREA"] = {
    poop = 25,
    rocks = 10,
    flint = 8,
    goldnugget = 5,
    dubloon = 5,
    silk = 8,
    venomgland = 5,
}

WEIGHTED_VINE_LOOT["JUNGLE_SKELETON_AREA"] = {
    boneshard = 35,
    poop = 25,
    rocks = 10,
    flint = 8,
    goldnugget = 5,
    dubloon = 5,
    silk = 8,
    venomgland = 5,
}

WEIGHTED_VINE_LOOT["MAGMAROCK_AREA"] = {
    rocks = 15,
    flint = 10,
    nitre = 10,
    goldnugget = 5,
    redgem = 1,
    bluegem = 1,
}

WEIGHTED_VINE_LOOT["MAGMAROCK_TREES_AREA"] = {
    charcoal = 20,
    rocks = 15,
    flint = 10,
    nitre = 10,
    goldnugget = 5,
    redgem = 1,
    bluegem = 1,
}

WEIGHTED_VINE_LOOT["TIDALMARSH_AREA"] = {
    rocks = 10,
    flint = 5,
    venomgland = 5,
}

WEIGHTED_VINE_LOOT["VOLCANO_AREA"] = {
    rocks = 4,
    nitre = 10,
    obsidian = 5,
    dragoonheart = 1.5,
    redgem = 1,
    bluegem = 1,
    purplegem = 0.75,
    orangegem = 0.3,
    yellowgem = 0.3,
    greengem = 0.3,
}

local ROOMS = {
    BeachSand = "BEACH_AREA",
    BeachSandHome = "BEACH_AREA",
    BeachDebris = "BEACH_AREA",
    BeachUnkept = "BEACH_AREA",
    BeachUnkeptDubloon = "BEACH_AREA",
    BeachPalmForest = "BEACH_AREA",
    BeachPiggy = "BEACH_AREA",
    BeesBeach = "BEACH_AREA",
    BeachCrabTown = "BEACH_AREA",
    BeachDunes = "BEACH_AREA",
    BeachGrassy = "BEACH_AREA",
    BeachSappy = "BEACH_AREA",
    BeachRocky = "BEACH_AREA",
    BeachLimpety = "BEACH_AREA",
    BeachSpider = "BEACH_AREA",
    BeachNoFlowers = "BEACH_AREA",
    BeachNoLimpets = "BEACH_AREA",
    BeachNoCrabbits = "BEACH_AREA",
    BeachPalmCasino = "SLOTMACHINE_AREA",
    BeachShells = "BEACH_AREA",
    BeachSkull = "BEACH_AREA",
    ---
    Jungle = "JUNGLE_AREA",
    JungleSparse = "JUNGLE_AREA",
    JungleDense = "JUNGLE_AREA",
    JungleDenseHome = "JUNGLE_AREA",
    JungleDenseMed = "JUNGLE_AREA",
    JungleDenseMed_Balatro = "JUNGLE_AREA",
    JungleDenseMed_Terrarium = "JUNGLE_AREA",
    JungleDenseBerries = "JUNGLE_AREA",
    JungleDenseMedHome = "JUNGLE_AREA",
    JungleDenseVery = "JUNGLE_AREA",
    JungleFlower = "JUNGLE_AREA",
    JungleSpidersDense = "JUNGLE_AREA",
    JungleSpiderCity = "JUNGLE_AREA",
    JungleBamboozled = "JUNGLE_AREA",
    JungleMonkeyHell = "JUNGLE_AREA",
    JungleCritterCrunch = "JUNGLE_AREA",
    JungleDenseCritterCrunch = "JUNGLE_AREA",
    JungleShroomin = "JUNGLE_AREA",
    JungleRockyDrop = "JUNGLE_AREA",
    JungleEvilFlowers = "JUNGLE_AREA",
    JungleNoBerry = "JUNGLE_AREA",
    JungleNoRock = "JUNGLE_AREA",
    JungleNoMushroom = "JUNGLE_AREA",
    JungleNoFlowers = "JUNGLE_AREA",
    JungleSkeleton = "JUNGLE_SKELETON_AREA",
    ---
    Magma = "MAGMAROCK_AREA",
    BG_Magma = "MAGMAROCK_AREA",
    GenericMagmaNoThreat = "MAGMAROCK_AREA",
    MagmaSpiders = "MAGMAROCK_AREA",
    MagmaGold = "MAGMAROCK_AREA",
    MagmaGoldBoon = "MAGMAROCK_AREA",
    MagmaTallBird = "MAGMAROCK_AREA",
    MagmaForest = "MAGMAROCK_TREES_AREA",
    ---
    NoOxMeadow = "GRASS_AREA",
    MeadowBees = "GRASS_AREA",
    MeadowCarroty = "GRASS_AREA",
    MeadowMandrake = "GRASS_AREA",
    MeadowQueen = "GRASS_AREA",
    MeadowBerries = "GRASS_AREA",
    ---
    TidalMarsh = "TIDALMARSH_AREA",
    TidalMermMarsh = "TIDALMARSH_AREA",
    ToxicTidalMarsh = "TIDALMARSH_AREA",
    ---
    VolcanoAsh = "VOLCANO_AREA",
    VolcanoObsidian = "VOLCANO_AREA",
    VolcanoStart = "VOLCANO_AREA",
    VolcanoNoise = "VOLCANO_AREA",
    VolcanoObsidianBench = "VOLCANO_AREA",
    VolcanoAltar = "VOLCANO_AREA",
    VolcanoCage = "VOLCANO_AREA",
}

local override_symbols = {"iron", "pigskin", "oinc", "oinc10", "oinc100", "charcoal", "",}
for i = 1, #override_symbols do
    VINE_LOOT_DATA[override_symbols[i]] = {build = "pl_tree_rock_swaps", symbols = {"swap_" .. override_symbols[i]}}
end

for k, v in pairs(ROOMS) do
    ROOMS_TO_LOOT_KEY[k] = v
end