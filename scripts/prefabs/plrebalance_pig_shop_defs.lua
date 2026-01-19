local SHOPTYPES = {

    DEFAULT = {
        "rocks",
        "flint",
        "goldnugget",
    },

    skyworthy_shop = { --TODO: split into multiple rooms
		--webber's spiders
        { "moonglass",          "oinc", 3  },
        { "fig",                "oinc", 3  },
        { "spidereggsack",      "oinc", 50 },
		
		--warly's seeds
        { "tomato",             "oinc", 2  },
        { "potato",             "oinc", 5  },
        { "garlic",             "oinc", 5  },
        { "onion",              "oinc", 5  },
        { "pepper",             "oinc", 10 },
        { "saltrock",           "oinc", 3  },
		
		--megan
        { "rabbit",                     "oinc", 5   },
        { "rabbithat",                  "oinc", 5   },
        { "manrabbit_tail",             "oinc", 5   },
        { "rabbithouse_blueprint",      "oinc", 50  },
		
		--hamlet nonrenewables
        -- { "dug_nettle",                 "oinc", 5   },

        --others
        { "red_cap",                         "oinc", 1   },
        { "moon_cap",                        "oinc", 10  },
        { "tentaclespots",                   "oinc", 5   },
        { "bee",                             "oinc", 5   },
        { "beebox_blueprint",                "oinc", 100 },
        { "saltbox_blueprint",               "oinc", 100 },
        { "soil_amender",                    "oinc", 10  },
        { "premiumwateringcan",              "oinc", 50  },
        { "glasscutter_blueprint",           "oinc", 200 },
        { "nightstick_blueprint",            "oinc", 100 },
        { "dragonflyfurnace_blueprint",      "oinc", 200 },
        
    },
	skyworthy_shop_2 = { --TODO: split into multiple rooms
		
		--ruins
        --[[{ "skeletonhat",            "oinc", 100  },
        { "armorskeleton",              "oinc", 100  },
        { "thurible",                   "oinc", 100  },]]--
        
        { "yellowamulet",				"relic_1", 1  },
        { "greenamulet",				"relic_2", 1  },
        { "orangeamulet",				"relic_3", 1  },
        { "yellowstaff",				"relic_1", 1  },
        { "greenstaff", 				"relic_2", 1  },
        { "orangestaff",				"relic_3", 1  },
        { "opalstaff",					"relic_1", 1  },
    },
	skyworthy_shop_3 = { --TODO: split into multiple rooms
		
		--moonquay
        { "dug_bananabush",            "oinc", 10   },
        { "palmcone_seed",             "oinc", 5    },
        { "turf_monkey_ground",        "oinc", 2    },
        { "dock_kit",                  "oinc", 5    },
        { "dock_woodposts_item",       "oinc", 5    },
        { "boat_cannon_kit",           "oinc", 20   },
        { "cannonball_rock_item",      "oinc", 3    },
		
		--lunar
        { "dug_rock_avocado_bush",          "oinc", 10  },
        { "bullkelp_root",                  "oinc", 5   },
		
		--toad
        { "shroom_skin",                    "oinc", 20  },
        { "mushroom_light_blueprint",       "oinc", 30  },
        { "mushroom_light2_blueprint",      "oinc", 30  },
    },
}

return {SHOPTYPES = SHOPTYPES}