local AddStategraphState = AddStategraphState
local AddStategraphEvent = AddStategraphEvent
local AddStategraphActionHandler = AddStategraphActionHandler
local AddStategraphPostInit = AddStategraphPostInit
GLOBAL.setfenv(1, GLOBAL)

require("stategraphs/commonstates")

local events ={
	CommonHandlers.OnIpecacPoop(),
}

local states = {}
CommonStates.AddIpecacPoopState(states)

for _, event in ipairs(events) do
    AddStategraphEvent("pig", event)
end

for _, state in ipairs(states) do
    AddStategraphState("pig", state)
end

--[[
AddStategraphPostInit("pig", function(sg)
    if sg.events.ipecacpoop == nil then
        AddStategraphEvent("pig", CommonHandlers.OnIpecacPoop())
    end
    if sg.states.ipecacpoop == nil then
        AddStategraphState("pig", states[1])
    end
end)
]]