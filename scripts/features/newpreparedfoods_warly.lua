local FOODTYPE =
{
    GENERIC = "GENERIC",
    MEAT = "MEAT",
    VEGGIE = "VEGGIE",
    ELEMENTAL = "ELEMENTAL",
    GEARS = "GEARS",
    HORRIBLE = "HORRIBLE",
    INSECT = "INSECT",
    SEEDS = "SEEDS",
    BERRY = "BERRY", --hack for smallbird; berries are actually part of veggie
    RAW = "RAW", -- things which some animals can eat off the ground, but players need to cook
    BURNT = "BURNT", --For lavae.
    NITRE = "NITRE", -- For acidbats; they are part of elemental.
    ROUGHAGE = "ROUGHAGE",
	WOOD = "WOOD",
    GOODIES = "GOODIES",
    MONSTER = "MONSTER", -- Added in for woby, uses the secondary foodype originally added for the berries
}


local foods =
{
    --糖醋鲤鱼
    sweetandsourcarp =
    {
        test = function(cooker, names, tags) return tags.fish and tags.fish >= 0.5 and (tags.sweetener and tags.sweetener >= 2) and not tags.inedible end,
        priority = 30,
        foodtype = FOODTYPE.MEAT,
        health = 20,
        hunger = 75/2,
        sanity = 5,
        perishtime = 8*30*16,
        cooktime = 2,
        potlevel = "low",
        tags = { "masterfood" },
        overridebuild = "new_cook_pot_food",
        prefabs = { "buff_fogproof" },
		oneat_desc = "Clear the fog",
        oneatenfn = function(inst, eater)
            eater:AddDebuff("buff_fogproof", "buff_fogproof")
       	end,

        floater = {nil, 0.1},
    },

    --hamlet蓝带鱼排
    frogfishbowl_hamlet =
    {
        test = function(cooker, names, tags) return ((names.drumstick and names.drumstick >= 2) or (names.drumstick_cooked and names.drumstick_cooked >= 2 ) or (names.drumstick and names.drumstick_cooked) or (names.froglegs and names.froglegs >= 2) or (names.froglegs_cooked and names.froglegs_cooked >= 2 ) or (names.froglegs and names.froglegs_cooked) or (names.froglegs and names.drumstick) or (names.froglegs and names.drumstick_cooked) or (names.froglegs_cooked and names.drumstick) or (names.froglegs_cooked and names.drumstick_cooked)) and tags.fish and tags.fish >= 0.5 and not tags.inedible end,
        priority = 31,
        foodtype = FOODTYPE.MEAT,
        health = 20,
        hunger = 75/2,
        sanity = -10,
        perishtime = 8*30*16,
        cooktime = 2,
        potlevel = "low",
        tags = { "masterfood" },
        overridebuild = "new_cook_pot_food",
        prefabs = { "buff_moistureimmunity" },
		oneat_desc = "Dissipates moisture",
        oneatenfn = function(inst, eater)
            eater:AddDebuff("buff_moistureimmunity", "buff_moistureimmunity")
       	end,
        floater = {nil, 0.1},
    },
}

for k, v in pairs(foods) do
    v.name = k
    v.weight = v.weight or 1
    v.priority = v.priority or 0

	v.cookbook_category = "portablecookpot"
end

return foods
