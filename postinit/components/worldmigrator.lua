local AddPrefabPostInit = AddPrefabPostInit
local AddComponentPostInit = AddComponentPostInit

GLOBAL.setfenv(1, GLOBAL)

AddComponentPostInit("worldmigrator", function(self)
    self.linkedWorldType = nil

    local _ValidateAndPushEvents = self.ValidateAndPushEvents
    function self:ValidateAndPushEvents()
        _ValidateAndPushEvents(self)
    end
end)
local function SetLinkedWorldType(portal, world_type)
    local function fn(inst)
        if not TheWorld.ismastersim then
            return inst
        end

        inst.components.worldmigrator.auto = false
        inst.components.worldmigrator.linkedWorldType = world_type
    end

    AddPrefabPostInit(portal, fn)
end

SetLinkedWorldType("cave_entrance_open", PL_WORLDTYPE.CAVE)
SetLinkedWorldType("cave_entrance", PL_WORLDTYPE.CAVE)
SetLinkedWorldType("oceanwhirlbigportal", PL_WORLDTYPE.CAVE)

SetLinkedWorldType("cave_exit", PL_WORLDTYPE.FOREST)
SetLinkedWorldType("oceanwhirlbigportalexit", PL_WORLDTYPE.FOREST)


