local AddPrefabPostInit = AddPrefabPostInit

GLOBAL.setfenv(1, GLOBAL)

local function GetBird(inst)
    return (inst.components.occupiable and inst.components.occupiable:GetOccupant()) or nil
end

--Only use for hit and idle anims
local function PushStateAnim(inst, anim, loop)
    inst.AnimState:PushAnimation(anim..inst.CAGE_STATE, loop)
end

local function DigestFood(inst, food)
    --NOTE (Omar): 
    -- Reminder that food is not valid at this point.
    -- So don't call any engine functions or any other functions that check for validity
    local bird = GetBird(inst)

    if bird and bird:HasTag("bird_mutant_rift") then
        if food.components.edible.foodtype == FOODTYPE.LUNAR_SHARDS then
            if food.prefab == "moonglass_charged" then --Can't be a tag check
                if bird.do_drop_brilliance then
                    inst.components.lootdropper:SpawnLootPrefab("purebrilliance")
                    bird.do_drop_brilliance = nil
                end
            else
                --inst.components.lootdropper:SpawnLootPrefab("")
            end
        end
    elseif food.components.edible.foodtype == FOODTYPE.MEAT then
        --If the food is meat:
            --Spawn an egg.
        if bird and bird:HasTag("bird_mutant") then
            inst.components.lootdropper:SpawnLootPrefab("rottenegg")
        else
            inst.components.lootdropper:SpawnLootPrefab("bird_egg")
        end
    else
        if bird and bird:HasTag("bird_mutant") then
            inst.components.lootdropper:SpawnLootPrefab("spoiled_food")
        else
            local seed_name = string.lower(food.prefab .. "_seeds")
            if Prefabs[seed_name] ~= nil then
    			inst.components.lootdropper:SpawnLootPrefab(seed_name)
            else
                --Otherwise...
                    --Spawn a poop 1/3 times.
                if math.random() < 0.33 then
                    local loot = inst.components.lootdropper:SpawnLootPrefab("guano")
                    loot.Transform:SetScale(.33, .33, .33)
                end
            end
        end
    end

    --Refill bird stomach.
    if bird and bird:IsValid() and bird.components.perishable then
        bird.components.perishable:SetPercent(1)
    end
end

local function OnGetItem(inst, giver, item)
    local bird = GetBird(inst)
    --If you're sleeping, wake up.
    if inst.components.sleeper and inst.components.sleeper:IsAsleep() then
        inst.components.sleeper:WakeUp()
    end

    if item.components.edible ~= nil and
        (   item.components.edible.foodtype == FOODTYPE.MEAT
            or item.components.edible.foodtype == FOODTYPE.LUNAR_SHARDS
            or item.prefab == "seeds"
            or string.match(item.prefab, "_seeds")
            or Prefabs[string.lower(item.prefab .. "_seeds")] ~= nil
        ) then
        --If the item is edible...
        --Play some animations (peck, peck, peck, hop, idle)
        inst.AnimState:PlayAnimation("peck")
        inst.AnimState:PushAnimation("peck")
        inst.AnimState:PushAnimation("peck")
        inst.AnimState:PushAnimation("hop")
        PushStateAnim(inst, "idle", true)

        -- We have to do this logic instantly so the player doesn't feed too many shards before the task in time
        if bird and bird:HasTag("bird_mutant_rift") and item.prefab == "moonglass_charged" then
            bird._infused_eaten = bird._infused_eaten + 1
            
            if bird._infused_eaten >= TUNING.RIFT_BIRD_EAT_COUNT_FOR_BRILLIANCE then
                bird:PutOnBrillianceCooldown(inst)
                bird.do_drop_brilliance = true
            end
        end
        --Digest Food in 60 frames.
        inst:DoTaskInTime(60 * FRAMES, DigestFood, item)
    end
end

AddPrefabPostInit("birdcage", function(inst)
    if not TheWorld.ismastersim then
		return inst
	end
    inst.components.trader.onaccept = OnGetItem
end)


