local tuber_tree_assets = {}

local tuber_tree_prefabs = {
    "twigs",
}

local nettle_assets = {}

local nettle_prefabs = {
    "twigs",
}

local valid_tiles = {
    ["nettle_sapling"] = {
        [WORLD_TILES.DEEPRAINFOREST] = true,
        [WORLD_TILES.DEEPRAINFOREST_NOCANOPY] = true,
    },
    ["tuber_tree_sapling"] = {
        [WORLD_TILES.PAINTED] = true,
    }
}

local valid_season = {
    ["nettle_sapling"] = function() return not TheWorld.state.iswinter end,
    ["tuber_tree_sapling"] = function() return TheWorld.state.issummer or TheWorld.state.islush end,
}

local valid_moisture = {
    ["nettle_sapling"] = true,
}

local function is_on_valid_tile(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local tile = TheWorld.Map:GetTileAtPoint(x, y, z)

    return valid_tiles[inst.prefab] and valid_tiles[inst.prefab][tile] or false
end

local function getstatus(inst)
    if valid_season[inst.prefab] and not valid_season[inst.prefab]() then
        return "WRONG_SEASON"
    elseif not is_on_valid_tile(inst) then
        return "WRONG_TILE"
    elseif valid_moisture[inst.prefab] and not inst.wet then
        return "WRONG_TOODRY"
    end
    return nil
end

local function UpdateMoisture(inst)
    local moisture = inst.components.moistureoverride and inst.components.moistureoverride.wetness or TheWorld.state.wetness
    -- if (moisture or TheWorld.state.israining) and not inst.components.moistureoverride then
    --     inst:AddComponent("moistureoverride")
    -- end
    if moisture > TUNING.NETTLE_MOISTURE_WET_THRESHOLD then -- ready to grow
        inst.wet = true
    elseif moisture > TUNING.NETTLE_MOISTURE_DRY_THRESHOLD and inst.wet == true then
        -- if wet, keep wet
    elseif moisture > 0 then -- still a bit dry
        inst.wet = false
        -- don't pause growth just yet, give players some time
    else -- too dry
        inst.wet = false
    end
end

local function UpdateGrowthStatus(inst)
    if inst.wet ~= nil then UpdateMoisture(inst) end

    if getstatus(inst) == nil then
        if inst.components.timer:IsPaused("grow") then
            inst.components.timer:ResumeTimer("grow")
        end
    else
        if not inst.components.timer:IsPaused("grow") then
            inst.components.timer:PauseTimer("grow")
        end
    end
end

local function growtree(inst)
    local tree = SpawnPrefab(FunctionOrValue(inst.growprefab, inst))
    if tree then
        tree.Transform:SetPosition(inst.Transform:GetWorldPosition())
        if inst.wet then
            local wetness = inst.components.moistureoverride and inst.components.moistureoverride.wetness
            if wetness then
                tree:AddComponent("moistureoverride")
                tree.components.moistureoverride:AddOnce(wetness)
                tree:StartUpdatingComponent(tree.components.moistureoverride)               
            end
        end
        tree:growfromseed()
        inst:Remove()
    end
end

local function stopgrowing(inst)
    inst.components.timer:StopTimer("grow")
end

local function ontimerdone(inst, data)
    if data.name == "grow" then
        growtree(inst)
    end
end

local function digup(inst, digger)
    inst.components.lootdropper:DropLoot()
    inst:Remove()
end

local function burr_growprefab_fn(inst)
    local x, y, z = inst.Transform:GetWorldPosition()

    if TheWorld.Map:GetTileAtPoint(x, y, z) == WORLD_TILES.GASJUNGLE then
        return "rainforesttree_rot"
    else
        return "rainforesttree"
    end
end

local function sapling_fn(build, anim, growprefab, tag, fireproof, overrideloot, override_growtime)
    local function start_growing(inst)
        if not inst.components.timer:TimerExists("grow") then
            local base_time = override_growtime and override_growtime.base or TUNING.PINECONE_GROWTIME.base
            local random_time = override_growtime and override_growtime.random or TUNING.PINECONE_GROWTIME.random
            local growtime = GetRandomWithVariance(base_time, random_time)
            inst.components.timer:StartTimer("grow", growtime)
        end
    end

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()

        inst.AnimState:SetBank(build)
        inst.AnimState:SetBuild(build)
        inst.AnimState:PlayAnimation(anim)

        if not fireproof then
            inst:AddTag("plant")
        end

        if tag then
            inst:AddTag(tag)
        end

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.growprefab = growprefab
        inst.StartGrowing = start_growing

        inst:AddComponent("timer")
        inst:ListenForEvent("timerdone", ontimerdone)
        start_growing(inst)

        inst:AddComponent("inspectable")
        inst.components.inspectable.getstatus = getstatus

        inst:AddComponent("lootdropper")
        inst.components.lootdropper:SetLoot(overrideloot or {"twigs"})

        inst:AddComponent("workable")
        inst.components.workable:SetWorkAction(ACTIONS.DIG)
        inst.components.workable:SetOnFinishCallback(digup)
        inst.components.workable:SetWorkLeft(1)

        if not fireproof then
            MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
            inst:ListenForEvent("onignite", stopgrowing)
            inst:ListenForEvent("onextinguish", start_growing)
            MakeSmallPropagator(inst)

            MakeHauntableIgnite(inst)
        else
            MakeHauntableWork(inst)
        end

        if build == "nettle_sapling" then
            inst.wet = false
        end
        inst:DoPeriodicTask(1, UpdateGrowthStatus)

        return inst
    end

    return fn
end

return Prefab("tuber_tree_sapling", sapling_fn("tuber_tree_sapling", "idle_planted", "tubertree", nil, nil, nil, TUNING.ANCIENTTREE_GROW_TIME[1]), tuber_tree_assets, tuber_tree_prefabs),
    Prefab("nettle_sapling", sapling_fn("nettle_sapling", "idle_planted", "nettle", nil, nil, nil, TUNING.ANCIENTTREE_GROW_TIME[1]), nettle_assets, nettle_prefabs)
