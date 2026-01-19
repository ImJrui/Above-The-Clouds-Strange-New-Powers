local AddPrefabPostInit = AddPrefabPostInit

GLOBAL.setfenv(1, GLOBAL)

PICKABLE_FOOD_PRODUCTS.cutnettle = true

local function ADD_SCRAPBOOK_DEPS(inst)
	inst:AddComponent("plrebalance_walteraimedshot")

	local SCRAPBOOK_DEPS = inst.scrapbook_adddeps or {}
    local NEW_SCRAPBOOK_DEPS =
    {
		-- "slingshotammo_shadow",
		"slingshotammo_infused",
		"slingshotammo_alloy",
    }
	for i = 1, #NEW_SCRAPBOOK_DEPS do
        table.insert(SCRAPBOOK_DEPS, NEW_SCRAPBOOK_DEPS[i])
    end
    inst.scrapbook_adddeps = SCRAPBOOK_DEPS
end

AddPrefabPostInit("slingshot", ADD_SCRAPBOOK_DEPS)

local function ImpactFx(inst, attacker, target)
    if not inst.noimpactfx and target ~= nil and target:IsValid() then
		local impactfx = SpawnPrefab(inst.ammo_def.impactfx)
		impactfx.Transform:SetPosition(target.Transform:GetWorldPosition())
    end
end

local function OnHit(inst, attacker, target)	
    if inst.ammo_def.onhitnoncombat and target ~= nil and target:IsValid() and target.components.combat == nil then
		ImpactFx(inst, attacker, target)
		inst.ammo_def.onhitnoncombat(inst, attacker, target)
	end
	inst:Remove()
	
end

local function slingshotammo_infused_proj_forcedexplode(inst)
	inst.AnimState:SetLightOverride(1)
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
	inst.entity:AddLight()
	inst.Light:SetIntensity(0.6)
	inst.Light:SetRadius(1)
	inst.Light:SetFalloff(0.7)
	inst.Light:SetColour(1, 0.2, 0.3)
	inst.Light:Enable(true)

	if not TheWorld.ismastersim then
        return
    end
	
	inst.components.projectile:SetOnHitFn(OnHit)--always explode no matter what
	inst.components.projectile:SetOnMissFn(OnHit)
end


AddPrefabPostInit("slingshotammo_infused_proj",slingshotammo_infused_proj_forcedexplode)

local function OnDropped(inst)
    inst.Light:Enable(true)
end

local function OnPutInInventory(inst)
    inst.Light:Enable(false)
end

local function slingshotammo_infused_addlight(inst)
	inst.AnimState:SetLightOverride(1)
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
	inst.entity:AddLight()
	inst.Light:SetIntensity(0.6)
	inst.Light:SetRadius(0.5)
	inst.Light:SetFalloff(0.7)
	inst.Light:SetColour(1, 0.2, 0.3)
	inst.Light:Enable(true)

	if not TheWorld.ismastersim then
        return
    end

	if not inst.components.inventoryitem then
		inst:AddComponent("inventoryitem")
	end
	inst.components.inventoryitem:SetOnDroppedFn(OnDropped)
    inst.components.inventoryitem:SetOnPutInInventoryFn(OnPutInInventory)
end


AddPrefabPostInit("slingshotammo_infused",slingshotammo_infused_addlight)

local function slingshotammo_scrapfeather_proj_postinit(inst)
	if not TheWorld:HasTag("porkland") then
		return
	end
    inst.AnimState:SetBank("newslingshotammo")
    inst.AnimState:SetBuild("newslingshotammo")

	local ammo_def = inst.ammo_def
	if ammo_def.spinloop then
		inst.AnimState:PlayAnimation(ammo_def.spinloop, true)
	else
		inst.AnimState:PlayAnimation("spin_loop", true)
		if ammo_def.symbol then
			inst.AnimState:OverrideSymbol("rock", "newslingshotammo", ammo_def.symbol)
		end
	end
end

AddPrefabPostInit("slingshotammo_scrapfeather_proj",slingshotammo_scrapfeather_proj_postinit)

local function slingshotammo_scrapfeather_postinit(inst)
	if not TheWorld:HasTag("porkland") then
		return
	end

	inst.AnimState:SetBank("newslingshotammo")
    inst.AnimState:SetBuild("newslingshotammo")
	inst.AnimState:PlayAnimation("idle_scrapfeather", true)
	inst.scrapbook_overridedata = { "rock", "newslingshotammo", "scrapfeather" }

	if not TheWorld.ismastersim then
        return
    end

	if inst.components.inventoryitem then
        inst.components.inventoryitem:ChangeImageName("slingshotammo_scrapfeather_hamlet")
	end
end

AddPrefabPostInit("slingshotammo_scrapfeather",slingshotammo_scrapfeather_postinit)