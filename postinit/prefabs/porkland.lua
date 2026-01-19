local AddPrefabPostInit = AddPrefabPostInit
local AddComponentPostInit = AddComponentPostInit
local AddSimPostInit = AddSimPostInit

GLOBAL.setfenv(1, GLOBAL)

local worlds = {"porkland" ,"shipwrecked", "volcano", "forest", "cave"}

local function postinit_worlds(inst)

    if not inst.components.worldpathfindermanager then
        inst:AddComponent("worldpathfindermanager")
    end

    if not TheWorld.ismastersim then
        return
    end

    if not inst.components.decoratedgrave_ghostmanager then
        inst:AddComponent("decoratedgrave_ghostmanager")
    end
    if not inst.components.linkeditemmanager then
        inst:AddComponent("linkeditemmanager")
    end

    if not inst.components.interiorspawner then
        inst:AddComponent("interiorspawner")
    end

    if not inst.components.interiorquaker then
        inst:AddComponent("interiorquaker")
    end
    if not inst.components.worldsoundmanager then
        inst:AddComponent("worldsoundmanager")
    end
    if not inst.components.clientundertile then
        inst:AddComponent("clientundertile")
    end
    if not inst.components.interiormaprevealer then
        inst:AddComponent("interiormaprevealer")
    end
    if not inst.components.skyworthymanager then
        inst:AddComponent("skyworthymanager")
    end
    if not inst.components.interiorpathfinder then
        inst:AddComponent("interiorpathfinder")
    end
    if not inst.components.pigtaxmanager then
        inst:AddComponent("pigtaxmanager")
    end
end

for i = 1, #worlds do
    AddPrefabPostInit(worlds[i],postinit_worlds)
end
