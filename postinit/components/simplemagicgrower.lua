local AddPrefabPostInit = AddPrefabPostInit
local AddComponentPostInit = AddComponentPostInit

GLOBAL.setfenv(1, GLOBAL)

AddComponentPostInit("simplemagicgrower", function(self)
    local _Grow = self.Grow
    function self:Grow()
        if _Grow then
            _Grow(self)
        end
        local inst = self.inst
        if inst.prefab == "tubertree" and inst.tubers < inst.maxtubers then
            inst.tubers = inst.maxtubers
            local stages = inst.components.growable.stages
            local growfn = stages[#stages].growfn
            if growfn then
                growfn(inst)
            end
        end
    end
end)



