local AddComponentPostInit = AddComponentPostInit

GLOBAL.setfenv(1, GLOBAL)

local WETNESS_SOURCE_WEATHER = "weather"
local DRY_THRESHOLD = TUNING.MOISTURE_DRY_THRESHOLD
local WET_THRESHOLD = TUNING.MOISTURE_WET_THRESHOLD

AddComponentPostInit("moistureoverride", function(self, inst)
    if TheWorld:HasTag("porkland") then
        return
    end
    
    local _DoUpdate = self.DoUpdate
    function self:DoUpdate(dt)
        if dt == nil then
            dt = GetTime() - self.last_update_time
        end
        self.last_update_time = GetTime()

        local rate_additive = self.rate_add:Get() * dt
        if rate_additive <= 0 then
            local CalculateWetnessRate, index, parent_fn = ToolUtil.GetUpvalue(TheWorld.net.components.weather.GetDebugString, "CalculateWetnessRate")
            local wetrate = CalculateWetnessRate(TheWorld.state.temperature, TheWorld.state.precipitationrate)
            self.rate_mult:SetModifier(WETNESS_SOURCE_WEATHER, wetrate)
        end

        self.wetness = math.clamp(self.wetness + self.rate_mult:Get() * dt + self.rate_add:Get() * dt, 0, TUNING.MAX_WETNESS)

        if self.wetness == 0 then
            self:Stop()
            self.inst:RemoveComponent("moistureoverride")
            return
        end

        if self.wetness > WET_THRESHOLD then
            self.inst:AddTag("temporary_wet")
        elseif self.wetness < DRY_THRESHOLD then
            self.inst:RemoveTag("temporary_wet")
        end
    end
end)