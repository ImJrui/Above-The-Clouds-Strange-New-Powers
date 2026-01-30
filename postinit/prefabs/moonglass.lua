local AddPrefabPostInit = AddPrefabPostInit

GLOBAL.setfenv(1, GLOBAL)

local function postinit_fn(inst)
	inst:AddTag("smeltable")
end

AddPrefabPostInit("moonglass", postinit_fn)