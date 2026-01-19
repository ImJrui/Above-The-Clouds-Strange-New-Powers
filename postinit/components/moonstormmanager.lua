local AddComponentPostInit = AddComponentPostInit
GLOBAL.setfenv(1, GLOBAL)

local function StartTheMoonstorms()
    SendModRPCToShard(GetShardModRPC("porkland", "StartTheMoonstorms"), SHARDID.MASTER)
end

local function StopTheMoonstorms()
	SendModRPCToShard(GetShardModRPC("porkland", "StopTheMoonstorms"), SHARDID.MASTER)
end

AddComponentPostInit("moonstormmanager", function(self, inst)
    if TheWorld.ismastershard then
        return
    end
    inst:ListenForEvent("ms_startthemoonstorms", StartTheMoonstorms)
    inst:ListenForEvent("ms_stopthemoonstorms", StopTheMoonstorms)
end)