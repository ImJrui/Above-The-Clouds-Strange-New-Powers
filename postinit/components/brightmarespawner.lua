local AddComponentPostInit = AddComponentPostInit
GLOBAL.setfenv(1, GLOBAL)

AddComponentPostInit("brightmarespawner", function(self, inst)
    if not TheWorld.ismastersim or TheWorld:HasTag("porkland") then
        return
    end

    local FindGestaltSpawnPtForPlayer, scope_fn, i = ToolUtil.GetUpvalue(self.FindRelocatePoint, "FindGestaltSpawnPtForPlayer")
    if not FindGestaltSpawnPtForPlayer then
        return
    end

    local function _FindGestaltSpawnPtForPlayer(player, wantstomorph)
        if player:GetIsInInterior() then
            return nil
        end

        return FindGestaltSpawnPtForPlayer(player, wantstomorph)
    end

    debug.setupvalue(scope_fn, i, _FindGestaltSpawnPtForPlayer)
end)