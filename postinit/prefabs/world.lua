local AddPrefabPostInit = AddPrefabPostInit
GLOBAL.setfenv(1, GLOBAL)

local cmp = {
    "interiorspawner",
    "worldpathfindermanager"
}

local sv_cmp = { -- server only
    "worldtimetracker",
    "decoratedgrave_ghostmanager",
    "linkeditemmanager",
    "interiorquaker",
    "worldsoundmanager",
    "clientundertile",
    "interiormaprevealer",
    "skyworthymanager",
    "interiorpathfinder",
    "pigtaxmanager",
}

AddPrefabPostInit("world", function(inst)
    if not TheNet:IsDedicated() then
        if not inst.components.interiorhudindicatablemanager then
            inst:AddComponent("interiorhudindicatablemanager")
        end
    end

    for _, v in ipairs(cmp) do
        if not inst.components[v] then
            inst:AddComponent(v)
        end
    end

    if not TheWorld.ismastersim then
        return
    end

    for _, v2 in ipairs(sv_cmp) do
        if not inst.components[v2] then
            inst:AddComponent(v2)
        end
    end

    -- 室内不会落鸟
    local birdspawner = inst.components.birdspawner
    if birdspawner and birdspawner.SetBirdTypesForTile then
        birdspawner:SetBirdTypesForTile(WORLD_TILES.INTERIOR, {})
    end
end)

