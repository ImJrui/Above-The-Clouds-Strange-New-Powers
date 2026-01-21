local AddPlayerPostInit = AddPlayerPostInit

GLOBAL.setfenv(1, GLOBAL)

local function SaveForInteriorMap(inst, data)
    if inst.components.interiorvisitor then

        data.plrebalance_interiormap = data.plrebalance_interiormap or {}
        data.plrebalance_anthill_visited_time = data.plrebalance_anthill_visited_time or {}

		local current_shard = TheShard:GetShardId()
		inst.plrebalance_interiormap[current_shard] = inst.components.interiorvisitor.interior_map
		inst.plrebalance_anthill_visited_time[current_shard] = inst.components.interiorvisitor.anthill_visited_time

        for shard_id, interior_map in pairs(inst.plrebalance_interiormap) do
            data.plrebalance_interiormap[shard_id] = interior_map
        end

        for shard_id, visited_time in pairs(inst.plrebalance_anthill_visited_time) do
            data.plrebalance_anthill_visited_time[shard_id] = visited_time
        end
    end
end

local function LoadForInteriorMap(inst, data)
    if not inst.components.interiorvisitor or not data then
        return
    end

    if data.plrebalance_interiormap then
        for shard_id, interior_map in pairs(data.plrebalance_interiormap) do
            inst.plrebalance_interiormap[shard_id] = interior_map
        end
    end

    if data.plrebalance_anthill_visited_time then
        for shard_id, visited_time in pairs(data.plrebalance_anthill_visited_time) do
            inst.plrebalance_anthill_visited_time[shard_id] = visited_time
        end
    end

    local current_shard = TheShard:GetShardId()
	if inst.plrebalance_interiormap[current_shard] ~= nil then
		inst.components.interiorvisitor.interior_map = inst.plrebalance_interiormap[current_shard]
		inst:DoStaticTaskInTime(3, function()
			SendModRPCToClient(GetClientModRPC("PorkLand", "interior_map"), inst.userid, ZipAndEncodeString(inst.components.interiorvisitor.interior_map))
		end)
	end

	if inst.plrebalance_anthill_visited_time[current_shard] ~= nil then
		inst.components.interiorvisitor.anthill_visited_time = inst.plrebalance_anthill_visited_time[current_shard]
    end
end

local function player_postinit(player)

	player.plrebalance_oldSaveForReroll = player.SaveForReroll
	player.plrebalance_oldLoadForReroll = player.LoadForReroll

    player.SaveForReroll = function(inst)
        local data = inst.plrebalance_oldSaveForReroll and inst:plrebalance_oldSaveForReroll() or {}

        SaveForInteriorMap(inst, data)

        return data
    end

    player.LoadForReroll = function(inst, data)
        if inst.plrebalance_oldLoadForReroll then
            inst:plrebalance_oldLoadForReroll(data)
        end

        LoadForInteriorMap(inst, data)
    end

	player.plrebalance_interiormap = {}
	player.plrebalance_anthill_visited_time = {}

    local _OnSave = player.OnSave
    local _OnLoad = player.OnLoad
    player.OnSave = function(inst, data)
        if _OnSave then
            _OnSave(inst, data)
        end

        SaveForInteriorMap(inst, data)
    end

    player.OnLoad = function(inst, data)
        if _OnLoad then
            _OnLoad(inst, data)
        end

        LoadForInteriorMap(inst, data)
    end
end

AddPlayerPostInit(player_postinit)