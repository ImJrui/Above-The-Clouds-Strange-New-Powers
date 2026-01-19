-------------------------------------------------------------------------
---------------------- Attach and dettach functions ---------------------
-------------------------------------------------------------------------
local Grogginess = require("components/grogginess")

local OldFogProofChange = Grogginess.OnFogProofChange

function Grogginess.OnFogProofChange(inst, data)
	if inst:HasTag("onfogproof") then
		local self = inst.components.grogginess

		if not self then
			return
		end
		
		if self.foggygroggy then
			if inst.components.talker then
				inst.components.talker:Say(GetString(inst, "ANNOUNCE_DEHUMID"))
			end
		end
		
		self.foggygroggy = false
		return
	end
	OldFogProofChange(inst, data)
end

local function fogproof_attach(inst, target)
    if target:HasTag("player") then
        target:AddTag("onfogproof")
        target.components.grogginess.OnFogProofChange(target)
    end
end

local function fogproof_detach(inst, target)
    if target:HasTag("player") then
        target:RemoveTag("onfogproof")
        target.components.grogginess.OnFogProofChange(target)
    end
end
-------------------------------------------------------------------------
local function antivenom_attach(inst, target)
    if not target:HasTag("poisonable") then
        target:AddComponent("poisonable")
    end
    target.components.poisonable:Cure(target)
    target.components.poisonable.immune = true
end

local function antivenom_detach(inst, target)
    if target.components.poisonable then
        target.components.poisonable.immune = false
    end
end
-------------------------------------------------------------------------
----------------------- Prefab building functions -----------------------
-------------------------------------------------------------------------

local function OnTimerDone(inst, data)
    if data.name == "buffover" then
        inst.components.debuff:Stop()
    end
end

local function MakeBuff(name, onattachedfn, onextendedfn, ondetachedfn, duration, priority, prefabs)
    local function OnAttached(inst, target)
        inst.entity:SetParent(target.entity)
        inst.Transform:SetPosition(0, 0, 0) --in case of loading
        inst:ListenForEvent("death", function()
            inst.components.debuff:Stop()
        end, target)

        -- target:PushEvent("foodbuffattached", { buff = "ANNOUNCE_ATTACH_BUFF_"..string.upper(name), priority = priority })
        if onattachedfn ~= nil then
            onattachedfn(inst, target)
        end
    end

    local function OnExtended(inst, target)
        inst.components.timer:StopTimer("buffover")
        inst.components.timer:StartTimer("buffover", duration)

        -- target:PushEvent("foodbuffattached", { buff = "ANNOUNCE_ATTACH_BUFF_"..string.upper(name), priority = priority })
        if onextendedfn ~= nil then
            onextendedfn(inst, target)
        end
    end

    local function OnDetached(inst, target)
        if ondetachedfn ~= nil then
            ondetachedfn(inst, target)
        end

        -- target:PushEvent("foodbuffdetached", { buff = "ANNOUNCE_DETACH_BUFF_"..string.upper(name), priority = priority })
        inst:Remove()
    end

    local function fn()
        local inst = CreateEntity()

        if not TheWorld.ismastersim then
            --Not meant for client!
            inst:DoTaskInTime(0, inst.Remove)
            return inst
        end

        inst.entity:AddTransform()

        --[[Non-networked entity]]
        inst.entity:Hide()
        inst.persists = false

        inst:AddTag("CLASSIFIED")

        inst:AddComponent("debuff")
        inst.components.debuff:SetAttachedFn(OnAttached)
        inst.components.debuff:SetDetachedFn(OnDetached)
        inst.components.debuff:SetExtendedFn(OnExtended)
        inst.components.debuff.keepondespawn = true

        inst:AddComponent("timer")
        inst.components.timer:StartTimer("buffover", duration)
        inst:ListenForEvent("timerdone", OnTimerDone)

        return inst
    end

    return Prefab("buff_"..name, fn, nil, prefabs)
end

return  MakeBuff("fogproof", fogproof_attach, nil, fogproof_detach, 240, 2),
        MakeBuff("antivenom", antivenom_attach, nil, antivenom_detach, 60, 2)

--MakeBuff(name, onattachedfn, onextendedfn, ondetachedfn, duration, priority, prefabs)
