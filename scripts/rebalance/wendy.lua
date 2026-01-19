local AddDeconstructRecipe = AddDeconstructRecipe
local AddRecipe2 = AddRecipe2
local AddRecipeFilter = AddRecipeFilter
local AddPrototyperDef = AddPrototyperDef
local AddRecipePostInit = AddRecipePostInit

local AddPrefabPostInit = AddPrefabPostInit
local AddStategraphState = AddStategraphState

GLOBAL.setfenv(1, GLOBAL)

--Wendy

local CANTHAVE_GHOST_TAGS = {"questing"}
local MUSTHAVE_GHOST_TAGS = {"ghostkid"}

local NEW_GRAVESTONE_CHANCE = 0.3

local function on_day_change(inst)
	local MaxSpooks = 0
    if #AllPlayers > 0 then
		for _, v in ipairs(AllPlayers) do
			if v:HasTag("ghostlyfriend") then
				MaxSpooks = MaxSpooks == 0 and 2 or MaxSpooks + 1
			end
		end
    end
	local nearby_ghosts = nil
	local gx, gy, gz = inst.Transform:GetWorldPosition()
	for i=1, MaxSpooks do
		local ghost_spawn_chance = NEW_GRAVESTONE_CHANCE

		if math.random() < ghost_spawn_chance then
			if nearby_ghosts == nil then
				nearby_ghosts = nearby_ghosts or #(TheSim:FindEntities(gx, gy, gz, TUNING.UNIQUE_SMALLGHOST_DISTANCE, MUSTHAVE_GHOST_TAGS, CANTHAVE_GHOST_TAGS))
			end
			
			if nearby_ghosts < MaxSpooks then
				inst.ghost = SpawnPrefab("smallghost")
				
				local disp_ang = math.random() * 2 * math.pi
				local dispX = math.cos(disp_ang) * 5
				local dispY = math.sin(disp_ang) * 5
				
				inst.ghost.Transform:SetPosition(gx + dispX + 0.3, gy, gz + dispY + 0.3)
				inst.ghost:LinkToHome(inst)
				
				nearby_ghosts = nearby_ghosts + 1
			else
				break
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