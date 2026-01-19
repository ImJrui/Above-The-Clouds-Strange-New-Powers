GLOBAL.setfenv(1, GLOBAL)

------------------------------------------------------
function GetWorldType()
    if TheWorld then
        if TheWorld:HasTag("forest") then
            return PL_WORLDTYPE.FOREST
        elseif TheWorld:HasTag("cave") then
            return PL_WORLDTYPE.CAVE
        elseif TheWorld:HasTag("island") then
            return PL_WORLDTYPE.SHIPWRECKED
        elseif TheWorld:HasTag("volcano") then
            return PL_WORLDTYPE.VOLCANOWORLD
        elseif TheWorld:HasTag("porkland") then
            return PL_WORLDTYPE.PORKLAND
        end
        return PL_WORLDTYPE.UNKNOWN
    end
end

local ConnectedDimensions = {}
local ConnectedWorldType = {}

local function UpdatePortalState(inst)
    local linkedWorldType = inst.components.worldmigrator.linkedWorldType
    if linkedWorldType and linkedWorldType ~= PL_WORLDTYPE.UNKNOWN then
        inst.components.worldmigrator:ClearDisabledWithReason("MISSINGSHARD")
        inst.components.worldmigrator:SetDestinationWorld(ConnectedDimensions[linkedWorldType] or nil, true)
    end
end

function Shard_UpdateDimensionalState(world_id, world_type)

    ConnectedWorldType[world_id] = world_type
    ConnectedDimensions[world_type] = world_id

    for k, v in pairs(ShardPortals) do
        UpdatePortalState(v)
    end
end

local _Shard_UpdateWorldState = Shard_UpdateWorldState
function Shard_UpdateWorldState(world_id, state, tags, world_data, ...)
    _Shard_UpdateWorldState(world_id, state, tags, world_data, ...)

    local ready = state == REMOTESHARDSTATE.READY

    if ready then
        if TheShard:IsMaster() then
            local connected_shard = Shard_GetConnectedShards()[world_id]
            local location = connected_shard and connected_shard.world[1] and connected_shard.world[1].location
            if location then
                Shard_UpdateDimensionalState(world_id, PL_WORLDTYPE[string.upper(location)])
            end
            SendModRPCToShard(GetShardModRPC("porkland", "MS_SyncWorldType"), world_id, SHARDID.MASTER, GetWorldType())
        else
            SendModRPCToShard(GetShardModRPC("porkland", "SyncWorldType"), SHARDID.MASTER, TheShard:GetShardId(), GetWorldType())
        end
    else
        for world_type, id in pairs(ConnectedDimensions) do
            if world_id == id then
                ConnectedDimensions[world_type] = nil
            end
        end
    end
end

local _Shard_UpdatePortalState = Shard_UpdatePortalState
function Shard_UpdatePortalState(inst, ...)
    _Shard_UpdatePortalState(inst, ...)
    
    UpdatePortalState(inst)
end

function Shard_GetConnectedWorldType(id)
    return ConnectedWorldType[id]
end