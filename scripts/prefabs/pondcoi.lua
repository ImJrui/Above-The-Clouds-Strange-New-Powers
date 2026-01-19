local prefabs =
{
    "pondfish",
}

-- See postinit/prefabs/pigskin.lua
local function fn()
    local inst = Prefabs["pondfish"].fn(TheSim)
    inst.is_coi = true
    inst:SetPrefabName("pondfish")
    return inst
end

return Prefab("pondcoi", fn, {}, prefabs)