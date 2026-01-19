local assets =
{
    Asset("ANIM", "anim/seedofruin.zip"),
}

local function OnFinished(inst, regenType)
    inst:Remove()
	-- if regenType ~= "SMALLRUINS" then
	-- 	inst:Remove()
	-- end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("seedofruin")
    inst.AnimState:SetBuild("seedofruin")
    inst.AnimState:PlayAnimation("idle_loop", true)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
	
    inst:AddComponent("plrebalance_ruinsregenerating")
	inst.components.plrebalance_ruinsregenerating.OnFinished = OnFinished

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("seedofruin", fn, assets)
