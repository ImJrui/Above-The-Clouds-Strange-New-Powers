local prefabs =
{
    "dumbbell_marble",
}

local assets =
{
    Asset("ANIM", "anim/dumbbell_iron.zip"),
    Asset("ANIM", "anim/swap_dumbbell_iron.zip"),
}

-- See postinit/prefabs/pigskin.lua
local function fn()
    local inst = Prefabs["dumbbell_marble"].fn(TheSim)
    inst.AnimState:SetBank("dumbbell_iron")
    inst.AnimState:SetBuild("dumbbell_iron")
	inst.swap_dumbbell = "swap_" .. "dumbbell_iron"
    inst.swap_dumbbell_symbol = "swap_" .. "dumbbell_iron"
    inst.impact_sound = "wolfgang1/dumbbell/gold_impact"

    inst:AddTag("smeltable") -- Smelter
    return inst
end

return Prefab("dumbbell_iron", fn, assets, prefabs)