local AddPrefabPostInit = AddPrefabPostInit
GLOBAL.setfenv(1, GLOBAL)

AddPrefabPostInit("snowball", function(inst)
    if not TheWorld.ismastersim or TheWorld:HasTag("porkland") then
        return
    end

    inst.components.wateryprotection.addcoldness = 2
end)
