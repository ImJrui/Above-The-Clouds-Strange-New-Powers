local modname = modname
local AddSimPostInit = AddSimPostInit
local GetModConfigData = GetModConfigData
GLOBAL.setfenv(1, GLOBAL)

if not GetModConfigData("EnableSkyworthy") then
    return
end

local SetServerShardData = ShardIndex.SetServerShardData
local GetWorldgenOverride, scope_fn, index = ToolUtil.GetUpvalue(SetServerShardData, "GetWorldgenOverride")

if GetWorldgenOverride and index then
    local function AlwaysNilGetWorldgenOverride(slot, shard, cb)
        if cb then
            cb(nil, nil)
        end
    end

    debug.setupvalue(scope_fn, index, AlwaysNilGetWorldgenOverride)
    print("worldgenoverride is disabled")
else
    print("can not find function GetWorldgenOverride in ShardIndex.SetServerShardData")
end

