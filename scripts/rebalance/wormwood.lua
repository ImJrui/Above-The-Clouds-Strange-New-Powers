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

local function OnSeasonChange(inst, season)
    if season == "lush" and not inst:HasTag("playerghost") then
        inst.components.bloomness:Fertilize()
    else
        inst.components.bloomness:UpdateRate()
    end
end

local function OnRespawnedFromGhost(inst)
    if TheWorld.state.islush then
        inst.components.bloomness:Fertilize()
    end
end

local function postinit_fn(inst)
	if not TheWorld:HasTag("porkland") then
		return
	end

	if not TheWorld.ismastersim then
        return
    end

	local _calcratefn = inst.components.bloomness.calcratefn
	inst.components.bloomness.calcratefn = function(inst, level, is_blooming, fertilizer)
		if TheWorld.state.season == "lush" then
			local season_mult = 1
			if is_blooming then
				season_mult = TUNING.WORMWOOD_SPRING_BLOOM_MOD
			else
				return TUNING.WORMWOOD_SPRING_BLOOMDRAIN_RATE
			end
			return (is_blooming and fertilizer > 0) and (season_mult * (1 + fertilizer * TUNING.WORMWOOD_FERTILIZER_RATE_MOD)) or 1
		end
		if _calcratefn then
			return _calcratefn(inst, level, is_blooming, fertilizer)
		end
	end

	inst:ListenForEvent("ms_respawnedfromghost", OnRespawnedFromGhost)

	inst:WatchWorldState("season", OnSeasonChange)

	local _OnNewSpawn = inst.OnNewSpawn
	inst.OnNewSpawn = function(inst)
		if TheWorld.state.islush then
			inst.components.bloomness:Fertilize()
		end
		if _OnNewSpawn then
			_OnNewSpawn(inst)
		end
	end
    inst.inittask = inst:DoTaskInTime(0, inst.OnNewSpawn)
end

AddPrefabPostInit("wormwood", postinit_fn)