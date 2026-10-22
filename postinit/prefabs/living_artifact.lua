local AddPlayerPostInit = AddPlayerPostInit
local AddPrefabPostInit = AddPrefabPostInit
GLOBAL.setfenv(1, GLOBAL)

-- if true then
--     return
-- end

local function EnableGoggleVision(player)
    local playervision = player.components.playervision
    if not playervision then
        return
    end

    if player._plrebalance_ironlord_previous_forcegogglevision == nil then
        player._plrebalance_ironlord_previous_forcegogglevision = playervision.forcegogglevision
    end
    playervision:ForceGoggleVision(true)
    player:PushEvent("plrebalance_ironlordgogglevision")
end

local function DisableGoggleVision(player)
    local previous = player._plrebalance_ironlord_previous_forcegogglevision
    if previous == nil then
        return
    end

    player._plrebalance_ironlord_previous_forcegogglevision = nil
    if player.components.playervision then
        player.components.playervision:ForceGoggleVision(previous)
    end
    player:PushEvent("plrebalance_ironlordgogglevision")
end

-- The existing classified events also restore the local client's vision when joining in mech form.
AddPlayerPostInit(function(player)
    player:ListenForEvent("livingartifactoveron", EnableGoggleVision)
    player:ListenForEvent("livingartifactoveroff", DisableGoggleVision)
end)

AddPrefabPostInit("living_artifact", function(inst)
    if not TheWorld.ismastersim then
        return
    end

    local livingartifact = inst.components.livingartifact
    local _OnActivate = livingartifact.onactivatefn
    livingartifact:SetOnActivateFn(function(inst, player, instant)
        _OnActivate(inst, player, instant)

        -- On load, the original callback resolves inst.player from the item's owner.
        if inst.player and inst.player:HasTag("ironlord") then
            EnableGoggleVision(inst.player)
        end
    end)

    -- Revert removes the artifact; this also covers other ways of removing an active artifact.
    inst:ListenForEvent("onremove", function(inst)
        if inst.player and inst.player:IsValid() then
            DisableGoggleVision(inst.player)
        end
    end)
end)
