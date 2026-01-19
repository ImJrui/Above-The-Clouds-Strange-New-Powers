
local AddPrefabPostInit = AddPrefabPostInit
local AddSimPostInit = AddSimPostInit
local PigShopExpander = PigShopExpander

GLOBAL.setfenv(1, GLOBAL)

--Warly design notes
--[[
1 - Warly starts with Potato, Garlic
2 - Warly can give seed packets to Miss Sow to get her to sell those seeds
3 - Warly can give a Sow's Contract to Swinesbury's Fine Grocer to get her to sell fully grown versions of seeds
4 - Warly can get DST crop seed packets and salt by donating to the wishing well
]]--

--[[
local item_prefabs = {
	"plrebalance_garlicpack",
	"plrebalance_onionpack",
	"plrebalance_tomatopack",
	"plrebalance_potatopack",
	"saltrock",
}

local extra_data_florist = {
	["plrebalance_potatopack"] = { "potato_seeds",        "oinc", 1  },
	["plrebalance_tomatopack"] = { "tomato_seeds",        "oinc", 1  },
	["plrebalance_garlicpack"] = { "garlic_seeds",        "oinc", 1  },
	["plrebalance_onionpack"] = { "onion_seeds",        "oinc", 1  },
}]]--

local extra_data_grocer = { --linked to Sow's Earmark
	["plrebalance_potatopack"] = { "potato",        "oinc", 3  },
	["plrebalance_tomatopack"] = { "tomato",        "oinc", 3  },
	["plrebalance_garlicpack"] = { "garlic",        "oinc", 3  },
	["plrebalance_onionpack"] = { "onion",        "oinc", 3  },
	--["saltrock"] = { "saltrock",        "oinc", 3  },
}

local extra_data_florist = {
	["potato_seeds"] = { "potato_seeds",        "oinc", 1  },
	["tomato_seeds"] = { "tomato_seeds",        "oinc", 1  },
	["garlic_seeds"] = { "garlic_seeds",        "oinc", 1  },
	["onion_seeds"] = { "onion_seeds",        "oinc", 1  },
	["pepper_seeds"] = { "pepper_seeds",        "oinc", 1  },
}

-- Traders

AddPrefabPostInit("pigman_florist_shopkeep", function(inst)

	if not inst.components.trader then return end
	
	local _ShouldAcceptItem = inst.components.trader.test
	
	local function ShouldAcceptItem(inst, item)
		local rv = PigShopExpander.AcceptExtraItem(inst, item, "CITY_PIG_SOW_ALREADY_HAVE_SEEDS", extra_data_florist)
		if rv ~= nil then return rv end
		
		return _ShouldAcceptItem(inst, item)
	end
	
    inst.components.trader:SetAcceptTest(ShouldAcceptItem)
	
	local _OnAccept = inst.components.trader.onaccept
	
	local function OnGetItemFromPlayer(inst, giver, item)
		if PigShopExpander.OnAcceptExtraItem(inst, giver, item, "CITY_PIG_SOW_ACCEPT_SEEDS", extra_data_florist) then
            return true
		end
		return _OnAccept(inst, giver, item)
	end
	
	inst.components.trader.onaccept = OnGetItemFromPlayer
	
	PigShopExpander.ExtraGoods_PostInit(inst, extra_data_florist)
end)