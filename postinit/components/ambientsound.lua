local AddComponentPostInit = AddComponentPostInit
GLOBAL.setfenv(1, GLOBAL)

AddComponentPostInit("ambientsound", function(self, inst)
    if TheWorld:HasTag("porkland") or TheNet:IsDedicated() or not self.OnUpdate then
        return
    end

    local OnUpdate = self.OnUpdate
    local waves_enabled, _, enabled_index = ToolUtil.GetUpvalue(OnUpdate, "_wavesenabled")
    local _, position_scope, position_index = ToolUtil.GetUpvalue(OnUpdate, "_lastplayerpos")
    if not enabled_index or not position_scope or not position_index then
        print("[Above The Clouds - Strange New Powers] Missing ambient wave state; keeping current sounds.")
        return
    end

    local in_interior = false
    local SetWavesEnabled = self.SetWavesEnabled
    function self:SetWavesEnabled(enabled)
        waves_enabled = enabled
        -- The mixer caches the player's position; refresh even when the player has not moved.
        debug.setupvalue(position_scope, position_index, nil)
        return SetWavesEnabled(self, enabled and not in_interior)
    end

    function self:OnUpdate(...)
        local inside = ThePlayer ~= nil and ThePlayer:GetIsInInterior()
        if inside ~= in_interior then
            in_interior = inside
            self:SetWavesEnabled(waves_enabled)
        end
        return OnUpdate(self, ...)
    end
end)
