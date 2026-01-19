require "prefabutil"

local cooking = require("cooking")

local assets =
{
    Asset("ANIM", "anim/portable_spicer.zip"),
    Asset("ANIM", "anim/new_cook_pot_food.zip"),
    Asset("ANIM", "anim/plate_food.zip"),
    Asset("ANIM", "anim/spices.zip"),
    Asset("ANIM", "anim/newspices.zip"),
    Asset("ANIM", "anim/ui_cookpot_1x2.zip"),
    Asset("ANIM", "anim/portable_cook_pot.zip"),
    Asset("ANIM", "anim/cook_pot_food.zip"),
    Asset("ANIM", "anim/ui_cookpot_1x4.zip"),
}

local assets_item =
{
    Asset("ANIM", "anim/portable_spicer.zip"),
    Asset("ANIM", "anim/portable_cook_pot.zip"),
}

local prefabs =
{
    "collapse_small",
    "ash",
    "portablespicer_item",
}

-------------------------------------------------------------------------

for k, v in pairs(cooking.recipes.portablespicer) do
    table.insert(prefabs, v.name)

	if v.overridebuild then
        table.insert(assets, Asset("ANIM", "anim/"..v.overridebuild..".zip"))
	end
end

local prefabs_item =
{
    "portablespicer",
}

local function portablespicer_ShowProduct(inst)
    if not inst:HasTag("burnt") then
        local product = inst.components.stewer.product
        local recipe = cooking.GetRecipe(inst.prefab, product)
        if recipe ~= nil then
            product = recipe.basename or product
            if recipe.spice ~= nil then
                inst.AnimState:OverrideSymbol("swap_plate", "plate_food", "plate")
                inst.AnimState:OverrideSymbol("swap_garnish", "newspices", string.lower(recipe.spice))
            else
                inst.AnimState:ClearOverrideSymbol("swap_plate")
                inst.AnimState:ClearOverrideSymbol("swap_garnish")
            end
        else
            inst.AnimState:ClearOverrideSymbol("swap_plate")
            inst.AnimState:ClearOverrideSymbol("swap_garnish")
        end

        local build =
            (recipe ~= nil and recipe.overridebuild) or
            (IsModCookingProduct(inst.prefab, product) and product) or
            "cook_pot_food"
        local overridesymbol = recipe ~= nil and recipe.overridesymbolname or product
        inst.AnimState:OverrideSymbol("swap_cooked", build, overridesymbol)
    end
end

local function portablespicer_donecookfn(inst)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("cooking_pst")
        inst.AnimState:PushAnimation("idle_full", false)
        portablespicer_ShowProduct(inst)
        inst.SoundEmitter:KillSound("snd")
        inst.SoundEmitter:PlaySound("dontstarve/common/together/portable/spicer/cooking_pst")
    end
end

local function portablespicer_continuedonefn(inst)
    if not inst:HasTag("burnt") then 
        inst.AnimState:PlayAnimation("idle_full")
        portablespicer_ShowProduct(inst)
    end
end

AddPrefabPostInit("portablespicer",function(inst)
    if not TheWorld.ismastersim then
        return
    end
    if not inst.components.stewer then
        inst:AddComponent("stewer")
    end
        inst.components.stewer.oncontinuedone = portablespicer_continuedonefn
        inst.components.stewer.ondonecooking = portablespicer_donecookfn
end)