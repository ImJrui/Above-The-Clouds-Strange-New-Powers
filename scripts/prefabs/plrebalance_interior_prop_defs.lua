local old_propdefs = require("prefabs/interior_prop_defs")

local PROP_DEFS = {}

local EXIT_SHOP_SOUND = "dontstarve_DLC003/common/objects/store/door_close"

local function Generate_Skyworthyshop_Rows(tab, rowstartX, rowstartY, rowdispX, rowdispY, columndispX, columndispY, numrows, numcolumns, pool, itemsold)
	itemsold = itemsold or {} --in case nothing
	for i=1, numrows do
		for j=1, numcolumns do
			local index = (j - 1) * numrows + i
			local item = itemsold[index]
			tab[#tab + 1] = {name = "shop_buyer",x_offset = rowstartX + rowdispX * i + columndispX * j, z_offset = rowstartY + rowdispY * i + columndispY * j,
				animation = pool[index],
				saleitem = item,
			}
		end
	end
end

local function GenerateRandomDecorFront(tab, prefab, minX, maxX, Y)
	local x_occupied = {}
	for i = 1, #prefab do
		for j = 1, 10 do
			local test_x = math.random(minX, maxX)
			local failed = false
			for k = 1, #x_occupied do
				if math.abs(test_x - x_occupied[k]) < 3 then
					failed = true
					break
				end
			end
			if not failed then
				tab[#tab + 1] = prefab[i]
				prefab[i].z_offset = test_x
				prefab[i].x_offset = Y
				x_occupied[#x_occupied + 1] = test_x
				break
			end
		end
	end
end
		
local pool_skyworthy_shop = {
	"idle_globe_bar",
	"idle_marble_dome",
	"idle_marble_dome",
	"idle_marblesilk",
	"idle_marblesilk",
	"idle_cakestand_dome",
	"idle_globe_bar",
	"idle_marble_dome",
	"idle_marble_dome",
	"idle_marblesilk",
	"idle_marblesilk",
	"idle_cakestand_dome",
	"idle_globe_bar",
	"idle_marble_dome",
	"idle_marble_dome",
	"idle_marblesilk",
	"idle_marblesilk",
	"idle_cakestand_dome",
}
		
local pool_skyworthy_shop_2 = {
	"idle_marblesilk",
	"idle_marblesilk",
	"idle_marblesilk",
	"idle_marble_dome",
	"idle_marble_dome",
	"idle_marble_dome",
	"idle_cakestand_dome",
}
		
local pool_skyworthy_shop_2_items = {
	{ "yellowamulet",        "relic_1", 1  },
	{ "greenamulet",        "relic_2", 1  },
	{ "orangeamulet",        "relic_3", 1  },
	{ "yellowstaff",        "relic_1", 1  },
	{ "greenstaff",        "relic_2", 1  },
	{ "orangestaff",        "relic_3", 1  },
	{ "opalstaff",        "relic_1", 1  },
}
		
local pool_skyworthy_shop_3 = {
	"idle_globe_bar",
	"idle_marble_dome",
	"idle_marble_dome",
	"idle_marble_dome",
	"idle_marblesilk",
	"idle_marblesilk",
	"idle_cakestand_dome",
	"idle_globe_bar",
	"idle_marble_dome",
	"idle_marble_dome",
	"idle_marble_dome",
	"idle_marblesilk",
	"idle_marblesilk",
	"idle_cakestand_dome",
}
		
local pool_skyworthy_shop_3_items = {
		
	--moonquay
	{ "dug_bananabush",        "oinc", 10  },
	{ "palmcone_seed",        "oinc", 5  },
	-- { "dock_kit",        "oinc", 5  },
	{ "dock_woodposts_item",        "oinc", 5  },
	{ "boat_cannon_kit",        "oinc", 20  },
	{ "cannonball_rock_item",        "oinc", 3  },
	{ "turf_monkey_ground",        "oinc", 2  },
	
	--lunar
	{ "dug_rock_avocado_bush",        "oinc", 10  },
	{ "bullkelp_root",        "oinc", 5  },
	
	--toad
	{ "shroom_skin",        "oinc", 20  },
	{ "mushroom_light_blueprint",        "oinc", 30  },
	{ "mushroom_light2_blueprint",        "oinc", 30  },
	
	--pearl
	{ "hermit_bundle_shells",        "oinc", 10  },
	{ "turf_shellbeach",        "oinc", 2  },
}

PROP_DEFS.skyworthy_shop = function (depth, width, exterior_door_def, exterior_door_def_2, exterior_door_def_3)
    local rv = {
        {
            name = "prop_door_hamportal",
            x_offset = 7,
            z_offset = -8,
            animdata = {
                bank = "hamportal",
                build = "portal_hamlet_build",
                anim = "idle_off",
                background = false
            },
            is_exit = true,
            my_door_id = exterior_door_def.my_door_id,
            target_door_id = exterior_door_def.target_door_id,
            addtags = {"guard_entrance", "shop_music", "door_north"},
            usesounds = {EXIT_SHOP_SOUND},
        },
        {
            name = "prop_door",
            x_offset = 0,
            z_offset = -width / 2,
            animdata = {
                bank = "player_house_doors",
                build = "player_house_doors",
                anim = "round_door_open_east",
                background = true
            },
            my_door_id = exterior_door_def_2.my_door_id,
            target_door_id = exterior_door_def_2.target_door_id,
            target_interior = exterior_door_def_2.target_interior,
            usesounds = {EXIT_SHOP_SOUND},
            addtags = {"door_west"},
        },
        {
            name = "prop_door_z0",
            x_offset = 0,
            z_offset = width / 2 - 0.000001,
            animdata = {
                bank = "player_house_doors",
                build = "player_house_doors",
                anim = "round_door_open_west",
                background = false
            },
            my_door_id = exterior_door_def_3.my_door_id,
            target_door_id = exterior_door_def_3.target_door_id,
            target_interior = exterior_door_def_3.target_interior,
            usesounds = {EXIT_SHOP_SOUND},
            addtags = {"door_east"},
        },

        {name = "deco_roomglow_large", x_offset = 0, z_offset = 0},
		{name = "pigman_professor_shopkeep", x_offset = -5, z_offset = 8, startstate = "desk_pre"},
		
        {name = "window_greenhouse_backwall", x_offset = -depth / 2, z_offset = -width / 4 - 0.1},
        {name = "window_greenhouse_backwall", x_offset = -depth / 2, z_offset = width / 4 + 0.1},
        -- {name = "window_greenhouse_rescaledplrebalance", x_offset = -depth / 4 - 0.1, z_offset = width / 2}, --rescaled to fit wall
        -- {name = "window_greenhouse_rescaledplrebalance", x_offset = depth / 4 + 0.1, z_offset = width / 2}, --rescaled to fit wall

		{name = "lightrays_jungle", x_offset = 0, z_offset = -5},
		{name = "lightrays_jungle", x_offset = 0, z_offset = 5},
		
        {name = "deco_accademy_beam", x_offset = -depth / 2, z_offset = width / 2, flip = true},
		{name = "deco_accademy_beam", x_offset = -depth / 2, z_offset = -width / 2},
        {name = "deco_marble_beam", x_offset = depth / 2, z_offset = width / 2, flip = true},
		{name = "deco_marble_beam", x_offset = depth / 2, z_offset = -width / 2},
		{name = "swinging_light_floral_bulb", x_offset = -6, z_offset = -5},
		{name = "swinging_light_floral_bulb", x_offset = -6, z_offset = 5},
		
		{name = "rug_oval", x_offset = -2, z_offset = -5, rotation = math.random(60, 120)},
		{name = "rug_oval", x_offset = -2, z_offset = 5, rotation = math.random(60, 120)},
		{name = "rug_oval", x_offset = 3, z_offset = -3, rotation = math.random(60, 120)},
		{name = "rug_oval", x_offset = 3, z_offset = 3, rotation = math.random(60, 120)},
    }

	local skyworthy_shop_decors_front = {
		{name = "deco_wallornament_black_cat"},
		{name = "deco_wallornament_black_cat"},
		{name = "deco_antiquities_beefalo"},
		{name = "deco_wallornament_wreath"},
		{name = "deco_wallornament_photo"},
	}
	GenerateRandomDecorFront(rv, skyworthy_shop_decors_front, -width / 3, width / 3, -depth / 2 + -0.001)
	Generate_Skyworthyshop_Rows(rv, 8, -8, 0.5, 2.5, -5, -0.5, 6, 3, pool_skyworthy_shop)
	return rv
end

PROP_DEFS.skyworthy_shop_2 = function (depth, width, exterior_door_def)
    local rv = {
        {
            name = "prop_door_z0",
            x_offset = 0,
            z_offset = width / 2 - 0.000001,
            animdata = {
                bank = "player_house_doors",
                build = "player_house_doors",
                anim = "round_door_open_west",
                background = false
            },
            my_door_id = exterior_door_def.my_door_id,
            target_door_id = exterior_door_def.target_door_id,
            target_interior = exterior_door_def.target_interior,
            usesounds = {EXIT_SHOP_SOUND},
            addtags = {"guard_entrance", "shop_music", "door_east"},
        },

        {name = "deco_roomglow_large", x_offset = 0, z_offset = 0},
		{name = "pigman_professor_shopkeep", x_offset = -5, z_offset = 8, startstate = "desk_pre"},
		
        {name = "window_greenhouse_backwall", x_offset = -depth / 2, z_offset = -width / 4 - 0.1},
        {name = "window_greenhouse_backwall", x_offset = -depth / 2, z_offset = width / 4 + 0.1},
        -- {name = "window_greenhouse_rescaledplrebalance", x_offset = -depth / 4 - 0.1, z_offset = width / 2}, --rescaled to fit wall
        -- {name = "window_greenhouse_rescaledplrebalance", x_offset = depth / 4 + 0.1, z_offset = width / 2}, --rescaled to fit wall
		
		{name = "lightrays_jungle", x_offset = 0, z_offset = -5},
		{name = "lightrays_jungle", x_offset = 0, z_offset = 5},
				
        {name = "deco_accademy_beam", x_offset = -depth / 2, z_offset = width / 2, flip = true},
		{name = "deco_accademy_beam", x_offset = -depth / 2, z_offset = -width / 2},
        {name = "deco_marble_beam", x_offset = depth / 2, z_offset = width / 2, flip = true},
		{name = "deco_marble_beam", x_offset = depth / 2, z_offset = -width / 2},
		{name = "swinging_light_floral_bulb", x_offset = -6, z_offset = -5},
		{name = "swinging_light_floral_bulb", x_offset = -6, z_offset = 5},
		
		{name = "rug_oval", x_offset = -2, z_offset = -5, rotation = math.random(60, 120)},
		{name = "rug_oval", x_offset = -2, z_offset = 5, rotation = math.random(60, 120)},
		{name = "rug_oval", x_offset = 3, z_offset = -3, rotation = math.random(60, 120)},
		{name = "rug_oval", x_offset = 3, z_offset = 3, rotation = math.random(60, 120)},
    }

	local skyworthy_shop_decors_front = {
		{name = "deco_wallornament_black_cat"},
		{name = "deco_wallornament_black_cat"},
		{name = "deco_antiquities_beefalo"},
		{name = "deco_wallornament_wreath"},
		{name = "deco_wallornament_photo"},
	}
	GenerateRandomDecorFront(rv, skyworthy_shop_decors_front, -width / 3, width / 3, -depth / 2 + -0.001)
	Generate_Skyworthyshop_Rows(rv, -1, -8, 0, 2.5, 0, 0, 7, 1, pool_skyworthy_shop_2, pool_skyworthy_shop_2_items)
	return rv
end

PROP_DEFS.skyworthy_shop_3 = function (depth, width, exterior_door_def)
    local rv = {
        {
            name = "prop_door_z0",
            x_offset = 0,
            z_offset = -width / 2,
            animdata = {
                bank = "player_house_doors",
                build = "player_house_doors",
                anim = "round_door_open_east",
                background = true
            },
            my_door_id = exterior_door_def.my_door_id,
            target_door_id = exterior_door_def.target_door_id,
            target_interior = exterior_door_def.target_interior,
            usesounds = {EXIT_SHOP_SOUND},
            addtags = {"guard_entrance", "shop_music", "door_west"},
        },

        {name = "deco_roomglow_large", x_offset = 0, z_offset = 0},
		{name = "pigman_professor_shopkeep", x_offset = -5, z_offset = 8, startstate = "desk_pre"},
		
        {name = "window_greenhouse_backwall", x_offset = -depth / 2, z_offset = -width / 4 - 0.1},
        {name = "window_greenhouse_backwall", x_offset = -depth / 2, z_offset = width / 4 + 0.1},
        -- {name = "window_greenhouse_rescaledplrebalance", x_offset = -depth / 4 - 0.1, z_offset = width / 2}, --rescaled to fit wall
        -- {name = "window_greenhouse_rescaledplrebalance", x_offset = depth / 4 + 0.1, z_offset = width / 2}, --rescaled to fit wall
		
		{name = "lightrays_jungle", x_offset = 0, z_offset = -5},
		{name = "lightrays_jungle", x_offset = 0, z_offset = 5},
				
        {name = "deco_accademy_beam", x_offset = -depth / 2, z_offset = width / 2, flip = true},
		{name = "deco_accademy_beam", x_offset = -depth / 2, z_offset = -width / 2},
        {name = "deco_marble_beam", x_offset = depth / 2, z_offset = width / 2, flip = true},
		{name = "deco_marble_beam", x_offset = depth / 2, z_offset = -width / 2},
		{name = "swinging_light_floral_bulb", x_offset = -6, z_offset = -5},
		{name = "swinging_light_floral_bulb", x_offset = -6, z_offset = 5},
		
		{name = "rug_oval", x_offset = -2, z_offset = -5, rotation = math.random(60, 120)},
		{name = "rug_oval", x_offset = -2, z_offset = 5, rotation = math.random(60, 120)},
		{name = "rug_oval", x_offset = 3, z_offset = -3, rotation = math.random(60, 120)},
		{name = "rug_oval", x_offset = 3, z_offset = 3, rotation = math.random(60, 120)},
    }

	local skyworthy_shop_decors_front = {
		{name = "deco_wallornament_black_cat"},
		{name = "deco_wallornament_black_cat"},
		{name = "deco_antiquities_beefalo"},
		{name = "deco_wallornament_wreath"},
		{name = "deco_wallornament_photo"},
	}
	GenerateRandomDecorFront(rv, skyworthy_shop_decors_front, -width / 3, width / 3, -depth / 2 + -0.001)
	Generate_Skyworthyshop_Rows(rv, 8, -8, 0, 2.5, -5, 0, 7, 2, pool_skyworthy_shop_3, pool_skyworthy_shop_3_items)
	return rv
end

local function GenerateProps(name, ...)
    if not PROP_DEFS[name] then
        return old_propdefs(name, ...)
    end

    return PROP_DEFS[name](...)
end

return GenerateProps
