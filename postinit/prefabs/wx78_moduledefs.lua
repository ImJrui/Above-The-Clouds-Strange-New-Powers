GLOBAL.setfenv(1, GLOBAL)

local wx78_moduledefs = require("wx78_moduledefs")
local module_definitions = wx78_moduledefs.module_definitions
local AddNewModuleDefinition = wx78_moduledefs.AddNewModuleDefinition
local GetModuleDefinitionFromNetID = wx78_moduledefs.GetModuleDefinitionFromNetID
local AddCreatureScanDataDefinition = wx78_moduledefs.AddCreatureScanDataDefinition
local GetCreatureScanDataDefinition = wx78_moduledefs.GetCreatureScanDataDefinition
local AddSpecialCreatureScanDataDefinition = wx78_moduledefs.AddSpecialCreatureScanDataDefinition

local ATTACH_RADIUS = {
    [0] = 0,
    [1] = 4,
    [2] = 8,
}

local ATTACH_BONUS = {
    [0] = 1.0,
    [1] = 0.6,
    [2] = 0.3,
}

local function fan_activate(inst, wx)
    wx._fan_modules = (wx._fan_modules or 0) + 1

    if not wx.components.upgrademodulebuff then
        wx:AddComponent("upgrademodulebuff")
    end

    local data = {
        radius = ATTACH_RADIUS[wx._fan_modules] or ATTACH_RADIUS[2],
        bonus = wx._fan_modules,
        onattachedfn = function(player)
            if not player:HasTag("immunefog") then
                player:AddTag("immunefog")
            end
            if player.components.grogginess then
                player.components.grogginess.OnFogProofChange(player)
            end
        end,
        ondetachedfn = function(player)
            if player:HasTag("immunefog") then
                player:RemoveTag("immunefog")
            end
            if player.components.grogginess then
                player.components.grogginess.OnFogProofChange(player)
            end
        end,
        onupdatedfn = function(player, bonus)
            if player._fogoveralpha then
                player._fogoveralpha:set(ATTACH_BONUS[bonus] or ATTACH_BONUS[2])
            end
        end,
    }

    wx.components.upgrademodulebuff:AddAuraSource("fan_module_buff", data)
end

local function fan_deactivate(inst, wx)
    wx._fan_modules = (wx._fan_modules or 1) - 1
    if wx._fan_modules <= 0 then
        wx._fan_modules = nil
    end

    if wx.components.upgrademodulebuff then
        if wx._fan_modules and wx._fan_modules > 0 then
            local data = {
                radius = ATTACH_RADIUS[wx._fan_modules] or ATTACH_RADIUS[2],
                bonus = wx._fan_modules,
            }
            wx.components.upgrademodulebuff:UpdateAura("fan_module_buff", data)
        else
            wx.components.upgrademodulebuff:RemoveAura("fan_module_buff")
        end
    end
end

local FAN_MODULE_DATA =
{
    name = "porklandrebalance_fan",
    type = CIRCUIT_BARS.BETA,
    slots = 3,
    activatefn = fan_activate,
    deactivatefn = fan_deactivate,
    overridebank = "chips",
    overridebuild = "wx_newmodules",
    overrideuibuild = "wx_circuits_porkland",
    overrideminiuibuild = "pl_status_wx",
}
table.insert(module_definitions, FAN_MODULE_DATA)

AddCreatureScanDataDefinition("gnat", "porklandrebalance_fan", 1)

AddNewModuleDefinition(FAN_MODULE_DATA)

---------------------------------------------------------------

local function filter_activate(inst, wx)
    wx._filter_modules = (wx._filter_modules or 0) + 1

    if not wx.components.upgrademodulebuff then
        wx:AddComponent("upgrademodulebuff")
    end

    local data = {
        radius = ATTACH_RADIUS[wx._filter_modules] or ATTACH_RADIUS[2],
        bonus = wx._filter_modules,
        onattachedfn = function(player)
            if not player:HasTag("immunehayfever") then
                player:AddTag("immunehayfever")
            end
        end,
        ondetachedfn = function(player)
            if player:HasTag("immunehayfever") then
                player:RemoveTag("immunehayfever")
            end
        end
    }

    wx.components.upgrademodulebuff:AddAuraSource("filter_module_buff", data)
end

local function filter_deactivate(inst, wx)
    wx._filter_modules = (wx._filter_modules or 1) - 1
    if wx._filter_modules <= 0 then
        wx._filter_modules = nil
    end

    if wx.components.upgrademodulebuff then
        if wx._filter_modules and wx._filter_modules > 0 then
            local data = {
                radius = ATTACH_RADIUS[wx._filter_modules] or ATTACH_RADIUS[2],
                bonus = wx._filter_modules,
            }
            wx.components.upgrademodulebuff:UpdateAura("filter_module_buff", data)
        else
            wx.components.upgrademodulebuff:RemoveAura("filter_module_buff")
        end
    end
end

local FILTER_MODULE_DATA =
{
    name = "porklandrebalance_filter",
    type = CIRCUIT_BARS.BETA,
    slots = 3,
    activatefn = filter_activate,
    deactivatefn = filter_deactivate,
    overridebank = "chips",
    overridebuild = "wx_newmodules",
    overrideuibuild = "wx_circuits_porkland",
    overrideminiuibuild = "pl_status_wx",
}
table.insert(module_definitions, FILTER_MODULE_DATA)

AddCreatureScanDataDefinition("peagawk", "porklandrebalance_filter", 4)

AddNewModuleDefinition(FILTER_MODULE_DATA)

---------------------------------------------------------------
--nightvision fix

local NIGHTVISION = {}

for i=1, #module_definitions do
	if module_definitions[i].name == "nightvision" then
		NIGHTVISION = module_definitions[i]
		break
	end
end

local _nightvision_activate = NIGHTVISION.activatefn
local _nightvision_deactivate = NIGHTVISION.deactivatefn

local _OnNightVisionUpdate = ToolUtil.GetUpvalue(_nightvision_activate, "OnNightVisionUpdate")

local function OnNightVisionUpdate(wx)
    if wx:HasTag("inside_interior") then
		local playervision = wx.components.playervision
		if playervision then
			local nonightvisioncc = wx.components.skilltreeupdater:IsActivated("wx78_circuitry_betabuffs_1")
			playervision:PushForcedNightVision(wx, 0, nil, nil, nil, nonightvisioncc)
		end
		return
    end
    _OnNightVisionUpdate(wx)
end

local function nightvision_common_activate(inst, wx)
    _nightvision_activate(inst, wx)

    if wx._nightvision_modcount == 1 then
		if TheWorld.ismastersim then
			wx:ListenForEvent("enterinterior", OnNightVisionUpdate)
			wx:ListenForEvent("leaveinterior", OnNightVisionUpdate)
		else
			wx:ListenForEvent("enterinterior_client", OnNightVisionUpdate)
			wx:ListenForEvent("leaveinterior_client", OnNightVisionUpdate)
		end
	end
end

local function nightvision_common_deactivate(inst, wx)
    _nightvision_deactivate(inst, wx)

    if wx._nightvision_modcount == 0 then
		if TheWorld.ismastersim then
			wx:RemoveEventCallback("enterinterior", OnNightVisionUpdate)
			wx:RemoveEventCallback("leaveinterior", OnNightVisionUpdate)
		else
			wx:RemoveEventCallback("enterinterior_client", OnNightVisionUpdate)
			wx:RemoveEventCallback("leaveinterior_client", OnNightVisionUpdate)
		end
    end
end

NIGHTVISION.activatefn = nightvision_common_activate
NIGHTVISION.deactivatefn = nightvision_common_deactivate

NIGHTVISION.client_activatefn = nightvision_common_activate
NIGHTVISION.client_deactivatefn = nightvision_common_deactivate

ToolUtil.SetUpvalue(_nightvision_activate, "OnNightVisionUpdate", OnNightVisionUpdate)

---------------------------------------------------------------

AddCreatureScanDataDefinition("pigman_storeowner", "music", 4)
AddCreatureScanDataDefinition("pigman_storeowner_shopkeep", "music", 4)
AddCreatureScanDataDefinition("pigman_queen", "music", 6)

AddCreatureScanDataDefinition("piko", "movespeed", 2)
AddCreatureScanDataDefinition("pigbandit", "movespeed2", 3)

AddCreatureScanDataDefinition("pugalisk", "cold", 6)
AddCreatureScanDataDefinition("pugalisk_body", "cold", 6)
AddCreatureScanDataDefinition("pugalisk_tail", "cold", 6)

AddCreatureScanDataDefinition("glowfly", "light2", 2)
AddCreatureScanDataDefinition("glowfly_cocoon", "light2", 2)
AddCreatureScanDataDefinition("rabid_beetle", "light2", 2)

AddCreatureScanDataDefinition("weevole", "maxhealth", 2)
AddCreatureScanDataDefinition("snake_amphibious", "maxhealth", 2)
AddCreatureScanDataDefinition("spider_monkey", "maxhealth2", 4)

AddCreatureScanDataDefinition("pog", "maxhunger1", 2)
AddCreatureScanDataDefinition("mean_flytrap", "maxhunger", 3)
AddCreatureScanDataDefinition("adult_flytrap", "maxhunger", 4)

AddCreatureScanDataDefinition("thunderbird", "taser", 3)

AddCreatureScanDataDefinition("antqueen", "bee", 6)

AddCreatureScanDataDefinition("pangolden", "shielding", 4)

AddCreatureScanDataDefinition("ancient_herald", "heat", 10)

AddCreatureScanDataDefinition("vampirebat", "screech", 4)

-- AddCreatureScanDataDefinition("catcoon", "digestion", 2)

AddCreatureScanDataDefinition("bill", "spin", 3)

local function GetIsBirdFn(cage_or_trap, scanid)
    local birdprefab
    if cage_or_trap.components.occupiable ~= nil then
        local bird = cage_or_trap.components.occupiable:GetOccupant()
        birdprefab = bird ~= nil and bird.prefab or nil
    elseif cage_or_trap.components.trap ~= nil and cage_or_trap.components.trap.lootprefabs ~= nil then
        birdprefab = cage_or_trap.components.trap.lootprefabs[1]
    end

    return birdprefab == scanid
end

AddSpecialCreatureScanDataDefinition("toucan", GetIsBirdFn, "radar", 2)
AddSpecialCreatureScanDataDefinition("pigeon", GetIsBirdFn, "radar", 2)
AddSpecialCreatureScanDataDefinition("parrot_blue", GetIsBirdFn, "radar", 2)
AddSpecialCreatureScanDataDefinition("kingfisher", GetIsBirdFn, "radar", 2)
AddSpecialCreatureScanDataDefinition("pl_crow", GetIsBirdFn, "radar", 2)
AddSpecialCreatureScanDataDefinition("pl_robin", GetIsBirdFn, "radar", 2)