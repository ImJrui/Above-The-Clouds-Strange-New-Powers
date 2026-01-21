local AddPrefabPostInit = AddPrefabPostInit

GLOBAL.setfenv(1, GLOBAL)

local function postinit_fn(inst)
	inst:AddTag("silviculture")
end

AddPrefabPostInit("grass_tall", postinit_fn)