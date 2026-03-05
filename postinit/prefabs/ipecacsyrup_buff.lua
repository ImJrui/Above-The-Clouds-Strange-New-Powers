local AddPrefabPostInit = AddPrefabPostInit

GLOBAL.setfenv(1, GLOBAL)

local IPECAC_TICK_TIMERNAME = "pooptick"

local function buff_DoTick(inst)
    if inst._tick_count <= 0 then
        inst.components.debuff:Stop()
    else
        inst._tick_count = inst._tick_count - 1
        inst.components.timer:StartTimer(IPECAC_TICK_TIMERNAME, TUNING.IPECAC_TICK_TIME)
    end

    local target = inst.components.debuff.target
    if target then
        if target:HasTag("city_pig") and (not target:IsValid() or target:IsInLimbo()) then
            return
        end

        local poop = SpawnPrefab("poop")

        poop.Transform:SetPosition(target.Transform:GetWorldPosition())

		if target.components.citypossession and target.components.citypossession.cityID then
			poop.cityID = target.components.citypossession.cityID
			TheWorld.components.periodicpoopmanager:OnPoop(poop.cityID, poop)
		end

        local periodicspawner = target.components.periodicspawner
        if periodicspawner ~= nil and periodicspawner.onspawn ~= nil then
            periodicspawner.onspawn(target, poop)
        end

        target:PushEvent("ipecacpoop")

        local target_health = target.components.health

        if target_health then
            target_health:DoDelta(-TUNING.IPECAC_DAMAGE_PER_TICK, nil, inst.prefab, nil, inst)
        end
    end
end

local function buff_OnTimerDone(inst, data)
    if data.name == IPECAC_TICK_TIMERNAME then
        buff_DoTick(inst)
    end
end

local function postinit_fn(inst)
    if not TheWorld.ismastersim then
        return
    end

    local _buff_OnTimerDone = inst:GetEventCallbacks("timerdone", nil, "scripts/prefabs/ipecacsyrup.lua")
    inst:RemoveEventCallback("timerdone", _buff_OnTimerDone)
	inst:ListenForEvent("timerdone", buff_OnTimerDone)
end

AddPrefabPostInit("ipecacsyrup_buff", postinit_fn)