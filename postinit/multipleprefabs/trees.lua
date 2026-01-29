local AddPrefabPostInit = AddPrefabPostInit
local AddSimPostInit = AddSimPostInit
GLOBAL.setfenv(1, GLOBAL)

local function postinit_fn(inst)
    if not TheWorld.ismastersim then
        return
    end
    if inst.components.growable then
        inst:AddComponent("simplemagicgrower")
        inst.components.simplemagicgrower:SetLastStage(#inst.components.growable.stages)
    end
end

AddPrefabPostInit("clawpalmtree", postinit_fn)
AddPrefabPostInit("teatree", postinit_fn)
AddPrefabPostInit("tubertree", postinit_fn)

