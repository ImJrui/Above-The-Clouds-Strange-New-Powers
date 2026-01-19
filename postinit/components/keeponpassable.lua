local AddComponentPostInit = AddComponentPostInit
GLOBAL.setfenv(1, GLOBAL)


AddComponentPostInit("keeponpassable", function(self, inst)
    local _FallingTest = self.FallingTest
    function self:FallingTest(type)
        if not TheWorld:HasTag("porkland") and (type == "drowning" or type == "gravity") then
            return
        end
        _FallingTest(self, type)
    end
end)
