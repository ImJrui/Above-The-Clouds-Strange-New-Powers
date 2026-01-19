local AddPrefabPostInit = AddPrefabPostInit

GLOBAL.setfenv(1, GLOBAL)

local function postinit_fn(inst)
	if not TheWorld.ismastersim or not TheWorld:HasTag("forest") then
		return inst
	end

	inst.components.lootdropper:AddChanceLoot("trinket_giftshop_4", 1)
end

AddPrefabPostInit("porkland_intro_basket", postinit_fn)
