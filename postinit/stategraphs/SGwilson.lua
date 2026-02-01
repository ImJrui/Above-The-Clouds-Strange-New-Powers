local AddStategraphState = AddStategraphState
local AddStategraphEvent = AddStategraphEvent
local AddStategraphActionHandler = AddStategraphActionHandler
local AddStategraphPostInit = AddStategraphPostInit
GLOBAL.setfenv(1, GLOBAL)

AddStategraphPostInit("wilson", function(sg)
    local cower_onenter = sg.states["cower"].onenter
    sg.states["cower"].onenter = function(inst, data)
        if cower_onenter ~= nil then
            cower_onenter(inst, data)
        end

        if inst.components.rider ~= nil and inst.components.rider:IsRiding() then
            inst.sg:AddStateTag("dismounting")
            inst.AnimState:PlayAnimation("fall_off")
            inst.SoundEmitter:PlaySound("dontstarve/beefalo/saddle/dismount")
        end
    end

    table.insert(sg.states["cower"].events, EventHandler("animover", function(inst)
        if inst.sg:HasStateTag("dismounting") and inst.AnimState:AnimDone() then
            inst.sg:RemoveStateTag("dismounting")
            inst.components.rider:ActualDismount()
            inst.AnimState:PlayAnimation("cower")
        end
    end))

    local cower_onexit = sg.states["cower"].onexit
    sg.states["cower"].onexit = function(inst)
        if cower_onexit ~= nil then
            cower_onexit(inst)
        end
        if inst.sg:HasStateTag("dismounting") then
            --interrupted
            inst.components.rider:ActualDismount()
        end
    end
end)
