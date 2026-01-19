local AddComponentPostInit = AddComponentPostInit
GLOBAL.setfenv(1, GLOBAL)

local function DefaultClockPostInIt(self, inst)
    local _world = TheWorld

    inst:ListenForEvent("ms_setclocksegs_default", self.clocks["default"]["ms_setclocksegs"], _world)
    inst:ListenForEvent("ms_setmoonphase_default", self.clocks["default"]["ms_setmoonphase"], _world)
    inst:ListenForEvent("ms_lockmoonphase_default", self.clocks["default"]["ms_lockmoonphase"], _world)

    if TheWorld.ismastersim then
        local _OnSave = self.OnSave
        function self:OnSave(...)
            local data = _OnSave(self, ...)
            data.moonphaselockeddefault = ToolUtil.GetUpvalue(self.clocks["default"]["ms_lockmoonphase"], "_moonphaselocked")
            return data
        end
        local _OnLoad = self.OnLoad
        function self:OnLoad(data, ...)
            ToolUtil.SetUpvalue(self.clocks["default"]["ms_lockmoonphase"], "_moonphaselocked", data.moonphaselockeddefault)
            return _OnLoad(self, data, ...)
        end
    end

end

AddComponentPostInit("clock", function(self, inst)
    local _world = TheWorld
    local _ismastersim = _world.ismastersim
    local _ismastershard = _world.ismastershard

    DefaultClockPostInIt(self, inst)

    if _ismastersim and not _ismastershard and self.current_clock == "plateau" then
        local _OnClockUpdate = inst:GetEventCallbacks("secondary_clockupdate", _world, "scripts/components/clock.lua")
        inst:RemoveEventCallback("secondary_clockupdate", _OnClockUpdate, _world)
    end
end)
