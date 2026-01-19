local EnableSkyworthy = GetModConfigData("EnableSkyworthy")

local AddDeconstructRecipe = AddDeconstructRecipe
local AddRecipe2 = AddRecipe2
local AddRecipeFilter = AddRecipeFilter
local AddPrototyperDef = AddPrototyperDef
local AddRecipePostInit = AddRecipePostInit

local AddPrefabPostInit = AddPrefabPostInit
local AddSimPostInit = AddSimPostInit

GLOBAL.setfenv(1, GLOBAL)

local TechTree = require("techtree")

local function SortRecipe(a, b, filter_name, offset)
    local filter = CRAFTING_FILTERS[filter_name]
    if filter and filter.recipes then
        for sortvalue, product in ipairs(filter.recipes) do
            if product == a then
                table.remove(filter.recipes, sortvalue)
                break
            end
        end

        local target_position = #filter.recipes + 1
        for sortvalue, product in ipairs(filter.recipes) do
            if product == b then
                target_position = sortvalue + offset
                break
            end
        end
        table.insert(filter.recipes, target_position, a)
    end
end

local function SortAfter(a, b, filter_name)  -- a after b
    SortRecipe(a, b, filter_name, 1)
end

local function NotInInterior(pt)
    return not TheWorld.components.interiorspawner:IsInInteriorRegion(pt.x, pt.z)
end

local function IsInPorkland(pt)
	return TheWorld:HasTag("porkland")
end

local function CanNotBuildOnTile(pt)
	local CanNot_List = {
		260,--洞穴探险桥
		263,-- 码头地块
		262,-- 玫瑰桥
		201, --水上
	}
    local ground_tile = TheWorld.Map:GetTileAtPoint(pt.x, pt.y, pt.z)
    if ground_tile then
        for _, forbidden_tile_id in ipairs(CanNot_List) do
            if ground_tile == forbidden_tile_id then
                return true
            end
        end
    end
    return false
end

local function IsOnBoat(pt)
    local x, y, z = pt.x, pt.y, pt.z
    local boats = TheSim:FindEntities(x, y, z, 4, {"walkableplatform"})
    for _, ent in ipairs(boats) do
        if ent:HasTag("boat") then
            return true
        end
    end
    return false
end

local function calc_slingshotammo_numtogive(recipe, doer)
	return doer.components.skilltreeupdater
		and doer.components.skilltreeupdater:IsActivated("walter_ammo_efficiency")
		and recipe.numtogive * 1.5
		or nil
end
local function get_slingshotammo_sg_state(recipe, doer)
	return doer.components.skilltreeupdater
		and doer.components.skilltreeupdater:IsActivated("walter_ammo_efficiency")
		and "domediumaction"
		or nil
end

--------------------------------------------------------------
--change_recipes
local DISABLE_RECIPES = require("main/change_recipes").DISABLE_RECIPES
local pl_change_recipes = require("features/pl_change_recipes")
local DISABLE_RECIPES_PORKLAND = pl_change_recipes.DISABLE_RECIPES_PORKLAND
local ENABLE_RECIPES_PORKLAND = pl_change_recipes.ENABLE_RECIPES_PORKLAND
local PIGSHOPLIST = pl_change_recipes.PIGSHOPLIST
local LOST_RECIPES_FOREST = pl_change_recipes.LOST_RECIPES_FOREST

for i, recipe_name in ipairs(DISABLE_RECIPES_PORKLAND) do
    AddRecipePostInit(recipe_name, function(recipe)
        recipe.disabled_worlds = { "porkland" }
    end)
end

--------------------------------------------------------------
local function PorklandChangeRecipes()

	if not TheWorld:HasTag("porkland") then return end

	
	local ENABLE_RECIPES_PORKLAND_INVERT = table.invert(ENABLE_RECIPES_PORKLAND)
	for i, recipe_name in ipairs(DISABLE_RECIPES) do
		AddRecipePostInit(recipe_name, function(recipe)
			recipe.disabled_worlds = {}
			if not ENABLE_RECIPES_PORKLAND_INVERT[recipe_name] then
				recipe.level = TechTree.Create(TECH.LOST)
			end
		end)
	end

	--willow
	AllRecipes["bernie_inactive"].ingredients = {Ingredient("beardhair", 2), Ingredient("piko_orange", 1), Ingredient("silk", 2)}

	--wanda
	AllRecipes["pocketwatch_parts"].ingredients = {Ingredient("pocketwatch_dismantler", 0), Ingredient("alloy", 2), Ingredient("nightmarefuel", 2)}
	AllRecipes["pocketwatch_heal"].ingredients = {Ingredient("pocketwatch_parts", 1), Ingredient("alloy", 2), Ingredient("waterdrop", 0)}
	AllRecipes["pocketwatch_weapon"].ingredients = {Ingredient("pocketwatch_parts", 3), Ingredient("alloy", 4), Ingredient("nightmarefuel", 8)}

	--wigfrid
	AllRecipes["battlesong_sanityaura"].ingredients = {Ingredient("papyrus", 1), Ingredient("featherpencil", 1), Ingredient("ancient_remnant", 1)}
	AllRecipes["battlesong_sanitygain"].ingredients = {Ingredient("papyrus", 1), Ingredient("featherpencil", 1), Ingredient("waterdrop", 0)}
	AllRecipes["battlesong_fireresistance"].ingredients = {Ingredient("papyrus", 1), Ingredient("featherpencil", 1), Ingredient("infused_iron", 1)}
	AllRecipes["battlesong_instant_taunt"].ingredients = {Ingredient("papyrus", 1), Ingredient("featherpencil", 1), Ingredient("poop", 1)}
	AllRecipes["spear_wathgrithr_lightning"].ingredients = {Ingredient("twigs", 2), Ingredient("lightninggoathorn", 2), Ingredient("alloy", 1)}
	AllRecipes["wathgrithr_improvedhat"].ingredients = {Ingredient("goldnugget", 2), Ingredient("clippings", 4), Ingredient("snake_bone", 1)}

	-- wolfgang
	AllRecipes["dumbbell_gem"].ingredients = {Ingredient("purplegem", 1), Ingredient("snake_bone", 4), Ingredient("twigs", 1)}
	AllRecipes["dumbbell_redgem"].ingredients = {Ingredient("redgem", 1), Ingredient("snake_bone", 4), Ingredient("twigs", 1)}
	AllRecipes["dumbbell_bluegem"].ingredients = {Ingredient("bluegem", 1), Ingredient("snake_bone", 4), Ingredient("twigs", 1)}
	-- AllRecipes["dumbbell_marble"].ingredients = {Ingredient("alloy", 4), Ingredient("twigs", 1)}

	--wurt
	CONSTRUCTION_PLANS["mermthrone_construction"] = {Ingredient("clippings", 20), Ingredient("pigskin", 10), Ingredient("silk", 5)}

	--wx78
	-- AllRecipes["wx78module_bee"].ingredients = {Ingredient("scandata", 8), Ingredient("nectar_pod", 4), Ingredient("wx78module_maxsanity", 1)}
	AllRecipes["wx78module_music"].ingredients = {Ingredient("scandata", 4), Ingredient("ox_horn", 1)}
	AllRecipes["wx78module_maxhunger"].ingredients = {Ingredient("scandata", 3), Ingredient("venus_stalk", 1), Ingredient("wx78module_maxhunger1", 1)}
	AllRecipes["wx78module_movespeed"].ingredients = {Ingredient("scandata", 2), Ingredient("piko", 1)}
	AllRecipes["wx78module_taser"].ingredients = {Ingredient("scandata", 5), Ingredient("feather_thunder", 1)}

	-- walter
	AllRecipes["slingshotammo_marble"].ingredients = {Ingredient("snake_bone", 1)}
	AllRecipes["slingshotammo_freeze"].ingredients = {Ingredient("snake_bone", 1), Ingredient("bluegem", 1)}
	AllRecipes["slingshotammo_slow"].ingredients = {Ingredient("snake_bone", 1), Ingredient("purplegem", 1)}
	-- AllRecipes["slingshotammo_dreadstone"].ingredients = {Ingredient("dreadstone", 1)}
	AllRecipes["slingshot_handle_sticky"].ingredients = {Ingredient("slugbug", 1)}
	AllRecipes["slingshotammo_scrapfeather"].ingredients = {Ingredient("alloy", 1), Ingredient("feather_thunder", 1)}
	AllRecipes["slingshotammo_scrapfeather"].image = "slingshotammo_scrapfeather_hamlet.tex"
	AllRecipes["slingshotammo_horrorfuel"].ingredients = {Ingredient("ancient_remnant", 1), Ingredient("rocks", 1)}
	-- AllRecipes["slingshotammo_horrorfuel"].level = TechTree.Create(TECH.NONE)
	AllRecipes["slingshot_frame_wagpunk_0"].ingredients = {Ingredient("alloy", 2), Ingredient("transistor", 1), Ingredient("gears", 1)}
	AddRecipe2("slingshotammo_moonglass",{Ingredient("moonglass", 1)},TECH.CELESTIAL_ONE,{builder_skill="walter_ammo_shattershots",sg_state=get_slingshotammo_sg_state, numtogive=20, override_numtogive_fn=calc_slingshotammo_numtogive, no_deconstruction=true, allowautopick=true, force_hint=true, station_tag="celestial_station"})
	AddRecipe2("slingshot_handle_voidcloth",{Ingredient("ancient_remnant", 1)},TECH.MAGIC_THREE,{builder_skill="walter_slingshot_handles",	force_hint=true, station_tag="shadow_forge"})
	AddRecipe2("slingshot_frame_gems",{Ingredient("infused_iron", 2), Ingredient("nightmarefuel", 2), Ingredient("redgem", 1), Ingredient("bluegem", 1)},TECH.MAGIC_THREE,{builder_skill="walter_slingshot_frames",force_hint=true, station_tag="ancient_station"})

	-- wendy
	AllRecipes["ghostlyelixir_shadow"].ingredients = {Ingredient("ancient_remnant", 1), Ingredient("ghostflower", 3)}
	AllRecipes["ghostlyelixir_lunar"].ingredients = {Ingredient("infused_iron", 1), Ingredient("ghostflower", 3)}
	AllRecipes["graveurn"].ingredients = {Ingredient("ash", 1), Ingredient("weevole_carapace", 1)}
	AllRecipes["wendy_gravestone"].testfn = NotInInterior

	-- wortox
	AllRecipes["wortox_souljar"].ingredients = {Ingredient("messagebottleempty", 1), Ingredient("alloy", 2), Ingredient("redgem", 1)}
	
	--seedofruin
	AddRecipe2("seedofruin",{Ingredient("ancient_remnant", 1), Ingredient("infused_iron", 1)},	TECH.MAGIC_THREE, {}, {"TOOLS", "ARCHAEOLOGY", "MAGIC"})
	SortAfter("seedofruin", "armorvortexcloak", "MAGIC")
	SortAfter("seedofruin", "shoplocker", "TOOLS")

	--skyworthy_shop
	AddDeconstructRecipe("skyworthy_shop", {Ingredient("pigskin", 6), Ingredient("livinglog", 2)}) --is halved when using hammer
	AddDeconstructRecipe("pig_shop_skyworthy", {Ingredient("pigskin", 6), Ingredient("livinglog", 2)})

	AddRecipe2("skyworthy_shop_recipe",	{Ingredient("pigskin", 12), Ingredient("livinglog", 4), Ingredient("trinket_giftshop_4", 1)},	TECH.MAGIC_THREE,
		{placer = "pig_shop_skyworthy_placer",
		product = "pig_shop_skyworthy",
		min_spacing = 3.5,
		testfn = NotInInterior,
		no_deconstruction = true,
		atlas = "images/hud/pl_inventoryimages.xml",
		image = "porkland_entrance.tex",}, {"MAGIC", "ARCHAEOLOGY", "STRUCTURES"})
	SortAfter("skyworthy_shop_recipe", "seedofruin", "MAGIC")
	SortAfter("skyworthy_shop_recipe", "nightlight", "STRUCTURES")
	SortAfter("skyworthy_shop_recipe", "seedofruin", "ARCHAEOLOGY")

	--items
	AddRecipe2("ruinsrelic_chair", {Ingredient("cutstone", 1), Ingredient("oinc", 20)}, TECH.CARPENTRY_TWO, {placer = "ruinsrelic_chair_placer"}, {"DECOR","STRUCTURES","CRAFTING_STATION"}) --远古石椅子
	AddRecipe2("ruinsrelic_table", {Ingredient("cutstone", 1), Ingredient("oinc", 20)}, TECH.CARPENTRY_TWO, {placer = "ruinsrelic_table_placer"}, {"DECOR","STRUCTURES","CRAFTING_STATION"}) --远古石桌子
	AddRecipe2("ruinsrelic_vase", {Ingredient("cutstone", 2), Ingredient("oinc", 20)}, TECH.CARPENTRY_TWO, {placer = "ruinsrelic_vase_placer"}, {"DECOR","STRUCTURES","CRAFTING_STATION"}) --远古石花瓶
	AddRecipe2("ruinsrelic_plate", {Ingredient("cutstone", 1), Ingredient("oinc", 20)}, TECH.CARPENTRY_TWO, {placer = "ruinsrelic_plate_placer"}, {"DECOR","STRUCTURES","CRAFTING_STATION"}) --远古石板
	AddRecipe2("ruinsrelic_bowl", {Ingredient("cutstone", 2), Ingredient("oinc", 20)}, TECH.CARPENTRY_TWO, {placer = "ruinsrelic_bowl_placer"}, {"DECOR","STRUCTURES","CRAFTING_STATION"}) --远古石碗
	AddRecipe2("ruinsrelic_chipbowl", {Ingredient("cutstone", 1), Ingredient("oinc", 20)}, TECH.CARPENTRY_TWO, {placer = "ruinsrelic_chipbowl_placer"}, {"DECOR","STRUCTURES","CRAFTING_STATION"}) --远古石菜肴
	AddRecipe2("endtable", {Ingredient("boards", 2), Ingredient("cutstone", 2), Ingredient("oinc", 20)}, TECH.CARPENTRY_TWO, {placer = "endtable_placer"}, {"DECOR","STRUCTURES","CRAFTING_STATION"}) --茶几
	AddRecipe2("succulent_potted", {Ingredient("cutstone", 1), Ingredient("clippings", 2), Ingredient("oinc", 10)}, TECH.CARPENTRY_TWO, {placer = "succulent_potted_placer"}, {"DECOR","STRUCTURES","CRAFTING_STATION"}) --多肉盆栽
	AddRecipe2("pottedfern", {Ingredient("cutstone", 1), Ingredient("foliage", 2), Ingredient("oinc", 10)}, TECH.CARPENTRY_TWO, {placer = "pottedfern_placer"}, {"DECOR","STRUCTURES","CRAFTING_STATION"}) --蕨类盆栽
	AddRecipe2("carpentry_blade_moonglass", {Ingredient("alloy", 1), Ingredient("moonglass", 6)}, TECH.CELESTIAL_ONE, {nounlock = true})--月亮玻璃切片
	AddRecipe2("carpentry_station", {Ingredient("flint", 4), Ingredient("boards", 4), Ingredient("oinc", 50)}, TECH.SCIENCE_TWO, {placer = "carpentry_station_placer"}, {"SCIENCE","STRUCTURES"}) --锯马
	AllRecipes["moondial"].ingredients = {Ingredient("alloy", 2), Ingredient("bluegem", 1), Ingredient("ice", 2)}

	-- moonrock idol
	AllRecipes["multiplayer_portal_moonrock_constr_plans"].ingredients = {Ingredient("boards", 1), Ingredient("rope", 1)}
	AllRecipes["moonrockidol"].ingredients = {Ingredient("alloy", 1), Ingredient("purplegem", 1)}
	CONSTRUCTION_PLANS["multiplayer_portal_moonrock_constr"] = {Ingredient("purplegem", 1), Ingredient("alloy", 10)}--绚丽之门建造

	-- woodie

	-- wormwood
	AllRecipes["armor_bramble"].ingredients = {Ingredient("livinglog", 2), Ingredient("boneshard", 4)}

	--Wickerbottom
	AllRecipes["book_moon"].ingredients = {Ingredient("papyrus", 2), Ingredient("waterdrop", 1), Ingredient("glowfly", 2)}
	-- winona
	AddRecipe2("winona_storage_robot",{Ingredient("wagpunk_bits", 8), Ingredient("transistor", 4), Ingredient("winona_machineparts_1", 3)},	TECH.NONE,{builder_skill="winona_wagstaff_1"},{"CHARACTER"})
	SortAfter("winona_storage_robot", "roseglasseshat", "CHARACTER")

	--wilson
	AllRecipes["transmute_beardhair"].ingredients = {Ingredient("silk", 2)}
	AddRecipe2("transmute_silk", {Ingredient("beardhair", 2)}, TECH.NONE,
		{product="silk",
		image="silk.tex",
		builder_skill="wilson_alchemy_9",
		description="transmute_silk"},
		{"CHARACTER"})
	SortAfter("transmute_silk", "transmute_beardhair", "CHARACTER")
	AddRecipe2("transmute_mosquitosack", {Ingredient("spidergland", 2)}, TECH.NONE,
		{product="mosquitosack",
		image="mosquitosack.tex",
		builder_skill="wilson_alchemy_8",
		description="transmute_mosquitosack"},
		{"CHARACTER"})
	SortAfter("transmute_mosquitosack", "transmute_silk", "CHARACTER")
	AddRecipe2("transmute_spidergland", {Ingredient("mosquitosack", 2)}, TECH.NONE,
		{product="spidergland",
		image="spidergland.tex",
		builder_skill="wilson_alchemy_8",
		description="transmute_spidergland"},
		{"CHARACTER"})
	SortAfter("transmute_spidergland", "transmute_mosquitosack", "CHARACTER")
	AddRecipe2("transmute_weevole_carapace", {Ingredient("chitin", 2)}, TECH.NONE,
		{product="weevole_carapace",
		image="weevole_carapace.tex",
		builder_skill="wilson_alchemy_8",
		description="transmute_weevole_carapace"},
		{"CHARACTER"})
	SortAfter("transmute_weevole_carapace", "transmute_spidergland", "CHARACTER")
	AddRecipe2("transmute_chitin", {Ingredient("weevole_carapace", 2)}, TECH.NONE,
		{product="chitin",
		image="chitin.tex",
		builder_skill="wilson_alchemy_8",
		description="transmute_chitin"},
		{"CHARACTER"})
	SortAfter("transmute_chitin", "transmute_weevole_carapace", "CHARACTER")
	
	--farm items
	AddRecipe2("nutrientsgoggleshat",{Ingredient("plantregistryhat", 1), Ingredient("iron", 4), Ingredient("purplegem", 1)},TECH.SCIENCE_TWO,{}, {"GARDENING"})
	AllRecipes["soil_amender"].ingredients = {Ingredient("messagebottleempty", 1), Ingredient("clippings", 2), Ingredient("ash", 1)}
	AllRecipes["seedpouch"].ingredients = {Ingredient("weevole_carapace", 2), Ingredient("cutgrass", 4), Ingredient("seeds", 2)}

	--pets
	AllRecipes["critter_lamb_builder"].ingredients = {Ingredient("lightninggoathorn", 1), Ingredient("tea", 1)}
	AllRecipes["critter_perdling_builder"].ingredients = {Ingredient("peagawkfeather", 1), Ingredient("jammypreserves", 1)}
	AllRecipes["critter_dragonling_builder"].ingredients = {Ingredient("snake_bone", 1), Ingredient("hotchili", 1)}
	AllRecipes["critter_glomling_builder"].ingredients = {Ingredient("slugbug", 1), Ingredient("taffy", 1)}
	AllRecipes["critter_lunarmothling_builder"].ingredients = {Ingredient("glowfly", 1), Ingredient("ratatouille", 1)}
	-- AllRecipes["critter_kitten_builder"].ingredients = {Ingredient("oinc", 50)}
	-- AllRecipes["critter_puppy_builder"].ingredients = {Ingredient("oinc", 50)}
	-- AllRecipes["critter_eyeofterror_builder"].ingredients = {Ingredient("oinc", 50)}

end

AddPrefabPostInit("porkland", PorklandChangeRecipes) --load after world loads, but before sim loads

---------------------------------------------------------------------
AddSimPostInit(function()
	-- 对所有世界生效
	if EnableSkyworthy then
		AddRecipe2("skyworthy_kit", {Ingredient("nightmarefuel", 4), Ingredient("livinglog", 4), Ingredient("trinket_giftshop_4", 1)}, TECH.MAGIC_TWO, nil, {"MAGIC","STRUCTURES"})
		AddDeconstructRecipe("skyworthy", {Ingredient("nightmarefuel", 4), Ingredient("livinglog", 4), Ingredient("trinket_giftshop_4", 1)})
	end
	
	--warly
	AddRecipe2("spice_lotus",{Ingredient("lotus_flower", 2),Ingredient("nectar_pod", 1)},TECH.FOODPROCESSING_ONE,{builder_tag="professionalchef", numtogive=2, nounlock=true})
	SortAfter("spice_lotus", "spice_chili", "CHARACTER")
	--Wolfgang
	AddRecipe2("dumbbell_iron",{Ingredient("alloy", 4), Ingredient("twigs", 1)},TECH.NONE, {builder_tag="strongman"},{"CHARACTER"})
	SortAfter("dumbbell_iron", "dumbbell_marble", "CHARACTER")

	--walter
	AddRecipe2("slingshotammo_infused",	{Ingredient("infused_iron", 1),Ingredient("waterdrop", 0)}, TECH.NONE, {builder_skill="walter_ammo_lunar", sg_state=get_slingshotammo_sg_state, numtogive=20, override_numtogive_fn=calc_slingshotammo_numtogive, no_deconstruction=true, allowautopick=true, force_hint=true, nounlock=true},{"CHARACTER"})
	SortAfter("slingshotammo_infused", "slingshotammo_purebrilliance", "CHARACTER")
	AddRecipe2("slingshotammo_alloy",	{Ingredient("alloy", 1)}, TECH.SCIENCE_TWO, {builder_tag="pebblemaker", sg_state=get_slingshotammo_sg_state, numtogive=20, override_numtogive_fn=calc_slingshotammo_numtogive, no_deconstruction=true, allowautopick=true},{"CHARACTER"})
	SortAfter("slingshotammo_alloy", "slingshotammo_marble", "CHARACTER")

	--wx78_newmodules
	AddRecipe2("wx78module_porklandrebalance_fan",	{Ingredient("scandata", 4), Ingredient("iron", 2)},	TECH.ROBOTMODULECRAFT_ONE, {builder_tag = "upgrademoduleowner"}, {"CHARACTER", "ENVIRONMENT_PROTECTION"})
	SortAfter("wx78module_porklandrebalance_fan", "wx78module_cold", "CHARACTER")
	AddRecipe2("wx78module_porklandrebalance_filter",	{Ingredient("scandata", 4), Ingredient("peagawkfeather", 1)},TECH.ROBOTMODULECRAFT_ONE, {builder_tag = "upgrademoduleowner"}, {"CHARACTER", "ENVIRONMENT_PROTECTION"})
	SortAfter("wx78module_porklandrebalance_filter", "wx78module_porklandrebalance_fan", "CHARACTER")

	-- shoplocker
	AddRecipe2("shoplocker",{Ingredient("oinc", 20)}, TECH.CITY, {nounlock = true})

	AddRecipe2("tuber_tree_sapling_item", {Ingredient("tuber_bloom_crop", 1), Ingredient("fertilizer", 1)}, TECH.SCIENCE_ONE, {no_deconstruction = true, image = "tuber_tree_sapling.tex"}, {"REFINE"})

	if TheWorld:HasTag("porkland") then
		return
	end
	
	-- 对porkland之外的世界生效

	AddRecipe2("molehat", {Ingredient("mole", 2), Ingredient("transistor", 2), Ingredient("wormlight", 1)}, TECH.SCIENCE_TWO, nil, {"LIGHT", "CLOTHING"})
	AddRecipe2("beargervest", {Ingredient("bearger_fur", 1), Ingredient("sweatervest", 1), Ingredient("rope", 2)}, TECH.SCIENCE_TWO, nil, {"CLOTHING"})
	AddRecipe2("armordragonfly", {Ingredient("dragon_scales", 1), Ingredient("armorwood", 1), Ingredient("pigskin", 3)}, TECH.SCIENCE_TWO, nil, {"ARMOUR"})
	AddRecipe2("eyebrellahat", {Ingredient("deerclops_eyeball", 1), Ingredient("twigs", 15), Ingredient("boneshard", 4)}, TECH.SCIENCE_TWO, nil, {"CLOTHING", "RAIN"})
	AddRecipe2("cane", {Ingredient("goldnugget", 2), Ingredient("walrus_tusk", 1), Ingredient("twigs", 4)}, TECH.SCIENCE_TWO, nil, {"TOOLS"})
	AddRecipe2("icepack", {Ingredient("bearger_fur", 1), Ingredient("gears", 1), Ingredient("transistor", 1)}, TECH.SCIENCE_TWO, nil, {"CONTAINERS"})
	AddRecipe2("staff_tornado", {Ingredient("goose_feather", 10), Ingredient("lightninggoathorn", 1), Ingredient("gears", 1)}, TECH.SCIENCE_TWO, nil, {"WEAPONS", "MAGIC"})
	AddRecipe2("dragonflychest", {Ingredient("dragon_scales", 1), Ingredient("boards", 4), Ingredient("goldnugget", 10)}, TECH.SCIENCE_TWO, {placer="dragonflychest_placer", min_spacing=1.5}, {"CONTAINERS"})
	
	-- boats
	AllRecipes["boat_lograft"].testfn = IsInPorkland
	AllRecipes["boat_row"].testfn = IsInPorkland
	AllRecipes["boat_cargo"].testfn = IsInPorkland
	AllRecipes["boat_cork"].testfn = IsInPorkland

	for _, i in ipairs(PIGSHOPLIST) do
		if AllRecipes[i] then
			AllRecipes[i].testfn = function(pt) return NotInInterior(pt) and not CanNotBuildOnTile(pt) and not IsOnBoat(pt) end
		end
	end

	for i, recipe_name in ipairs(LOST_RECIPES_FOREST) do
		AddRecipePostInit(recipe_name, function(recipe)
			recipe.level = TechTree.Create(TECH.LOST)
		end)
	end
end)

-------------------------------------------------------------------------------