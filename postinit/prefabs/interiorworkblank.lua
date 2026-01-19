local AddPrefabPostInit = AddPrefabPostInit

GLOBAL.setfenv(1, GLOBAL)

AddPrefabPostInit("interiorworkblank", function(inst)
    inst:AddTag("quake_blocker")
    inst:AddTag("antlion_sinkhole_blocker")
end) 
