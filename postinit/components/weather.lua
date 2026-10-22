local AddComponentPostInit = AddComponentPostInit
GLOBAL.setfenv(1, GLOBAL)

AddComponentPostInit("weather", function(self, inst)
    if TheWorld:HasTag("porkland") then
        return
    end

    if TheWorld.ismastersim then
        local OnSendLightningStrike = inst:GetEventCallbacks("ms_sendlightningstrike", TheWorld, "scripts/components/weather.lua")
        if OnSendLightningStrike then
            inst:RemoveEventCallback("ms_sendlightningstrike", OnSendLightningStrike, TheWorld)

            inst:ListenForEvent("ms_sendlightningstrike", function(src, pos, ...)
                -- Match plateauweather: cancel strikes whose initial position is indoors.
                local interiorspawner = TheWorld.components.interiorspawner
                if interiorspawner and interiorspawner:IsInInteriorRegion(pos.x, pos.z) then
                    return
                end

                return OnSendLightningStrike(src, pos, ...)
            end, TheWorld)
        end
    end

    if TheNet:IsDedicated() or not self.OnUpdate then
        return
    end

    local OnUpdate = self.OnUpdate
    local function HookRainSound(start_name, stop_name)
        local StartRainSound, scope_fn, index = ToolUtil.GetUpvalue(OnUpdate, start_name)
        local StopRainSound = ToolUtil.GetUpvalue(OnUpdate, stop_name)
        if not StartRainSound or not StopRainSound then
            return
        end

        local function StartRainSoundInExterior(...)
            -- Read the live upvalue so entering/leaving or changing players takes effect.
            local player = ToolUtil.GetUpvalue(OnUpdate, "_activatedplayer") or ThePlayer
            if player and player:GetIsInInterior() then
                StopRainSound()
                return
            end

            return StartRainSound(...)
        end

        -- OnUpdate and LongUpdate share these upvalues; both use the new functions.
        debug.setupvalue(scope_fn, index, StartRainSoundInExterior)
    end

    HookRainSound("StartAmbientRainSound", "StopAmbientRainSound")
    HookRainSound("StartTreeRainSound", "StopTreeRainSound")
    HookRainSound("StartUmbrellaRainSound", "StopUmbrellaRainSound")
end)
