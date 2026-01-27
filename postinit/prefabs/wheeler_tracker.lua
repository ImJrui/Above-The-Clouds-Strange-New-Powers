local AddPrefabPostInit = AddPrefabPostInit

GLOBAL.setfenv(1, GLOBAL)

local function IsInSameIsland(inst, target)
    if not (target and target:IsValid()) then
        return false
    end

    return true
end

local function postinit_fn(inst)
    if TheWorld:HasTag("porkalnd") then
        return
    end

	inst.IsInSameIsland = IsInSameIsland
end

AddPrefabPostInit("wheeler_tracker", postinit_fn)