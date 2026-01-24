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

--[[ Although I really like the animations of Abigail entering and exiting the room, now the follower teleportation uses a unified logic.
--- Wendy Door Fix ---
local function NoHoles(pt)
    return not TheWorld.Map:IsPointNearHole(pt)
end

function MoveAbigail3(inst)
	inst.sg:GoToState("appear")
	
	local leader = inst.components.follower.leader
	local leader_pos = leader:GetPosition()
	local x, y, z = leader_pos:Get()
	
	local rand = math.random() * math.pi * 2
	local offset = FindWalkableOffset(leader_pos, rand, 2, 10, false, true, NoHoles)
	if offset ~= nil then
		x = x + offset.x
		z = z + offset.z
	end
	inst.Physics:Teleport(x, 0, z)
end

local function MoveAbigail2(inst)
	if not inst.sg:HasStateTag("plrebalance_abiteleport") then return end
	
    MoveAbigail3(inst)
end

local state_plrebalance_abiteleport = State{
	name = "plrebalance_abiteleport",
	tags = { "busy", "noattack", "nointerrupt", "dissipate", "plrebalance_abiteleport" },

	onenter = function(inst)
		inst.Physics:Stop()
		inst.AnimState:PlayAnimation("dissipate")
		-- inst.SoundEmitter:PlaySound("dontstarve/characters/wendy/abigail/howl_one_shot")

		inst.components.health:SetInvincible(true)
		inst.components.aura:Enable(false)
	end,

	events =
	{
		EventHandler("animover", function(inst)
			if inst.AnimState:AnimDone() then
				MoveAbigail3(inst)
			end
		end)
	},
}

AddStategraphState("abigail", state_plrebalance_abiteleport)

local function MoveAbigail(inst)
	local abigail = inst.components.ghostlybond.ghost
    if abigail ~= nil and abigail.sg ~= nil and not abigail.inlimbo then
		if not abigail.sg:HasStateTag("dissipate") then
			abigail.sg:GoToState("plrebalance_abiteleport")
		end
        --abigail.PLREBALANCE_abiporttask = abigail:DoTaskInTime(25 * FRAMES, MoveAbigail3)
    end
end

function WendyPostInit(inst)
    if not TheWorld.ismastersim then
        return
    end
	
	inst:ListenForEvent("used_door", MoveAbigail)
end

function AbigailPostInit(inst)
    if not TheWorld.ismastersim then
        return
    end
	
    inst:ListenForEvent("entitywake", MoveAbigail2)
end

AddPrefabPostInit("wendy", WendyPostInit)
AddPrefabPostInit("abigail", AbigailPostInit)
]]