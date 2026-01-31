local AddPrefabPostInit = AddPrefabPostInit

GLOBAL.setfenv(1, GLOBAL)

local function postinit_fn(inst)
	if not TheWorld:HasTag("porkland") then
		return
	end

	local bankbuild = "pl_slingshot_handles"
	inst.AnimState:SetBank(bankbuild)
	inst.AnimState:SetBuild(bankbuild)
	inst.AnimState:PlayAnimation("idle_slug")

	if not TheWorld.ismastersim then
		return inst
	end

	inst.swap_build = bankbuild
	-- inst.swap_symbol = def.swap_symbol
end

AddPrefabPostInit("slingshot_handle_sticky", postinit_fn)