local AddModRPCHandler = AddModRPCHandler
local AddShardModRPCHandler = AddShardModRPCHandler
local AddClientModRPCHandler = AddClientModRPCHandler
GLOBAL.setfenv(1, GLOBAL)

local function printinvalid(rpcname, player)
    print(string.format("Invalid %s RPC from (%s) %s", rpcname, player.userid or "", player.name or ""))

    --This event is for MODs that want to handle players sending invalid rpcs
    TheWorld:PushEvent("invalidrpc", { player = player, rpcname = rpcname })

    if BRANCH == "dev" then
        --Internal testing
        assert(false, string.format("Invalid %s RPC from (%s) %s", rpcname, player.userid or "", player.name or ""))
    end
end

AddModRPCHandler("porkland", "ConfirmSkyWorthy", function(player, destination_id)
    if destination_id == nil or Shard_GetConnectedWorldType(destination_id) == PL_WORLDTYPE.UNKNOWN then
        -- player:say("Invalid destination!")
        return
    end
    player.skyworthy:OnTravelDestinationConfirmed(player, destination_id)
end)

AddShardModRPCHandler("porkland", "StartTheMoonstorms", function(shardid)
    TheWorld:PushEvent("ms_setclocksegs_default", {day = 0, dusk = 0, night = 16})
    TheWorld:PushEvent("ms_setmoonphase_default", {moonphase = "full", iswaxing = false})
    TheWorld:PushEvent("ms_lockmoonphase_default", {lock = true})
end)

AddShardModRPCHandler("porkland", "StopTheMoonstorms", function(shardid)
    TheWorld:PushEvent("ms_setclocksegs_default", {day = 0, dusk = 0, night = 16})
    TheWorld:PushEvent("ms_setmoonphase_default", {moonphase = "new", iswaxing = true})
    TheWorld:PushEvent("ms_lockmoonphase_default", {lock = false})
end)

AddShardModRPCHandler("porkland", "SyncWorldType", function(shardid, connected_id, world_type)
    for id in pairs(Shard_GetConnectedShards()) do
        if id ~= connected_id then
            SendModRPCToShard(GetShardModRPC("porkland", "MS_SyncWorldType"), id, connected_id, world_type)
        end
    end
end)

AddShardModRPCHandler("porkland", "MS_SyncWorldType", function(shardid, connected_id, world_type)
    Shard_UpdateDimensionalState(connected_id, world_type)
end)
