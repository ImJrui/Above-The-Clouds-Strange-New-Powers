local AddDeconstructRecipe = AddDeconstructRecipe
local AddRecipe2 = AddRecipe2
local AddRecipeFilter = AddRecipeFilter
local AddPrototyperDef = AddPrototyperDef
local AddRecipePostInit = AddRecipePostInit

local AddPrefabPostInit = AddPrefabPostInit
local AddPlayerPostInit = AddPlayerPostInit
local AddClassPostConstruct = AddClassPostConstruct

local PLENV = env
GLOBAL.setfenv(1, GLOBAL)

--Nobi

local ShadowWaxwellBrain = require("brains/shadowwaxwellbrain")

local DIG_TAGS = {"magmarock", "magmarock_gold", "sanddune", "buriedtreasure"}
local _DIG_TAGS = ToolUtil.GetUpvalue(ShadowWaxwellBrain.OnStart, "DIG_TAGS")

for i,tag in pairs(DIG_TAGS) do
    table.insert(_DIG_TAGS, tag)
end

local ANY_TOWORK_MUSTONE_TAGS = {"SHEAR_workable", "HACK_workable"}
local _FindAnyEntityToWorkActionsOn = ToolUtil.GetUpvalue(ShadowWaxwellBrain.OnStart, "FindAnyEntityToWorkActionsOn")
local _ANY_TOWORK_MUSTONE_TAGS = ToolUtil.GetUpvalue(_FindAnyEntityToWorkActionsOn, "ANY_TOWORK_MUSTONE_TAGS")

for i,tag in pairs(ANY_TOWORK_MUSTONE_TAGS) do
    table.insert(_ANY_TOWORK_MUSTONE_TAGS, tag)
end

local TOWORK_CANT_TAGS = {"limpet_rock", "flippable"}
local _TOWORK_CANT_TAGS = ToolUtil.GetUpvalue(_FindAnyEntityToWorkActionsOn, "TOWORK_CANT_TAGS")

for i,tag in pairs(TOWORK_CANT_TAGS) do
    table.insert(_TOWORK_CANT_TAGS, tag)
end

local function GetLeader(inst)
    return inst.components.follower.leader
end

-- Ugh this is painful
local _PickValidActionFrom = ToolUtil.GetUpvalue(_FindAnyEntityToWorkActionsOn, "PickValidActionFrom")
local IgnoreThis = ToolUtil.GetUpvalue(_FindAnyEntityToWorkActionsOn, "IgnoreThis")
local _FilterAnyWorkableTargets = ToolUtil.GetUpvalue(_FindAnyEntityToWorkActionsOn, "FilterAnyWorkableTargets")

-- Note: Storing globals in lua is much more effecient than calling the global constantly -Half
local HACK_ACTION = ACTIONS.HACK
local SHEAR_ACTION = ACTIONS.SHEAR

local function can_hack(target)
	return target.tubers ~= 0
end

local function PickValidActionFrom(target, ...)
    if target.components.shearable ~= nil and target.components.shearable:CanShear()then
        return SHEAR_ACTION
    end
	
    if target.components.hackable ~= nil and (target.components.workable == nil or target.components.hackable:CanBeWorked()) then
        return HACK_ACTION
    end

    return _PickValidActionFrom(target, ...)
end

local function FilterAnyWorkableTargets(targets, ignorethese, leader, worker, ...)
    -- Needed to stop conflicts with diggable
    for _, sometarget in ipairs(targets) do
        if ignorethese[sometarget] ~= nil and ignorethese[sometarget].worker ~= worker then
            -- Ignore me!
        elseif sometarget.components.burnable == nil or (not sometarget.components.burnable:IsBurning() and not sometarget.components.burnable:IsSmoldering()) then
            if sometarget:HasTag("SHEAR_workable") then
				IgnoreThis(sometarget, ignorethese, leader, worker) --workers will always ignore sheared targets so it's faster.
                return sometarget
            end
            if sometarget:HasTag("HACK_workable") then
				if not can_hack(sometarget) then
                    IgnoreThis(sometarget, ignorethese, leader, nil) --nil here so this worker also ignores this
				else
					return sometarget --if cannot hack, don't even return once
                end
            end
            if sometarget:HasTag("DISLODGE_workable") then
				if not sometarget.prefab:find("ruins_statue") then
                    IgnoreThis(sometarget, ignorethese, leader, nil) --nil here so this worker also ignores this
				else
					return sometarget --if cannot hack, don't even return once
                end
            end
        end
    end
    return _FilterAnyWorkableTargets(targets, ignorethese, leader, worker, ...)
end

local function FindAnyEntityToWorkActionsOn(inst, ignorethese, ...)
	local rv = nil
	if inst.sg:HasStateTag("busy") then
		return _FindAnyEntityToWorkActionsOn(inst, ignorethese, ...)
	end
    local leader = GetLeader(inst)
    if leader == nil then -- There is no purpose for a puppet without strings attached.
        return _FindAnyEntityToWorkActionsOn(inst, ignorethese, ...)
    end
	
    local target = inst.sg.statemem.target

    local action = nil
    if target ~= nil and target:IsValid() and not (target:IsInLimbo() or target:HasTag("NOCLICK") or target:HasTag("event_trigger")) and
        target:IsOnValidGround() and (
		(target.components.hackable ~= nil and target.components.hackable:CanBeWorked())
		or (target.components.shearable ~= nil and  target.components.shearable:CanShear())) and
        not (target.components.burnable ~= nil and (target.components.burnable:IsBurning() or target.components.burnable:IsSmoldering())) and
        target.entity:IsVisible() then
        -- Check if action is the one desired still.
        action = PickValidActionFrom(target)

        if action ~= nil and ignorethese[target] == nil then
            --[[if target.components.hackable:GetHacksLeft() == 1 then
                IgnoreThis(target, ignorethese, leader, inst)
            end]]--
			if not can_hack(target) then
				IgnoreThis(target, ignorethese, leader, nil) --nil here so this worker also ignores this
			end
            return BufferedAction(inst, target, action)
        end
    end

    return _FindAnyEntityToWorkActionsOn(inst, ignorethese, ...)
end

-- ToolUtil.SetUpvalue(_FindAnyEntityToWorkActionsOn, PickValidActionFrom, "PickValidActionFrom")
-- ToolUtil.SetUpvalue(_FindAnyEntityToWorkActionsOn, FilterAnyWorkableTargets, "FilterAnyWorkableTargets")
-- ToolUtil.SetUpvalue(ShadowWaxwellBrain.OnStart, FindAnyEntityToWorkActionsOn, "FindAnyEntityToWorkActionsOn")

ToolUtil.SetUpvalue(_FindAnyEntityToWorkActionsOn, "PickValidActionFrom", PickValidActionFrom)
ToolUtil.SetUpvalue(_FindAnyEntityToWorkActionsOn, "FilterAnyWorkableTargets", FilterAnyWorkableTargets)
ToolUtil.SetUpvalue(ShadowWaxwellBrain.OnStart, "FindAnyEntityToWorkActionsOn", FindAnyEntityToWorkActionsOn)

----------------------------------------------------------------------------------------

local function FixupWorkerCarry(inst, swap)
    if inst.prefab == "shadowworker" then
		if inst.sg.mem.swaptool == swap then
			return false
		end
		inst.sg.mem.swaptool = swap
		if swap == nil then
            inst.AnimState:ClearOverrideSymbol("swap_object")
            inst.AnimState:Hide("ARM_carry")
            inst.AnimState:Show("ARM_normal")
        else
            inst.AnimState:Show("ARM_carry")
            inst.AnimState:Hide("ARM_normal")
            inst.AnimState:OverrideSymbol("swap_object", swap, swap)
        end
		return true
    else
        if swap == nil then -- DEPRECATED workers.
            inst.AnimState:Hide("swap_arm_carry")
        --'else' case cannot exist old workers had one item only assumed.
        end
    end
end

local actionhandler_hack =  ActionHandler(
    ACTIONS.HACK,
	function(inst)
		if FixupWorkerCarry(inst, "swap_machete") then
			return "item_out_hack"
		elseif not inst.sg:HasStateTag("prehack") then
			return inst.sg:HasStateTag("hacking")
				and "hack"
				or "hack_start"
		end
	end
)

local actionhandler_shear =  ActionHandler(
    ACTIONS.SHEAR,
	function(inst)
		if FixupWorkerCarry(inst, "swap_shears") then
			return "item_out_shear"
		elseif not inst.sg:HasStateTag("preshear") then
			return inst.sg:HasStateTag("shearing")
				and "shear"
				or "shear_start"
		end
	end
)

local function TryRepeatAction(inst, buffaction, right)
	if buffaction ~= nil and
		buffaction:IsValid() and
		buffaction.target ~= nil and
		(buffaction.target.components.hackable ~= nil or buffaction.target.components.shearable ~= nil) and
		buffaction.target.components.workable == nil and --or will double and bug
		buffaction.target:IsActionValid(buffaction.action, right)
		then
		local otheraction = inst:GetBufferedAction()
		if otheraction == nil or (
			otheraction.target == buffaction.target and
			otheraction.action == buffaction.action
		) then
			inst.components.locomotor:Stop()
			inst:ClearBufferedAction()
			inst:PushBufferedAction(buffaction)
			return true
		end
	end
	return false
end

--[[local function SGshadowmaxwell_hackable(sg)
	local oldfn = sg.states["chop"].timeline[2].fn
	sg.states["chop"].timeline[2].fn = function(inst)
		oldfn(inst)
		TryRepeatAction(inst, inst.sg.statemem.action)
	end
end]]--

local state_item_out_shear = State{
	name = "item_out_shear",
	onenter = function(inst) inst.sg:GoToState("item_out", "shear") end,
}

local state_shear_start =  State{
	name = "shear_start",
	tags = {"preshear", "working"},

	onenter = function(inst)
        inst.Physics:Stop()
		inst.AnimState:PlayAnimation("cut_pre")
	end,

	events =
	{
		--EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
		EventHandler("animover", function(inst)
			if inst.AnimState:AnimDone() then
				inst.sg:GoToState("shear")
			end
		end),
	},
}

local state_shear = State{
	name = "shear",
	tags = {"preshear", "shearing", "working"},

	onenter = function(inst)
		inst.AnimState:PlayAnimation("cut_loop")
		inst.sg.statemem.action = inst:GetBufferedAction()
	end,

	timeline =
	{
		TimeEvent(4 * FRAMES, function(inst)
			inst:PerformBufferedAction()
			inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/harvested/grass_tall/shears")
		end),

		TimeEvent(9 * FRAMES, function(inst)
			inst.sg:RemoveStateTag("preshear")
		end),

		TimeEvent(14 * FRAMES, function(inst)
			TryRepeatAction(inst, inst.sg.statemem.action)
		end),

		TimeEvent(16 * FRAMES, function(inst)
			inst.sg:RemoveStateTag("shearing")
		end),
	},

	events =
	{
		--EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
		EventHandler("animover", function(inst)
			if inst.AnimState:AnimDone() then
				inst.AnimState:PlayAnimation("cut_pst")
				inst.sg:GoToState("idle", true)
			end
		end),
	},
}

--hacking

local state_item_out_hack = State{
	name = "item_out_hack",
	onenter = function(inst) inst.sg:GoToState("item_out", "hack") end,
}

local state_hack_start = State{
	name = "hack_start",
	tags = {"prehack", "working"},

	onenter = function(inst)
		inst.Physics:Stop()
		inst.AnimState:PlayAnimation("chop_pre")
	end,

	events = {
		--EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
		EventHandler("animover", function(inst)
			if inst.AnimState:AnimDone() then
				inst.sg:GoToState("hack")
			end
		end),
	},
}

local state_hack = State{
	name = "hack",
	tags = {"prehack", "hacking", "working"},

	onenter = function(inst)
		inst.sg.statemem.action = inst:GetBufferedAction()
		inst.AnimState:PlayAnimation("chop_loop")
	end,

	timeline = {
		TimeEvent(2*FRAMES, function(inst)
			if not can_hack(inst.sg.statemem.action.target) then
				inst:ClearBufferedAction() --force remove action
				inst.sg:GoToState("idle")
			else
				inst:PerformBufferedAction()
			end
		end),


		TimeEvent(9*FRAMES, function(inst)
			if not can_hack(inst.sg.statemem.action.target) then
				inst:ClearBufferedAction() --force remove action
				inst.sg:GoToState("idle")
			end
		end),

		TimeEvent(14*FRAMES-1, function(inst) --last chance before hack
			if not can_hack(inst.sg.statemem.action.target) then
				inst:ClearBufferedAction() --force remove action
				inst.sg:GoToState("idle")
			end
		end),

		TimeEvent(14*FRAMES, function(inst)
			inst.sg:RemoveStateTag("prehack")
			TryRepeatAction(inst, inst.sg.statemem.action)
		end),

		TimeEvent(16*FRAMES, function(inst)
			inst.sg:RemoveStateTag("hacking")
		end),
	},

	events = {
		--EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
		EventHandler("animover", function(inst)
			if inst.AnimState:AnimDone() then
				inst.sg:GoToState("idle", true)
			end
		end),
	},
}


----------------------------------------------------------------------------------------
--Try to initialise all functions locally outside of the post-init so they exist in RAM only once
----------------------------------------------------------------------------------------

PLENV.AddStategraphActionHandler("shadowmaxwell", actionhandler_hack)
PLENV.AddStategraphActionHandler("shadowmaxwell", actionhandler_shear)
PLENV.AddStategraphState("shadowmaxwell", state_item_out_shear)
PLENV.AddStategraphState("shadowmaxwell", state_shear_start)
PLENV.AddStategraphState("shadowmaxwell", state_shear)
PLENV.AddStategraphState("shadowmaxwell", state_item_out_hack)
PLENV.AddStategraphState("shadowmaxwell", state_hack_start)
PLENV.AddStategraphState("shadowmaxwell", state_hack)