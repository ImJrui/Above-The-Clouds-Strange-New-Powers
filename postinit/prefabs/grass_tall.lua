local AddPrefabPostInit = AddPrefabPostInit

GLOBAL.setfenv(1, GLOBAL)

local function postinit_fn(inst)
	if not TheWorld:HasTag("forest") then return end

    inst:AddTag("lunarplant_target")

	if not TheWorld.ismastersim then
		return inst
	end
	
	inst:DoTaskInTime(0, function()
		if TheWorld.components.lunarthrall_plantspawner and inst:HasTag("lunarplant_target") then
			TheWorld.components.lunarthrall_plantspawner:setHerdsOnPlantable(inst)
		end
	end)
end

AddPrefabPostInit("grass_tall", postinit_fn)