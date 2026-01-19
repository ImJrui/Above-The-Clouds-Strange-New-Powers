local AddDeconstructRecipe = AddDeconstructRecipe
local AddRecipe2 = AddRecipe2
local AddRecipeFilter = AddRecipeFilter
local AddPrototyperDef = AddPrototyperDef
local AddRecipePostInit = AddRecipePostInit

local AddPrefabPostInit = AddPrefabPostInit
local AddPlayerPostInit = AddPlayerPostInit
local AddClassPostConstruct = AddClassPostConstruct

GLOBAL.setfenv(1, GLOBAL)

local function pl_clearinterior_listener(inst, data)
	local recallmark = inst.components.recallmark
	if recallmark:IsMarked() then
		local xPos = recallmark.recall_x - data.pos.x
		local zPos = recallmark.recall_z - data.pos.z
		local shouldDelete = xPos * xPos + zPos * zPos < TUNING.ROOM_FINDENTITIES_RADIUS * TUNING.ROOM_FINDENTITIES_RADIUS
		--print(xPos, zPos, shouldDelete)
		if shouldDelete then
			recallmark.recall_worldid = nil
			inst:AddTag("recall_unmarked")
		end
	end
end

local function pl_checkifinteriorgone(inst)
	local recallmark = inst.components.recallmark
	if recallmark.recall_worldid ~= TheShard:GetShardId() then return end
	local x, z = recallmark.recall_x, recallmark.recall_z
	if not x then return end
	local interiorspawner = TheWorld.components.interiorspawner
	local pos = Vector3(x, 0, z)
	if interiorspawner and interiorspawner:IsInInteriorRegion(x, z) and not interiorspawner.interior_defs[interiorspawner:PositionToIndex(pos)] then
		recallmark.recall_worldid = nil
		inst:AddTag("recall_unmarked")
	end
end

local function pocketwatch_recall_postinit(inst)
    if not TheWorld.ismastersim then
        return
    end
	inst.pl_clearinterioreventlistener = inst:ListenForEvent("pl_clearinterior", function(src, data) pl_clearinterior_listener(inst, data) end, TheWorld)
	inst:DoTaskInTime(0, pl_checkifinteriorgone)
end

AddPrefabPostInit("pocketwatch_recall", pocketwatch_recall_postinit)
AddPrefabPostInit("pocketwatch_portal", pocketwatch_recall_postinit)