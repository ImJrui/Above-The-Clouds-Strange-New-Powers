local AddDeconstructRecipe = AddDeconstructRecipe
local AddRecipe2 = AddRecipe2
local AddRecipeFilter = AddRecipeFilter
local AddPrototyperDef = AddPrototyperDef
local AddRecipePostInit = AddRecipePostInit

local AddPrefabPostInit = AddPrefabPostInit
local AddPlayerPostInit = AddPlayerPostInit
local AddClassPostConstruct = AddClassPostConstruct

local PLENV = env
GLOBAL.setfenv(1, GLOBAL)


--[[
local SILVICULTURE_ONEOF_TAGS = { "leif", "silviculture", "tree", "winter_tree" }
local SILVICULTURE_CANT_TAGS = { "magicgrowth", "player", "FX", "pickable", "stump", "withered", "barren", "INLIMBO", "ancienttree" }

local function trygrowth(inst, maximize, reader)
    if not inst:IsValid()
		or inst:IsInLimbo()
        or (inst.components.witherable ~= nil and inst.components.witherable:IsWithered()) then

        return false
    end
	
	-- if inst.components.hackable ~= nil then
    --     inst.components.hackable:Regen()
    -- end

	if inst.components.growable then
		inst.components.growable:DoMagicGrowth(reader)
	end
end

local function silviculture_fn(inst, reader)
	inst.PLREBALANCE_silvionread(inst, reader)
	
	local x, y, z = reader.Transform:GetWorldPosition()
	local range = 30
	local _ents = TheSim:FindEntities(x, y, z, range, nil, SILVICULTURE_CANT_TAGS, SILVICULTURE_ONEOF_TAGS)
	local ents = {}

	for k,v in pairs(_ents) do
		if v.components.hackable ~= nil then
			table.insert (ents, v)
		end
	end

	if #ents > 0 then
		trygrowth(table.remove(ents, math.random(#ents)), reader)
		if #ents > 0 then
			local timevar = 1 - 1 / (#ents + 1)
			for i, v in ipairs(ents) do
				v:DoTaskInTime(timevar * math.random(), trygrowth)
			end
		end
	else
		return inst.PLREBALANCE_silvionread(inst, reader)
	end
	inst.PLREBALANCE_silvionread(inst, reader)
	return true
end

AddPrefabPostInit("book_silviculture", function(inst)
	if not TheWorld.ismastersim then
        return
    end
	inst.PLREBALANCE_silvionread = inst.components.book.onread
	inst.components.book:SetOnRead(silviculture_fn)
end)
]]

