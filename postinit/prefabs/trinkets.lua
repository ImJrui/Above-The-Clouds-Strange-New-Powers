local AddPrefabPostInit = AddPrefabPostInit

GLOBAL.setfenv(1, GLOBAL)

local function postinit_fn(inst)
	inst:AddTag("irreplaceable")
	if not TheWorld.ismastersim then
		return inst
	end
end

AddPrefabPostInit("trinket_giftshop_4", postinit_fn)
