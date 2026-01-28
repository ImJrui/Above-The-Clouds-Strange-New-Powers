local assets ={}
local prefabs = {}

local function ondeploy(inst, pt, deployer)
    local tree = SpawnPrefab("nettle_sapling")
    if tree ~= nil then
        tree.Transform:SetPosition(pt:Get())
        inst.components.stackable:Get():Remove()
        if tree.components.pickable ~= nil then
            tree.components.pickable:OnTransplant()
        end
        if deployer ~= nil and deployer.SoundEmitter ~= nil then
            --V2C: WHY?!! because many of the plantables don't
            --     have SoundEmitter, and we don't want to add
            --     one just for this sound!
            deployer.SoundEmitter:PlaySound("dontstarve/common/plant")
        end

        if TheWorld.components.lunarthrall_plantspawner and tree:HasTag("lunarplant_target") then
            TheWorld.components.lunarthrall_plantspawner:setHerdsOnPlantable(tree)
        end
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    MakeInventoryFloatable(inst)
    -- inst.components.floater:UpdateAnimations("dropped_water", "dropped")

    inst.AnimState:SetBank("nettle_sapling_item")
    inst.AnimState:SetBuild("nettle_sapling_item")
    inst.AnimState:PlayAnimation("idle")

    inst.MiniMapEntity:SetIcon("nettle.tex")

    inst:AddTag("deployedplant")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.SMALL_FUEL

    inst:AddComponent("deployable")
    inst.components.deployable.ondeploy = ondeploy
    inst.components.deployable:SetDeployMode(DEPLOYMODE.PLANT)
    -- inst.components.deployable:SetDeploySpacing(DEPLOYSPACING.MEDIUM)

    MakeMediumBurnable(inst, TUNING.LARGE_BURNTIME)
    MakeSmallPropagator(inst)
    MakeHauntableLaunchAndIgnite(inst)

    return inst
end

return
    Prefab("nettle_sapling_item", fn, assets, prefabs),
    MakePlacer("nettle_sapling_item_placer", "nettle_sapling", "nettle_sapling", "idle_planted")


