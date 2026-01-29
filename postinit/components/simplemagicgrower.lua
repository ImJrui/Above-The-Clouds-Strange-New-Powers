local AddPrefabPostInit = AddPrefabPostInit
local AddComponentPostInit = AddComponentPostInit

GLOBAL.setfenv(1, GLOBAL)

local HACKS_PER_TUBER = 3

local function MakeAnims(stage)
    return {
        idle = "idle_" .. stage,
        sway1 = "sway1_loop_" .. stage,
        sway2 = "sway2_loop_" .. stage,
        chop = "chop_" .. stage,
        fallleft = "fallleft_" .. stage,
        fallright = "fallright_" .. stage,
        stump = "stump_" .. stage,
        burning = "burning_loop_" .. stage,
        burnt = "burnt_" .. stage,
        chop_burnt = "chop_burnt_" .. stage,
        idle_chop_burnt = "idle_chop_burnt_" .. stage,
        blown1 = "blown_loop_" .. stage .. "1",
        blown2 = "blown_loop_" .. stage .. "2",
        blown_pre = "blown_pre_" .. stage,
        blown_pst = "blown_pst_" .. stage
    }
end

local anims = {
    MakeAnims("short"),
    MakeAnims("tall"),
}

local function UpdateArt(inst)
    for i, slot in ipairs(inst.tuberslots) do
        inst.AnimState:Hide("tubers" .. slot)
    end

    for i = 1, inst.tubers do
        inst.AnimState:Show("tubers" .. inst.tuberslots[i])
    end
end

local function UpdateTubers(inst, tubers, skip_workleft_update)
    inst.tubers = tubers
    UpdateArt(inst)
    if not skip_workleft_update then
        inst.components.workable:SetWorkLeft((inst.tubers + 1) * HACKS_PER_TUBER)
    end
end

local function PushSway(inst)
    local anim = anims[inst.stage]
    if math.random() > 0.5 then
        inst.AnimState:PushAnimation(anim.sway1, true)
    else
        inst.AnimState:PushAnimation(anim.sway2, true)
    end
end

AddComponentPostInit("simplemagicgrower", function(self)
    local _Grow = self.Grow
    function self:Grow()
        if _Grow then
            _Grow(self)
        end
        local inst = self.inst
        if inst.prefab == "tubertree" and inst.tubers < inst.maxtubers then
            inst.tubers = inst.maxtubers
            inst.AnimState:PlayAnimation("grow_short_to_tall")
            inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/volcano_cactus/grow_pre")
            UpdateTubers(inst, inst.tubers)
            PushSway(inst)
        end
    end
end)



