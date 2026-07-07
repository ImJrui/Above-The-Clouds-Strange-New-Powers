local AddDeconstructRecipe = AddDeconstructRecipe
local AddRecipe2 = AddRecipe2
local AddRecipeFilter = AddRecipeFilter
local AddPrototyperDef = AddPrototyperDef
local AddRecipePostInit = AddRecipePostInit

local AddPrefabPostInit = AddPrefabPostInit
local AddStategraphState = AddStategraphState

GLOBAL.setfenv(1, GLOBAL)

--Wendy

-- Ghosts on a quest (following someone) shouldn't block other ghost spawns!
local CANTHAVE_GHOST_TAGS = {"questing"}
local MUSTHAVE_GHOST_TAGS = {"ghostkid"}
local function on_day_change(inst)
    if #AllPlayers > 0 and (not inst.ghost or not inst.ghost:IsValid()) then
        local ghost_spawn_chance = TUNING.GHOST_GRAVESTONE_CHANCE
        for _, v in ipairs(AllPlayers) do
            if v:HasTag("ghostlyfriend") then
                ghost_spawn_chance = ghost_spawn_chance + TUNING.GHOST_GRAVESTONE_CHANCE

                if v.components.skilltreeupdater and v.components.skilltreeupdater:IsActivated("wendy_smallghost_1") then
                    ghost_spawn_chance = ghost_spawn_chance + TUNING.WENDYSKILL_SMALLGHOST_EXTRACHANCE
                end
            end
        end

        if math.random() < ghost_spawn_chance then
            local gx, gy, gz = inst.Transform:GetWorldPosition()
            local nearby_ghosts = TheSim:FindEntities(gx, gy, gz, TUNING.UNIQUE_SMALLGHOST_DISTANCE, MUSTHAVE_GHOST_TAGS, CANTHAVE_GHOST_TAGS)
            if #nearby_ghosts == 0 then
                inst.ghost = SpawnPrefab("smallghost")
                inst.ghost.Transform:SetPosition(gx + 0.3, gy, gz + 0.3)
                inst.ghost:LinkToHome(inst)
            end
        end
    end
end

function PigRuinsChange(inst)
    if not TheWorld.ismastersim then
        return
    end

    inst:WatchWorldState("cycles", on_day_change)
end

AddPrefabPostInit("pig_ruins_entrance_small", PigRuinsChange)
AddPrefabPostInit("pig_ruins_entrance", PigRuinsChange)
AddPrefabPostInit("pig_ruins_exit", PigRuinsChange)
AddPrefabPostInit("pig_ruins_exit2", PigRuinsChange)
AddPrefabPostInit("pig_ruins_entrance3", PigRuinsChange)
AddPrefabPostInit("pig_ruins_entrance4", PigRuinsChange)
AddPrefabPostInit("pig_ruins_exit4", PigRuinsChange)

---------------------------------------------------
-- Wendy's Abigail damage is increased when inside an interior region.

local AbigailUpdateDamage = nil

AddPrefabRegisterPostInit("abigail", function(prefab)
    local constructor = prefab.fn
    local _UpdateDamage = ToolUtil.GetUpvalue(constructor, "UpdateDamage")

    if _UpdateDamage == nil then
        return
    end

    local function UpdateDamage(inst, ...)
        _UpdateDamage(inst, ...)

        local x, _, z = inst.Transform:GetWorldPosition()
        if TheWorld.components.interiorspawner and TheWorld.components.interiorspawner:IsInInteriorRegion(x, z) then
            inst.components.combat.defaultdamage = TUNING.ABIGAIL_DAMAGE["night"]
            inst.attack_level = 3

            local level_str = tostring(inst.attack_level)
            if inst.attack_fx and not inst.attack_fx.AnimState:IsCurrentAnimation("attack" .. level_str .. "_loop") then
                inst.attack_fx.AnimState:PlayAnimation("attack" .. level_str .. "_loop", true)
            end
        end
        -- print("tutu: Abigail damage updated to " .. inst.components.combat.defaultdamage .. " in interior region.")
    end

    AbigailUpdateDamage = UpdateDamage

    ToolUtil.SetUpvalue(constructor, "UpdateDamage", UpdateDamage)
end)

AddPrefabPostInit("abigail", function(inst)
    if not TheWorld.ismastersim then
        return
    end

    if AbigailUpdateDamage == nil then
        return
    end

    inst.UpdateDamage = AbigailUpdateDamage
end)

local function UpdateAbigailDamage(inst)
    local abigail = inst.components.ghostlybond and inst.components.ghostlybond.ghost

    if abigail and abigail.UpdateDamage then
        abigail:UpdateDamage()
    end
end

AddPrefabPostInit("wendy", function(inst)
    if not TheWorld.ismastersim then
        return
    end

    inst:ListenForEvent("enterinterior", UpdateAbigailDamage)
    inst:ListenForEvent("leaveinterior", UpdateAbigailDamage)
end)
