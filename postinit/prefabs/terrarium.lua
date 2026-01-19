local AddPrefabPostInit = AddPrefabPostInit

GLOBAL.setfenv(1, GLOBAL)

-------------------------------------------------------------------------------
local MAX_LIGHT_FRAME = 14
local MAX_LIGHT_RADIUS = 15

-- dframes is like dt, but for frames, not time
local function OnUpdateLight(inst, dframes)
    local done
    if inst._islighton:value() then
        local frame = inst._lightframe:value() + dframes
        done = frame >= MAX_LIGHT_FRAME
        inst._lightframe:set_local(done and MAX_LIGHT_FRAME or frame)
    else
        local frame = inst._lightframe:value() - dframes*3
        done = frame <= 0
        inst._lightframe:set_local(done and 0 or frame)
    end

    inst.Light:SetRadius(MAX_LIGHT_RADIUS * inst._lightframe:value() / MAX_LIGHT_FRAME)

    if done then
        inst._LightTask:Cancel()
        inst._LightTask = nil
    end
end

local function OnUpdateLightColour(inst)
	inst._lighttweener = inst._lighttweener + FRAMES * 1.25
	if inst._lighttweener > TWOPI then
		inst._lighttweener = inst._lighttweener - TWOPI
	end

    local red, green, blue
    if inst._iscrimson:value() then
        red = 0.90
        green = 0.20
        blue = 0.20
    else
	    local x = inst._lighttweener
	    local s = .15
	    local b = 0.85
	    local sin = math.sin

		red = sin(x) * s + b - s
		green = sin(x + 2/3 * PI) * s + b - s
		blue = sin(x - 2/3 * PI) * s + b - s
    end

	inst.Light:SetColour(red, green, blue)
end

local function OnLightDirty(inst)
    if inst._LightTask == nil then
        inst._LightTask = inst:DoPeriodicTask(FRAMES, OnUpdateLight, nil, 1)
    end
    OnUpdateLight(inst, 0)

	if not TheNet:IsDedicated() then
		if inst._islighton:value() then
			if inst._lightcolourtask == nil then
				inst._lighttweener = 0
				inst._lightcolourtask = inst:DoPeriodicTask(FRAMES, OnUpdateLightColour)
			end
		elseif inst._lightcolourtask ~= nil then
			inst._lightcolourtask:Cancel()
			inst._lightcolourtask = nil
		end
	end
end

local function is_crimson(inst)
    return inst._iscrimson:value()
end

-------------------------------------------------------------------------------
local function hookup_eye_listeners(inst, eye)
    inst:ListenForEvent("onremove", inst.on_end_eyeofterror_fn, eye)
    inst:ListenForEvent("turnoff_terrarium", inst.on_end_eyeofterror_fn, eye)

    inst:ListenForEvent("finished_leaving", inst.on_eye_left_fn, eye)
end
-------------------------------------------------------------------------------

local function enable_dynshadow(inst)
	if inst._ShadowDelayTask ~= nil then
		inst._ShadowDelayTask:Cancel()
		inst._ShadowDelayTask = nil
	end
    inst.DynamicShadow:Enable(true)
end

local function disable_dynshadow(inst)
	if inst._ShadowDelayTask ~= nil then
		inst._ShadowDelayTask:Cancel()
		inst._ShadowDelayTask = nil
	end
    inst.DynamicShadow:Enable(false)
end


local function TurnLightsOn(inst)
    inst._islighton:set(true)
    OnLightDirty(inst)
    inst._TurnLightsOnTask = nil
end

local function StartSummoning(inst, is_loading)
    if is_loading or
            (   inst.is_on and TheWorld.state.isnight and
                inst._summoning_fx == nil and
                not inst.components.timer:TimerExists("summon_delay")
            ) then

        -- Put the Terrarium itself into an untouchable state.
        inst.components.inventoryitem.canbepickedup = false
        inst.components.activatable.inactive = false
        inst.components.trader.enabled = false      -- no trading while beaming

        -- Spawn the summoning beam, if we do not have one (and we shouldn't)
        if inst._summoning_fx == nil then
            inst._summoning_fx = SpawnPrefab("terrarium_fx")
            inst._summoning_fx.entity:SetParent(inst.entity)
            inst._summoning_fx.AnimState:PlayAnimation("activate_fx")
            inst._summoning_fx.AnimState:PushAnimation("activated_idle_fx", true)
        end
        -- ...including a delayed light activation
        inst._TurnLightsOnTask = inst:DoTaskInTime(7 * FRAMES, TurnLightsOn)

        enable_dynshadow(inst)

        inst.SoundEmitter:KillSound("shimmer")
        inst.SoundEmitter:PlaySound("terraria1/terrarium/beam_loop", "beam")

        -- If we're not starting this summoning sequence via OnLoad, do some extra presentation,
        -- and also queue up a boss spawn.
        if not is_loading then
            if is_crimson(inst) then
                TheNet:Announce(STRINGS.TWINS_COMING)
            else
                TheNet:Announce(STRINGS.EYEOFTERROR_COMING)
            end
            inst.components.timer:StartTimer("warning", TUNING.TERRARIUM_WARNING_TIME)

            inst.SoundEmitter:PlaySound("terraria1/terrarium/beam_shoot")
        end
    end
end

local DEACTIVATE_TIME = 10*FRAMES
local function TurnOff(inst)
    if not inst.is_on then
        return
    end

    inst.is_on = false
    inst.components.activatable.inactive = TUNING.SPAWN_EYEOFTERROR
    inst.components.trader.enabled = true

    inst.components.timer:StopTimer("warning")

    if not inst.components.inventoryitem.canbepickedup then
        inst.components.inventoryitem.canbepickedup = true
    end

    inst.SoundEmitter:KillSound("shimmer")
    inst.SoundEmitter:KillSound("beam")

    if inst._TurnLightsOnTask ~= nil then
        inst._TurnLightsOnTask:Cancel()
        inst._TurnLightsOnTask = nil
    end
    inst._islighton:set(false)
    OnLightDirty(inst)

    if inst._summoning_fx ~= nil then
        inst._summoning_fx.AnimState:PlayAnimation("deactivate_fx")
        inst._summoning_fx:DoTaskInTime(DEACTIVATE_TIME, inst._summoning_fx.Remove)
        inst._summoning_fx = nil

        inst.SoundEmitter:PlaySound("terraria1/terrarium/beam_stop")
    end

    -- The Terrarium is in limbo when it's in an inventory or container.
    if inst:IsInLimbo() then
        inst.AnimState:PlayAnimation("idle", true)

        disable_dynshadow(inst)
    else
        inst.AnimState:PlayAnimation("deactivate")
        inst.AnimState:PushAnimation("idle", true)

		if inst._ShadowDelayTask ~= nil then
			inst._ShadowDelayTask:Cancel()
		end
        inst._ShadowDelayTask = inst:DoTaskInTime(4*FRAMES, disable_dynshadow)
    end
end

local function spawn_eye_prefab(inst)
    if is_crimson(inst) then
        return SpawnPrefab("twinmanager")
    else
        return SpawnPrefab("eyeofterror")
    end
end

local function NotInInterior(pt)
    return not TheWorld.components.interiorspawner:IsInInterior(pt.x, pt.z)
end

local SPAWN_OFFSET = 10
local function SpawnEyeOfTerror(inst)
    -- 更简洁的写法
    local cantarget_players = {}
    for i, player in ipairs(AllPlayers or {}) do
        if NotInInterior(player:GetPosition()) then
            table.insert(cantarget_players, player)
        end
    end

    if #cantarget_players == 0 then
        TheNet:Announce(STRINGS.EYEOFTERROR_CANCEL)
        TurnOff(inst)
        return
    end

    if cantarget_players ~= nil and #cantarget_players > 0 then
        local targeted_player = cantarget_players[math.random(#cantarget_players)]

        local announce_template = (is_crimson(inst) and STRINGS.TWINS_TARGET) or STRINGS.EYEOFTERROR_TARGET
        TheNet:Announce(subfmt(announce_template, {player_name = targeted_player.name}))

        local angle = math.random() * TWOPI
        local player_pt = targeted_player:GetPosition()
        local spawn_offset = FindWalkableOffset(player_pt, angle, SPAWN_OFFSET, nil, false, true, nil, true, true)
            or Vector3(SPAWN_OFFSET * math.cos(angle), 0, SPAWN_OFFSET * math.sin(angle))
        local spawn_position = player_pt + spawn_offset

        if inst.eyeofterror ~= nil and inst.eyeofterror:IsInLimbo() then
            inst.eyeofterror:ReturnToScene()
            inst.eyeofterror.Transform:SetPosition(spawn_position:Get())    -- Needs to be done so the spawn fx spawn in the right place
            if inst.eyeofterror.sg ~= nil then
                inst.eyeofterror.sg:GoToState("flyback", targeted_player)
            else
                inst.eyeofterror:PushEvent("flyback", targeted_player)
            end
        else
            inst.eyeofterror = spawn_eye_prefab(inst)
            inst.eyeofterror.Transform:SetPosition(spawn_position:Get())    -- Needs to be done so the spawn fx spawn in the right place
            if inst.eyeofterror.sg ~= nil then
                inst.eyeofterror.sg:GoToState("arrive", targeted_player)
            else
                inst.eyeofterror:PushEvent("arrive", targeted_player)
            end
        end
        inst.eyeofterror:PushEvent("set_spawn_target", targeted_player)

        hookup_eye_listeners(inst, inst.eyeofterror)
    end
end

local function OnCooldownOver(inst)
	inst.components.activatable.inactive = TUNING.SPAWN_EYEOFTERROR
	inst.AnimState:Show("terrarium_tree")
	inst.components.inventoryitem:ChangeImageName(nil) -- back to default
end

local function TimerDone(inst, data)
	local timer = data ~= nil and data.name
	if timer == "summon_delay" then
		StartSummoning(inst)
	elseif timer == "warning" then
		SpawnEyeOfTerror(inst)
	elseif timer == "cooldown" then
		OnCooldownOver(inst)
	end
end

-------------------------------------------------------------------------------

local function postinit_fn(inst)
	if not TheWorld.ismastersim then
		return inst
	end
    local _TimerDone = inst:GetEventCallbacks("timerdone", nil, "scripts/prefabs/terrarium.lua")
    inst:RemoveEventCallback("timerdone", _TimerDone)
    inst:ListenForEvent("timerdone", TimerDone)
end

AddPrefabPostInit("terrarium", postinit_fn)
