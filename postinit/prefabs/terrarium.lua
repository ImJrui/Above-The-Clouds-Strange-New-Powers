GLOBAL.setfenv(1, GLOBAL)

local function NotInInterior(pt)
    return not TheWorld.components.interiorspawner:IsInInterior(pt.x, pt.z)
end

AddPrefabRegisterPostInit("terrarium", function(terrarium_prefab)
    local fn = terrarium_prefab.fn
    if not fn then return end

    local _TimerDone, scope_fn_TD, idx_TD = ToolUtil.GetUpvalue(fn, "TimerDone")
    if not _TimerDone then return end

    local _SpawnEyeOfTerror, scope_fn_SEOT, idx_SEOT = ToolUtil.GetUpvalue(_TimerDone, "SpawnEyeOfTerror")
    if not _SpawnEyeOfTerror then return end

    local _on_night, scope_fn_night, idx_night = ToolUtil.GetUpvalue(fn, "on_night")
    if not _on_night then return end

    local _TurnOff , scope_fn_TO, idx_TO = ToolUtil.GetUpvalue(_on_night, "TurnOff")
    if not _TurnOff then return end

    debug.setupvalue(scope_fn_SEOT, idx_SEOT, function(inst, ...)

        local _AllPlayers = AllPlayers

        local can_target_players = {}
        for i, player in ipairs(AllPlayers or {}) do
            if NotInInterior(player:GetPosition()) then
                table.insert(can_target_players, player)
            end
        end

        if #can_target_players > 0 then
            AllPlayers = can_target_players

            _SpawnEyeOfTerror(inst, ...)

            AllPlayers = _AllPlayers
        else
            TheNet:Announce(STRINGS.EYEOFTERROR_CANCEL)
            _TurnOff(inst)
            return
        end

    end)
end)