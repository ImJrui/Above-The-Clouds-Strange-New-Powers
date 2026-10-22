local AddComponentPostInit = AddComponentPostInit
GLOBAL.setfenv(1, GLOBAL)

AddComponentPostInit("lunarhailmanager", function(self, inst)
    if not TheWorld.ismastersim or TheWorld:HasTag("porkland") then
        return
    end

    local OnPlayerJoined = inst:GetEventCallbacks("ms_playerjoined", TheWorld, "scripts/components/lunarhailmanager.lua")
    if not OnPlayerJoined then return end

    local ScheduleDrop = ToolUtil.GetUpvalue(OnPlayerJoined, "ScheduleDrop")
    if not ScheduleDrop then return end

    local DoDropForPlayer, scope_fn, i = ToolUtil.GetUpvalue(ScheduleDrop, "DoDropForPlayer")
    if not DoDropForPlayer then return end

    local function _DoDropForPlayer(player, reschedulefn)
        if player:GetIsInInterior() then
            reschedulefn(player)
            return
        end

        return DoDropForPlayer(player, reschedulefn)
    end

    debug.setupvalue(scope_fn, i, _DoDropForPlayer)
end)