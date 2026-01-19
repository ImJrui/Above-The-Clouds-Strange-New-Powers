local AddAction = AddAction
local AddComponentAction = AddComponentAction
local AddStategraphActionHandler = AddStategraphActionHandler

GLOBAL.setfenv(1, GLOBAL)

local COMPONENT_ACTIONS = ToolUtil.GetUpvalue(EntityScript.CollectActions, "COMPONENT_ACTIONS")
local SCENE = COMPONENT_ACTIONS.SCENE
local USEITEM = COMPONENT_ACTIONS.USEITEM
-- local POINT = COMPONENT_ACTIONS.POINT
local EQUIPPED = COMPONENT_ACTIONS.EQUIPPED
local INVENTORY = COMPONENT_ACTIONS.INVENTORY

local SCYTHE_ONEOFTAGS = {"plant", "lichen", "oceanvine", "kelp"}
local KITCOON_MUST_TAGS = {"kitcoonden"}

local function IsValidScytheTarget(target)
    return target:HasOneOfTags(SCYTHE_ONEOFTAGS)
end

if not rawget(_G, "HotReloading") then
    _G.PLREBALANCE_ACTIONS = {
        PORKLANDREBALANCE_REGENERATERUINS = Action({priority = 1, distance = 3}),
        PORKLANDREBALANCE_LOCKSHOP = Action({priority = 1, distance = 1}),
        PORKLANDREBALANCE_LOCKSHOPREFRESH = Action({priority = 1, distance = 1}),
		PORKLANDREBALANCE_WALTERAIMEDSHOT = Action({priority = 1, distance = 10, mount_valid=true}),
    }

    for name, ACTION in pairs(_G.PLREBALANCE_ACTIONS) do
        ACTION.id = name
        ACTION.str = STRINGS.ACTIONS[name] or name
        AddAction(ACTION)
    end
end

ACTIONS.PORKLANDREBALANCE_REGENERATERUINS.fn = function(act)
    if act.target and act.target:IsValid() and act.target.components.plrebalance_ruinsregeneratingtarget and not act.target:HasTag("plrebalance_cannotreset") and act.invobject and act.invobject.components.plrebalance_ruinsregenerating then
        return act.invobject.components.plrebalance_ruinsregenerating:RegenerateRuins(act.target)
    end
end

ACTIONS.PORKLANDREBALANCE_LOCKSHOP.fn = function(act)
	local shopbuyer = act.target and act.target:IsValid() and act.target.replica.visualslot and act.target.replica.visualslot:GetShelf() or nil
	if act.invobject:HasTag("plrebalance_shoplockerhascharges") and shopbuyer and act.invobject and act.invobject.components.plrebalance_shoppedlocking then
        return act.invobject.components.plrebalance_shoppedlocking:LockShop(shopbuyer, act.invobject)
	end
end

ACTIONS.PORKLANDREBALANCE_LOCKSHOPREFRESH.fn = function(act)
	local shopbuyer = act.target and act.target:IsValid() and act.target.replica.visualslot and act.target.replica.visualslot:GetShelf() or nil
	if shopbuyer and act.invobject and act.invobject.components.plrebalance_shoppedlockingrefresher then
        return act.invobject.components.plrebalance_shoppedlockingrefresher:RefreshLockShop(shopbuyer, act.doer, act.invobject)
	end
end

ACTIONS.PORKLANDREBALANCE_WALTERAIMEDSHOT.fn = function(act)
	local slingshot = act.invobject or act.doer.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
    slingshot.components.plrebalance_walteraimedshot:DoAttack(act.doer, act.target, slingshot)
    return true
end

ACTIONS.PORKLANDREBALANCE_LOCKSHOP.stroverridefn = function(act)	
	local shopbuyer = act.target and act.target:IsValid() and act.target.replica.visualslot and act.target.replica.visualslot:GetShelf() or nil
	if act.invobject:HasTag("plrebalance_shoplockerhascharges") and shopbuyer and shopbuyer:HasTag("plrebalance_shoppedlockable") and
		not shopbuyer:HasTag("plrebalance_saleitem") and --item already locked
		not shopbuyer:HasTag("plrebalance_saleitemlocked") and --ditto
		not shopbuyer:HasTag("justsellonce") and --will not restock
		not shopbuyer:HasTag("robbed") then
		local item = act.target.replica.visualslot:GetItem()
		if item then
			return subfmt(STRINGS.ACTIONS.PORKLANDREBALANCE_LOCKSHOP, { item = item:GetBasicDisplayName() })
		end
	end
	return ""
end

local PL_COMPONENT_ACTIONS =
{
	EQUIPPED = {
		plrebalance_walteraimedshot = function(inst, doer, target, actions, right)
            if right and inst:HasTag("PLREBALANCE_SLINGSHOTPOINTTARGET") and target ~= nil and (
				target:HasTag("CHOP_WORKABLE") or
				target:HasTag("MINE_WORKABLE") or
				target:HasTag("DIG_WORKABLE") or
				target:HasTag("HACK_WORKABLE") or
				target:HasTag("HAMMER_WORKABLE") or
				target:HasTag("PICKABLE"))
			then
                table.insert(actions, ACTIONS.PORKLANDREBALANCE_WALTERAIMEDSHOT)
            end
        end,
	},
	USEITEM = { -- args: inst, doer, target, actions, right
		plrebalance_ruinsregenerating = function(inst, doer, target, actions, right)
			if target.components.plrebalance_ruinsregeneratingtarget and not target:HasTag("plrebalance_cannotreset") then
				table.insert(actions, ACTIONS.PORKLANDREBALANCE_REGENERATERUINS)
			end
		end,
		plrebalance_shoppedlocking = function(inst, doer, target, actions, right)
			local shopbuyer = target.replica.visualslot and target.replica.visualslot:GetShelf() or nil
			if inst:HasTag("plrebalance_shoplockerhascharges") and shopbuyer and shopbuyer:HasTag("plrebalance_shoppedlockable") and
				not shopbuyer:HasTag("plrebalance_saleitem") and --item already locked
				not shopbuyer:HasTag("plrebalance_saleitemlocked") and --ditto
				not shopbuyer:HasTag("justsellonce") and --will not restock
				not shopbuyer:HasTag("robbed") then
				table.insert(actions, ACTIONS.PORKLANDREBALANCE_LOCKSHOP)
			end
		end,
		plrebalance_shoppedlockingrefresher = function(inst, doer, target, actions, right)
			local shopbuyer = target.replica.visualslot and target.replica.visualslot:GetShelf() or nil
			if shopbuyer and shopbuyer:HasTag("plrebalance_shoppedlockable") and
				shopbuyer:HasTag("plrebalance_saleitemlocked") and --ditto
				not shopbuyer:HasTag("robbed") then
				table.insert(actions, ACTIONS.PORKLANDREBALANCE_LOCKSHOPREFRESH)
			end
		end,

	},
	ISVALID = { -- args: inst, action, right
		shearable = function(inst, action, right)
			return action == ACTIONS.SCYTHE and inst:HasTag("SHEAR_workable")
		end,
	},
}

for actiontype, actons in pairs(PL_COMPONENT_ACTIONS) do
    for component, fn in pairs(actons) do
        AddComponentAction(actiontype, component, fn)
    end
end

---- Action handlers

local actionhandlers = {
    ActionHandler(ACTIONS.PORKLANDREBALANCE_REGENERATERUINS, "give"),
    ActionHandler(ACTIONS.PORKLANDREBALANCE_LOCKSHOP, "give"),
    ActionHandler(ACTIONS.PORKLANDREBALANCE_LOCKSHOPREFRESH, "give"),
    ActionHandler(ACTIONS.PORKLANDREBALANCE_WALTERAIMEDSHOT, "slingshot_special"),
}

for _, actionhandler in ipairs(actionhandlers) do
    AddStategraphActionHandler("wilson", actionhandler)
end

for _, actionhandler in ipairs(actionhandlers) do
    AddStategraphActionHandler("wilson_client", actionhandler)
end

-- AddActionPostInit("SCYTHE", function(act)
--     -- 添加或覆盖 strfn 函数
--     act.strfn = function(act)
--         -- 检查动作的目标是否存在，并且目标拥有“harvestable”或类似标签
--         if act.target ~= nil then
--             -- 这是最常见的判断方式：如果目标是可收获的，就返回 "HARVEST"
--             if act.target:HasTag("plant") then
--                 return "SCYTHE"
--             end
--             -- 你可以根据目标的其它标签返回不同的字符串
--             -- elseif act.target:HasTag("someOtherTag") then
--             --     return "SOME_OTHER_STRING"
--             -- end
--         end
--         -- 如果不符合任何条件，返回 nil，游戏可能会显示默认文本
--         return nil
--     end
-- end)