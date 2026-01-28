local AddPrefabPostInit = AddPrefabPostInit
local AddSimPostInit = AddSimPostInit
GLOBAL.setfenv(1, GLOBAL)

local function postinit_fn(inst)
    if not TheWorld.ismastersim then
        return
    end

    inst:AddComponent("simplemagicgrower")
    inst.components.simplemagicgrower:SetLastStage(#inst.components.growable.stages)
end

local trees = {
    "clawpalmtree",
    "clawpalmtree_normal",
    "clawpalmtree_tall",
    "clawpalmtree_short",
    "teatree",
    "teatree_short",
    "teatree_normal",
    "teatree_tall",
    -- "tubertree",
    -- "tubertree_tall",
    -- "tubertree_short",
}

for _,tree in pairs(trees) do
    AddPrefabPostInit(tree, postinit_fn)
end

