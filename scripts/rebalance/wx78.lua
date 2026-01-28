local AddDeconstructRecipe = AddDeconstructRecipe
local AddRecipe2 = AddRecipe2
local AddRecipeFilter = AddRecipeFilter
local AddPrototyperDef = AddPrototyperDef
local AddRecipePostInit = AddRecipePostInit

local AddPrefabPostInit = AddPrefabPostInit
local AddPlayerPostInit = AddPlayerPostInit
local AddClassPostConstruct = AddClassPostConstruct

GLOBAL.setfenv(1, GLOBAL)

--WX

local ModuleDefs = require("wx78_moduledefs")
local Grogginess = require("components/grogginess")
local Moisture = require("components/moisture")
local Hayfever = require("components/hayfever")

local FogOver = require("widgets/fogover")

ModuleDefs.AddCreatureScanDataDefinition("pigman_storeowner", "music", 4)
ModuleDefs.AddCreatureScanDataDefinition("pigman_storeowner_shopkeep", "music", 4)
ModuleDefs.AddCreatureScanDataDefinition("pigman_queen", "music", 6)

ModuleDefs.AddCreatureScanDataDefinition("piko", "movespeed", 2)
ModuleDefs.AddCreatureScanDataDefinition("pigbandit", "movespeed2", 3)

ModuleDefs.AddCreatureScanDataDefinition("pugalisk", "cold", 6)
ModuleDefs.AddCreatureScanDataDefinition("pugalisk_body", "cold", 6)
ModuleDefs.AddCreatureScanDataDefinition("pugalisk_tail", "cold", 6)
ModuleDefs.AddCreatureScanDataDefinition("pugalisk_segment", "cold", 6)

ModuleDefs.AddCreatureScanDataDefinition("glowfly", "light", 2)
ModuleDefs.AddCreatureScanDataDefinition("glowfly_cocoon", "light", 2)
ModuleDefs.AddCreatureScanDataDefinition("rabid_beetle", "light", 2)

ModuleDefs.AddCreatureScanDataDefinition("weevole", "maxhealth", 2)
ModuleDefs.AddCreatureScanDataDefinition("snake_amphibious", "maxhealth", 2)
ModuleDefs.AddCreatureScanDataDefinition("spider_monkey", "maxhealth2", 4)

ModuleDefs.AddCreatureScanDataDefinition("pog", "maxhunger1", 2)
ModuleDefs.AddCreatureScanDataDefinition("mean_flytrap", "maxhunger", 3)
ModuleDefs.AddCreatureScanDataDefinition("adult_flytrap", "maxhunger", 4)

ModuleDefs.AddCreatureScanDataDefinition("thunderbird", "taser", 3)

ModuleDefs.AddCreatureScanDataDefinition("antqueen", "bee", 6)

--nightvision fix

local NIGHTVISION = nil

for i=1, #ModuleDefs.module_definitions do
	if NIGHTVISION == nil and ModuleDefs.module_definitions[i].name == "nightvision" then
		NIGHTVISION = ModuleDefs.module_definitions[i]
		break
	end
end

local _nightvision_activate = NIGHTVISION.activatefn
local _nightvision_deactivate = NIGHTVISION.deactivatefn

local _nightvision_onworldstateupdate = ToolUtil.GetUpvalue(_nightvision_activate, "nightvision_onworldstateupdate")

local function nightvision_onworldstateupdate(wx)
    if wx:HasTag("inside_interior") then
		wx:SetForcedNightVision(true)
		local x, _, z = wx.Transform:GetWorldPosition()
		for _, v in ipairs(TheSim:FindEntities(x, 0, z, TUNING.ROOM_FINDENTITIES_RADIUS, {"safelight"})) do --find safelight
			wx:SetForcedNightVision(false)
			return
		end
		return
	end
	_nightvision_onworldstateupdate(wx)
end

function NIGHTVISION.activatefn(inst, wx)
	_nightvision_activate(inst, wx)

    if wx._nightvision_modcount > 0 and TheWorld ~= nil and wx.SetForcedNightVision ~= nil then
        inst:ListenForEvent("enterinterior", nightvision_onworldstateupdate, wx)
        inst:ListenForEvent("leaveinterior", nightvision_onworldstateupdate, wx)
    end
end

function NIGHTVISION.deactivatefn(inst, wx)
	_nightvision_deactivate(inst, wx)

    if wx._nightvision_modcount == 0 and TheWorld ~= nil and wx.SetForcedNightVision ~= nil then
        inst:RemoveEventCallback("enterinterior", nightvision_onworldstateupdate, wx)
        inst:RemoveEventCallback("leaveinterior", nightvision_onworldstateupdate, wx)
    end
end

ToolUtil.SetUpvalue(_nightvision_activate, "nightvision_onworldstateupdate", nightvision_onworldstateupdate)

--womant tag missing，now moved to bosshp.lua

-- AddPrefabPostInit("antqueen", function(inst)
-- 	inst:AddTag("largecreature")
-- end)

--humid module

local OldFogProofChange = Grogginess.OnFogProofChange

function Grogginess.OnFogProofChange(inst, data)
	if (inst:HasTag("PorklandRebalance_WX_FogImmune") or inst:HasTag("PorklandRebalance_WX_FogImmune_Ally")) then
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

local _GetDryingRate = Moisture.GetDryingRate

function Moisture:GetDryingRate(...)
    local rate = _GetDryingRate(self, ...)

    if (self.inst:HasTag("PorklandRebalance_WX_FogImmune") or self.inst:HasTag("PorklandRebalance_WX_FogImmune_Ally")) and TheWorld.state.fullfog then
        rate = rate + TUNING.HYDRO_BONUS_COOL_RATE
    end
    return rate
end

local _UpdateAlpha = FogOver.UpdateAlpha

local activated_alpha = 0.3

function FogOver:UpdateAlpha(dt, ...)
    _UpdateAlpha(self, dt, ...)
	
	self.PorklandRebalance_WX_FogImmune_AlphaTarget = self.PorklandRebalance_WX_FogImmune_AlphaTarget or 1
	self.PorklandRebalance_WX_FogImmune_time = self.PorklandRebalance_WX_FogImmune_time or 0
	if self.owner:HasTag("PorklandRebalance_WX_FogImmune") or self.owner:HasTag("PorklandRebalance_WX_FogImmune_Ally") then
		if not self.PorklandRebalance_WX_FogImmune then
			self.PorklandRebalance_WX_FogImmune_AlphaGoal = activated_alpha
			self.PorklandRebalance_WX_FogImmune = true
			self.PorklandRebalance_WX_FogImmune_time = 2 - self.PorklandRebalance_WX_FogImmune_time
		end
	else
		if self.PorklandRebalance_WX_FogImmune then
			self.PorklandRebalance_WX_FogImmune_AlphaGoal = 1
			self.PorklandRebalance_WX_FogImmune = false
			self.PorklandRebalance_WX_FogImmune_time = 2 - self.PorklandRebalance_WX_FogImmune_time
		end
	end
	if self.PorklandRebalance_WX_FogImmune_time > 0 then
        self.PorklandRebalance_WX_FogImmune_time = math.max(0, self.PorklandRebalance_WX_FogImmune_time - dt)
		if self.PorklandRebalance_WX_FogImmune_AlphaGoal < self.PorklandRebalance_WX_FogImmune_AlphaTarget then
			self.PorklandRebalance_WX_FogImmune_AlphaTarget = Remap(self.PorklandRebalance_WX_FogImmune_time, 2, 0, 1, activated_alpha)
		else
			self.PorklandRebalance_WX_FogImmune_AlphaTarget = Remap(self.PorklandRebalance_WX_FogImmune_time, 2, 0, activated_alpha, 1)
		end
	end
	if self.time == 0 then self.alpha = self.alphagoal end
	self.alpha = self.alpha * self.PorklandRebalance_WX_FogImmune_AlphaTarget
end

--lush module

AddPlayerPostInit(function(inst)
	inst.HasTag_Old = inst.HasTag
	function inst:HasTag(tag, ...)
		if tag == "has_gasmask" and inst:HasTag_Old("PorklandRebalance_WX_GasMask") then
			return true
		end
		return inst:HasTag_Old(tag, ...)
	end
end)

--module graphics
local modmodule={"porklandrebalance_fan","porklandrebalance_filter",}--以后可以加新的

AddClassPostConstruct( "widgets/upgrademodulesdisplay", function(self)--右边显示模块的动画
	local oldOnModuleAdded = self.OnModuleAdded
	function self:OnModuleAdded(moduledefinition_index,...)
	
		oldOnModuleAdded(self,moduledefinition_index,...)--执行旧函数
		local module_def = ModuleDefs.GetModuleDefinitionFromNetID(moduledefinition_index)--根据id获取模块
		if module_def == nil then
			return
		end
		local modname = module_def.name--获取模块名称
		for k, v in pairs(modmodule) do
			if modname==v then--是本模组的模块
				local new_chip = self.chip_objectpool[self.chip_poolindex-1]--旧函数执行self.chip_poolindex+1了，这里要-1
				new_chip:GetAnimState():OverrideSymbol("movespeed2_chip", "wx_circuits_porkland", modname.."_chip")--动画覆盖
			end
		end
	end
end)