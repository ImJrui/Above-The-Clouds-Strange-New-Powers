
local assets =
{
    Asset("ANIM", "anim/sea_trinkets.zip"),
}

local TRADEFOR = {}

local function MakeTrinket(num, prefix)
    local prefabs = TRADEFOR[num]

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank("sea_trinkets")
        inst.AnimState:SetBuild("sea_trinkets")
        inst.AnimState:PlayAnimation(tostring(num))

        inst:AddTag("molebait")
        inst:AddTag("cattoy")
        inst:AddTag("trinket")

        MakeInventoryFloatable(inst)
        if num == 4 then
            inst.components.floater:UpdateAnimations(tostring(num).."_water", tostring(num))
        end

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("inspectable")

        inst:AddComponent("inventoryitem")

        inst:AddComponent("stackable")
        inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

        inst:AddComponent("tradable")
        inst.components.tradable.goldvalue = 5
        inst.components.tradable.dubloonvalue = 5
        -- inst.components.tradable.tradefor = TRADEFOR[num]

        inst.components.tradable.rocktribute = math.ceil(inst.components.tradable.goldvalue / 3) -- for antlion

        MakeHauntableLaunch(inst)

        inst:AddComponent("bait")

        return inst
    end

    return Prefab(prefix .. tostring(num), fn, assets, prefabs)
end

local ret = {}
for k = 1, 5 do
    table.insert(ret, MakeTrinket(k, "sunken_boat_trinket_"))
end
return unpack(ret)
