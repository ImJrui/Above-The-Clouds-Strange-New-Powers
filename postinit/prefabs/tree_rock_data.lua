GLOBAL.setfenv(1, GLOBAL)

local TREE_ROCK_DATA = require("prefabs/tree_rock_data")

local WEIGHTED_VINE_LOOT = TREE_ROCK_DATA.WEIGHTED_VINE_LOOT
local VINE_LOOT_DATA = TREE_ROCK_DATA.VINE_LOOT_DATA
local TASKS_TO_LOOT_KEY = TREE_ROCK_DATA.TASKS_TO_LOOT_KEY
local ROOMS_TO_LOOT_KEY = TREE_ROCK_DATA.ROOMS_TO_LOOT_KEY
local STATIC_LAYOUTS_TO_LOOT_KEY = TREE_ROCK_DATA.STATIC_LAYOUTS_TO_LOOT_KEY
local EXTRA_LOOT_MODIFIERS = TREE_ROCK_DATA.EXTRA_LOOT_MODIFIERS
local AREA_MODIFIER_FNS = TREE_ROCK_DATA.AREA_MODIFIER_FNS

-- 雨林外面 (总权重 100)
WEIGHTED_VINE_LOOT["WILD_RAINFOREST"] = {
    ["weevole_carapace"]   = 15,    -- 15.00%
    ["lightbulb"]          = 10,    -- 10.00%
    ["rocks"]              = 25,    -- 25.00%
    ["flint"]              = 25,    -- 25.00%
    ["poop"]               = 20,    -- 20.00%
    ["boneshard"]          = 5,     --  5.00%
}

-- 雨林深处 (总权重 85)
WEIGHTED_VINE_LOOT["DEEP_RAINFOREST"] = {
    ["silk"]               = 5,     --  5.88%
    ["venus_stalk"]        = 5,     --  5.88%
    ["lightbulb"]          = 10,    -- 11.76%
    ["boneshard"]          = 5,     --  5.88%
    ["rocks"]              = 30,    -- 35.29%
    ["flint"]              = 30,    -- 35.29%
}

-- 彩绘沙地群系 (总权重 100)
WEIGHTED_VINE_LOOT["PAINTED_SANDS"] = {
    ["goldnugget"]         = 5,     --  5.00%
    ["iron"]               = 10,    -- 10.00%
    ["rocks"]              = 20,    -- 20.00%
    ["nitre"]              = 15,    -- 15.00%
    ["flint"]              = 20,    -- 20.00%
    ["charcoal"]           = 20,    -- 20.00%
    ["poop"]               = 10,    -- 10.00%
}

-- 平原群系（黄色地皮+爪棕榈树） (总权重 105)
WEIGHTED_VINE_LOOT["PLAINS"] = {
    ["weevole_carapace"]   = 25,    -- 23.81%
    ["poop"]               = 25,    -- 23.81%
    ["rocks"]              = 25,    -- 23.81%
    ["flint"]              = 25,    -- 23.81%
    ["boneshard"]          = 5,     --  4.76%
}

-- 城镇 (总权重 99)
WEIGHTED_VINE_LOOT["PIGTOPIA"] = {
    ["oinc"]               = 20,    -- 20.20%
    ["oinc10"]             = 5,     --  5.05%
    ["oinc100"]            = 1,     --  1.01%
    ["pigskin"]            = 3,     --  3.03%
    ["poop"]               = 30,    -- 30.30%
    ["rocks"]              = 20,    -- 20.20%
    ["flint"]              = 20,    -- 20.20%
}

-- 城市外围 (总权重 97)
WEIGHTED_VINE_LOOT["EDGE_OF_PIGTOPIA"] = {
    ["pigskin"]            = 2,     --  2.06%
    ["poop"]               = 30,    -- 30.93%
    ["rocks"]              = 30,    -- 30.93%
    ["flint"]              = 30,    -- 30.93%
    ["boneshard"]          = 5,     --  5.15%
}

-- 混合地形 （起始出生地，有平原、浅雨林、彩绘沙等） (总权重 138)
WEIGHTED_VINE_LOOT["MIXED_TERRAIN"] = {
    ["weevole_carapace"]   = 15,    -- 10.87%
    ["poop"]               = 20,    -- 14.49%
    ["boneshard"]          = 5,     --  3.62%
    ["goldnugget"]         = 3,     --  2.17%
    ["iron"]               = 5,     --  3.62%
    ["rocks"]              = 30,    -- 21.74%
    ["nitre"]              = 15,    -- 10.87%
    ["flint"]              = 30,    -- 21.74%
    ["charcoal"]           = 15,    -- 10.87%
}

-- BFB (总权重 75.25)
WEIGHTED_VINE_LOOT["PINCALE"] = {
    ["rocks"]              = 25,    -- 33.23%
    ["nitre"]              = 20,    -- 26.58%
    ["flint"]              = 25,    -- 33.23%
    ["redgem"]             = 1.75,  --  2.33%
    ["bluegem"]            = 1.75,  --  2.33%
    ["purplegem"]          = 1.75,  --  2.33%
}

-- 不老泉 (总权重 71)
WEIGHTED_VINE_LOOT["PUGALISK_FOUNTAIN"] = {
    ["weevole_carapace"]   = 15,    -- 21.13%
    ["rocks"]              = 15,    -- 21.13%
    ["flint"]              = 15,    -- 21.13%
    ["poop"]               = 10,    -- 14.08%
    ["boneshard"]          = 10,    -- 14.08%
    ["redgem"]             = 3,     --  4.23%
    ["bluegem"]            = 3,     --  4.23%
}

local TASKS = {
    -- 【一岛(主岛)】 锁 LOCKS.JUNGLE_DEPTH_1 / CIVILIZATION_1 / 2 / ISLAND_2
    ["Edge_of_the_unknown"]         = "MIXED_TERRAIN",               -- → 未知边缘群系 ✓
    ["Edge_of_the_unknown_2"]       = "MIXED_TERRAIN",               -- → 未知边缘二群系 ✓
    ["painted_sands"]               = "PAINTED_SANDS",               -- → 彩绘沙地群系 ✓
    ["plains"]                      = "PLAINS",                      -- → 平原群系 ✓
    ["rainforests"]                 = "WILD_RAINFOREST",             -- → 雨林群系 ✓
    ["rainforest_ruins"]            = "WILD_RAINFOREST",             -- → 雨林遗迹群系 ✓
    ["plains_ruins"]                = "PLAINS",                      -- → 平原遗迹群系 ✓
    ["Edge_of_civilization"]        = "EDGE_OF_PIGTOPIA",            -- → 耕地群系 ✓
    ["Pigtopia"]                    = "PIGTOPIA",                    -- → 猪伯利镇 ✓(对应 wiki 一项)
    ["Pigtopia_capital"]            = "PIGTOPIA",                    -- ✗ wiki 未列(一岛首都,锁 CIVILIZATION_2)
    ["Deep_rainforest"]             = "WILD_RAINFOREST",             -- ✗ wiki 未列(茂密雨林群系,与 Edge_of_civilization 同锁)
    ["Deep_rainforest_2"]           = "WILD_RAINFOREST",             -- → 茂密雨林二群系 ✓
    ["Deep_lost_ruins_gas"]         = "WILD_RAINFOREST",             -- → 毒气雨林群系 ✓
    ["Lost_Ruins_1"]                = "DEEP_RAINFOREST",             -- → 失落遗迹群系 ✓
    ["this_is_how_you_get_ants"]    = "DEEP_RAINFOREST",             -- → 蚁人雨林群系 ✓
    -- ["Lilypond_land"]            = "",                            -- → 莲花池群系 ✓
    -- ["Lilypond_land_2"]          = "",                            -- → 莲花池二群系 ✓
    -- ["Land_Divide_1"]            = "",                            -- ✗ 一/二岛分隔桥,wiki 未列

    -- 【二岛(皇室岛)】 锁 LOCKS.LAND_DIVIDE_1 / OTHER_JUNGLE_DEPTH_1 / 2
    ["Deep_rainforest_3"]           = "DEEP_RAINFOREST",             -- → 茂密雨林三群系 ✓
    ["Deep_rainforest_mandrake"]    = "DEEP_RAINFOREST",             -- → 曼德拉茂密雨林群系 ✓
    ["Path_to_the_others"]          = "MIXED_TERRAIN",               -- → 二岛通道群系 ✓
    ["Other_edge_of_civilization"]  = "EDGE_OF_PIGTOPIA",            -- → 二岛耕地群系 ✓
    ["Other_pigtopia"]              = "PIGTOPIA",                    -- ✗ 二岛猪城,wiki 未列
    ["Other_pigtopia_capital"]      = "PIGTOPIA",                    -- → 女王城 ✓
    -- ["Land_Divide_2"]            = "",                            -- ✗ 二/三岛分隔桥,wiki 未列

    -- 【三岛(古代岛)】 锁 LOCKS.LOST_JUNGLE_DEPTH_2
    ["Deep_lost_ruins4"]            = "DEEP_RAINFOREST",             -- → 深层失落遗迹群系 ✓
    ["lost_rainforest"]             = "PUGALISK_FOUNTAIN",             -- → 失落雨林群系 ✓
    -- ["Land_Divide_3"]            = "",                            -- ✗ 三/四岛分隔桥,wiki 未列

    -- 【四岛(顶峰岛)】 锁 LOCKS.PINACLE
    ["pincale"]                     = "PINCALE",                     -- → 峰顶群系 ✓
    -- ["Land_Divide_4"]            = "",                            -- ✗ 四/五岛分隔桥,wiki 未列

    -- 【五岛(远古岛)】 锁 LOCKS.WILD_JUNGLE_DEPTH_1 / 2
    ["Deep_wild_ruins4"]            = "DEEP_RAINFOREST",             -- → 深层狂野遗迹群系 ✓
    ["wild_rainforest"]             = "WILD_RAINFOREST",             -- → 荒野雨林群系 ✓
    ["wild_ancient_ruins"]          = "DEEP_RAINFOREST",             -- → 狂野古代遗迹群系 ✓
}

local override_symbols = {"oinc", "oinc10", "oinc100", "iron", "pigskin", "charcoal", "venus_stalk", "weevole_carapace"}
for i = 1, #override_symbols do
    VINE_LOOT_DATA[override_symbols[i]] = {build = "pl_tree_rock_swaps", symbols = {"swap_" .. override_symbols[i]}}
end

local ROOMS = {

}

local STATIC_LAYOUTS = {

}

local EXTRA_LOOT = {
    --[[
    ["WEB_CREEP"] = {
        test_fn = function(inst)
            return TheWorld.GroundCreep:OnCreep(inst.Transform:GetWorldPosition())
        end,
        loot = function(inst, currenttotalweight)
            return {
                ["silk"] = currenttotalweight * SILK_LOOT_MULTIPLIER,
            }
        end,
    },
    ]]
}

local AREA = {
    --[[
    ["VENT_AREA"] = function()
        local riftspawner = TheWorld.components.riftspawner
        if riftspawner and riftspawner:IsShadowPortalActive() then
            return "VENT_AREA_SHADOW_RIFT"
        end
    end,
    ]]
}

for k, v in pairs(TASKS) do
    TASKS_TO_LOOT_KEY[k] = v
end

for k, v in pairs(ROOMS) do
    ROOMS_TO_LOOT_KEY[k] = v
end

for k, v in pairs(STATIC_LAYOUTS) do
    STATIC_LAYOUTS_TO_LOOT_KEY[k] = v
end

for k, v in pairs(EXTRA_LOOT) do
    EXTRA_LOOT_MODIFIERS[k] = v
end

for k, v in pairs(AREA) do
    AREA_MODIFIER_FNS[k] = v
end
