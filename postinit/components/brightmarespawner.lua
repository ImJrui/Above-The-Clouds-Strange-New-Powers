local AddComponentPostInit = AddComponentPostInit
GLOBAL.setfenv(1, GLOBAL)

AddComponentPostInit("brightmarespawner", function(self, inst)
    if TheWorld:HasTag("porkland") then return end
    
    if not TheWorld.ismastersim then
        return
    end

    local FindGestaltSpawnPtForPlayer_old, scope_fn, i = ToolUtil.GetUpvalue(self.FindRelocatePoint, "FindGestaltSpawnPtForPlayer")
    if not FindGestaltSpawnPtForPlayer_old then
        return
    end

    local function FindGestaltSpawnPtForPlayer_New(player, wantstomorph)
        if player:GetIsInInterior() then
            return nil
        end

        return FindGestaltSpawnPtForPlayer_old(player, wantstomorph)
    end

    debug.setupvalue(scope_fn, i, FindGestaltSpawnPtForPlayer_New)
end) 