local AddPrefabPostInit = AddPrefabPostInit
local AddComponentPostInit = AddComponentPostInit

GLOBAL.setfenv(1, GLOBAL)

---touch stone
AddPrefabPostInit("resurrectionstone", function (inst)
    if not TheWorld:HasTag("porkland") or not TheWorld.ismastersim then
        return
    end
    if inst.components.lootdropper then
        inst.components.lootdropper:SetLoot({"rocks", "rocks", "nightmarefuel"})
    end
end)