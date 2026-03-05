local AddStategraphState = AddStategraphState
local AddStategraphEvent = AddStategraphEvent
local AddStategraphActionHandler = AddStategraphActionHandler
local AddStategraphPostInit = AddStategraphPostInit
GLOBAL.setfenv(1, GLOBAL)

local function ForceStopHeavyLifting(inst)
    if inst.components.inventory:IsHeavyLifting() then
        inst.components.inventory:DropItem(
            inst.components.inventory:Unequip(EQUIPSLOTS.BODY),
            true,
            true
        )
    end
end

local function ToggleOffPhysics(inst)
    inst.sg.statemem.isphysicstoggle = true
	inst.Physics:SetCollisionMask(COLLISION.GROUND)
end

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
    -- 修复在虚空坠落的bug
    local _abyss_fall_onenter = sg.states["abyss_fall"].onenter
    sg.states["abyss_fall"].onenter = function(inst, teleport_pt, ...)
        if not TheWorld.has_pl_ocean then
			ForceStopHeavyLifting(inst)
			inst.components.rider:ActualDismount()
			inst.components.locomotor:Stop()
			inst.components.locomotor:Clear()
			inst:ClearBufferedAction()
			inst:ShowHUD(false)

			inst.AnimState:PlayAnimation("abyss_fall")
            if inst.components.drownable then
                local teleport_x, teleport_y, teleport_z
                if teleport_pt then
                    teleport_x, teleport_y, teleport_z = teleport_pt:Get()
                end
                inst.components.drownable:OnFallInVoid(teleport_x, teleport_y, teleport_z)
            end
			inst.DynamicShadow:Enable(false)
			ToggleOffPhysics(inst)
			if inst.components.playercontroller then
				inst.components.playercontroller:Enable(false)
			end
			inst.components.health:SetInvincible(true)
            return
        end
        return _abyss_fall_onenter(inst, teleport_pt, ...)
    end
end)
