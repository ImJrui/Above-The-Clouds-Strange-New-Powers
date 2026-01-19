local assets =
{
    Asset("ANIM", "anim/newspices.zip"),
}

local function MakeSpice(name)
    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank("newspices")
        inst.AnimState:SetBuild("newspices")
        inst.AnimState:PlayAnimation("idle")
        inst.AnimState:OverrideSymbol("swap_spice", "newspices", name)
        inst.scrapbook_overridedata={"swap_spice", "newspices", name}

        inst:AddTag("spice")

        MakeInventoryFloatable(inst, "med", nil, (name == "spice_garlic" and 0.85) or 0.7)

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("stackable")
        inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

        inst:AddComponent("inspectable")
        inst:AddComponent("inventoryitem")


        MakeHauntableLaunch(inst)

        return inst
    end

    return Prefab(name, fn, assets)
end

return MakeSpice("spice_lotus")

