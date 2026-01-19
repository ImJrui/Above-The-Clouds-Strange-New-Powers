local PLANT_DEFS = require("prefabs/farm_plant_defs").PLANT_DEFS
local FRAMES = 1/30

local function MakeGrowTimes(germination_min, germination_max, full_grow_min, full_grow_max)
	local grow_time = {}

	-- germination time
	grow_time.seed		= {germination_min, germination_max}

	-- grow time
	grow_time.sprout	= {full_grow_min * 0.5, full_grow_max * 0.5}
	grow_time.small		= {full_grow_min * 0.3, full_grow_max * 0.3}
	grow_time.med		= {full_grow_min * 0.2, full_grow_max * 0.2}

	-- harvestable perish time
	grow_time.full		= 4 * TUNING.TOTAL_DAY_TIME
	grow_time.oversized	= 6 * TUNING.TOTAL_DAY_TIME
	grow_time.regrow	= {4 * TUNING.TOTAL_DAY_TIME, 5 * TUNING.TOTAL_DAY_TIME} -- min, max

	return grow_time
end

-- moisture
local drink_low = TUNING.FARM_PLANT_DRINK_LOW
local drink_med = TUNING.FARM_PLANT_DRINK_MED
local drink_high = TUNING.FARM_PLANT_DRINK_HIGH

-- Nutrients
local S = TUNING.FARM_PLANT_CONSUME_NUTRIENT_LOW
local M = TUNING.FARM_PLANT_CONSUME_NUTRIENT_MED
local L = TUNING.FARM_PLANT_CONSUME_NUTRIENT_HIGH

------------------------------------------------
--aloe
PLANT_DEFS.aloe	= {{build = "farm_plant_mfp_aloe", bank = "farm_plant_pepper"}}
PLANT_DEFS.aloe.build = "farm_plant_mfp_aloe"
PLANT_DEFS.aloe.bank = "farm_plant_pepper"
PLANT_DEFS.aloe.prefab = "farm_plant_aloe"
PLANT_DEFS.aloe.sounds =
{
	grow_oversized = "farming/common/farm/carrot/grow_oversized",
	grow_full = "farming/common/farm/grow_full",
	grow_rot = "farming/common/farm/rot",
}
PLANT_DEFS.aloe.moisture = {drink_rate = drink_low, min_percent = TUNING.FARM_PLANT_DROUGHT_TOLERANCE}
PLANT_DEFS.aloe.good_seasons = {autumn = true, winter = true, spring = true, summer = true}
PLANT_DEFS.aloe.nutrient_consumption = {M, 0, 0}
PLANT_DEFS.aloe.nutrient_restoration = {nil, true, true}
PLANT_DEFS.aloe.max_killjoys_tolerance = TUNING.FARM_PLANT_KILLJOY_TOLERANCE
PLANT_DEFS.aloe.weight_data = { 412.34, 596.06, .27 }
PLANT_DEFS.aloe.pictureframeanim = {anim = "emoteXL_loop_dance6", time = 97*FRAMES}
PLANT_DEFS.aloe.grow_time = MakeGrowTimes(12 * TUNING.SEG_TIME, 16 * TUNING.SEG_TIME, 4 * TUNING.TOTAL_DAY_TIME, 7 * TUNING.TOTAL_DAY_TIME)
PLANT_DEFS.aloe.product = "aloe"
PLANT_DEFS.aloe.product_oversized = "aloe_oversized"
PLANT_DEFS.aloe.seed = "aloe_seeds"
PLANT_DEFS.aloe.plant_type_tag = "farm_plant_aloe"
PLANT_DEFS.aloe.loot_oversized_rot = {"spoiled_food", "spoiled_food", "spoiled_food", PLANT_DEFS.aloe.seed, "fruitfly", "fruitfly"}
PLANT_DEFS.aloe.family_min_count = TUNING.FARM_PLANT_SAME_FAMILY_MIN
PLANT_DEFS.aloe.family_check_dist = TUNING.FARM_PLANT_SAME_FAMILY_RADIUS
PLANT_DEFS.aloe.stage_netvar = net_tinybyte
PLANT_DEFS.aloe.plantregistrywidget = "widgets/redux/farmplantpage"
PLANT_DEFS.aloe.plantregistrysummarywidget = "widgets/redux/farmplantsummarywidget"
PLANT_DEFS.aloe.plantregistryinfo = {
	{
		text = "seed",
		anim = "crop_seed",
		grow_anim = "grow_seed",
		learnseed = true,
		growing = true,
	},
	{
		text = "sprout",
		anim = "crop_sprout",
		grow_anim = "grow_sprout",
		growing = true,
	},
	{
		text = "small",
		anim = "crop_small",
		grow_anim = "grow_small",
		growing = true,
	},
	{
		text = "medium",
		anim = "crop_med",
		grow_anim = "grow_med",
		growing = true,
	},
	{
		text = "grown",
		anim = "crop_full",
		grow_anim = "grow_full",
		revealplantname = true,
		fullgrown = true,
	},
	{
		text = "oversized",
		anim = "crop_oversized",
		grow_anim = "grow_oversized",
		revealplantname = true,
		fullgrown = true,
		hidden = true,
	},
	{
		text = "rotting",
		anim = "crop_rot",
		grow_anim = "grow_rot",
		stagepriority = -100,
		is_rotten = true,
		hidden = true,
	},
	{
		text = "oversized_rotting",
		anim = "crop_rot_oversized",
		grow_anim = "grow_rot_oversized",
		stagepriority = -100,
		is_rotten = true,
		hidden = true,
	},
}

------------------------------------------------
--radish
PLANT_DEFS.radish = {{build = "farm_plant_mfp_radish", bank = "farm_plant_carrot"}}
PLANT_DEFS.radish.build = "farm_plant_mfp_radish"
PLANT_DEFS.radish.bank = "farm_plant_carrot"
PLANT_DEFS.radish.prefab = "farm_plant_radish"
PLANT_DEFS.radish.sounds =
{
	grow_oversized = "farming/common/farm/carrot/grow_oversized",
	grow_full = "farming/common/farm/grow_full",
	grow_rot = "farming/common/farm/rot",
}
PLANT_DEFS.radish.moisture = {drink_rate = drink_low, min_percent = TUNING.FARM_PLANT_DROUGHT_TOLERANCE}
PLANT_DEFS.radish.good_seasons = {autumn = true, winter = true, spring = true}
PLANT_DEFS.radish.nutrient_consumption = {0, M, 0}
PLANT_DEFS.radish.nutrient_restoration = {true, nil, true}
PLANT_DEFS.radish.max_killjoys_tolerance = TUNING.FARM_PLANT_KILLJOY_TOLERANCE
PLANT_DEFS.radish.weight_data = { 371.51, 526.04, 0.39 }
PLANT_DEFS.radish.pictureframeanim = {anim = "emote_happycheer", time = 12*FRAMES}
PLANT_DEFS.radish.grow_time = MakeGrowTimes(12 * TUNING.SEG_TIME, 16 * TUNING.SEG_TIME, 4 * TUNING.TOTAL_DAY_TIME, 7 * TUNING.TOTAL_DAY_TIME)
PLANT_DEFS.radish.product = "radish"
PLANT_DEFS.radish.product_oversized = "radish_oversized"
PLANT_DEFS.radish.seed = "radish_seeds"
PLANT_DEFS.radish.plant_type_tag = "farm_plant_radish"
PLANT_DEFS.radish.loot_oversized_rot = {"spoiled_food", "spoiled_food", "spoiled_food", PLANT_DEFS.radish.seed, "fruitfly", "fruitfly"}
PLANT_DEFS.radish.family_min_count = TUNING.FARM_PLANT_SAME_FAMILY_MIN
PLANT_DEFS.radish.family_check_dist = TUNING.FARM_PLANT_SAME_FAMILY_RADIUS
PLANT_DEFS.radish.stage_netvar = net_tinybyte
PLANT_DEFS.radish.plantregistrywidget = "widgets/redux/farmplantpage"
PLANT_DEFS.radish.plantregistrysummarywidget = "widgets/redux/farmplantsummarywidget"
PLANT_DEFS.radish.plantregistryinfo = {
    {
        text = "seed",
        anim = "crop_seed",
        grow_anim = "grow_seed",
        learnseed = true,
        growing = true,
    },
    {
        text = "sprout",
        anim = "crop_sprout",
        grow_anim = "grow_sprout",
        growing = true,
    },
    {
        text = "small",
        anim = "crop_small",
        grow_anim = "grow_small",
        growing = true,
    },
    {
        text = "medium",
        anim = "crop_med",
        grow_anim = "grow_med",
        growing = true,
    },
    {
        text = "grown",
        anim = "crop_full",
        grow_anim = "grow_full",
        revealplantname = true,
        fullgrown = true,
    },
    {
        text = "oversized",
        anim = "crop_oversized",
        grow_anim = "grow_oversized",
        revealplantname = true,
        fullgrown = true,
        hidden = true,
    },
    {
        text = "rotting",
        anim = "crop_rot",
        grow_anim = "grow_rot",
        stagepriority = -100,
        is_rotten = true,
        hidden = true,
    },
    {
        text = "oversized_rotting",
        anim = "crop_rot_oversized",
        grow_anim = "grow_rot_oversized",
        stagepriority = -100,
        is_rotten = true,
        hidden = true,
    },
}

-- season preferences {"temperate", "humid", "lush", "aporkalypse"}
-- season preferences {"autumn", "spring", "summer", "aporkalypse"}

for veggiename,veggiedata in pairs(PLANT_DEFS) do
	local good_seasons = PLANT_DEFS[veggiename].good_seasons

	good_seasons.temperate = good_seasons.autumn or nil
	good_seasons.humid = good_seasons.spring or nil
	good_seasons.lush = good_seasons.summer or nil
end

return {PLANT_DEFS = PLANT_DEFS}
