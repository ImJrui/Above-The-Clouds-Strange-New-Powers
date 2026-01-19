-- Traders

local AddSimPostInit = AddSimPostInit
local AddPrefabPostInit = AddPrefabPostInit

PigShopExpander = {}
local PigShopExpander = PigShopExpander
GLOBAL.setfenv(1, GLOBAL)

local SHOPTYPES = require("prefabs/pig_shop_defs").SHOPTYPES

local shops = {
    pig_shop_antiquities = {  -- 古董店
        { "tentaclespots",				"oinc",			5   },
        { "messagebottleempty",			"oinc",			10  },
    },
    pig_shop_florist = {      -- 花艺店
        { "pinecone",					"oinc",			1   },
        -- { "soil_amender",				"oinc",			10  },
        -- { "seedpouch",					"oinc",			20  },
    },
    pig_shop_produce = {      -- 农产品店
        { "coi",						"oinc",			3   },
    },
}

for shop_type, items in pairs(shops) do
    SHOPTYPES[shop_type] = SHOPTYPES[shop_type] or {}
    for _, item in ipairs(items) do
        table.insert(SHOPTYPES[shop_type], item)
    end
end

local SHOPTYPES_PLREBALANCE = require("prefabs/plrebalance_pig_shop_defs").SHOPTYPES

local function OnUseMayorMandate(inst)
	inst.plrebalance_mayormandatecharges = inst.plrebalance_mayormandatecharges - 1
	inst:PLRebalance_UpdateExtraVisualCharges()
	if inst.plrebalance_mayormandatecharges == 0 then
		inst.plrebalance_mayormandateitem = nil
		inst.plrebalance_mayormandatecharges = nil
		
		local x,y,z = inst.Transform:GetWorldPosition()
		
		local angle = math.random() * 0.25 * math.pi + 0.125 * math.pi
		local cosa = math.cos(angle)
		local sina = math.sin(angle)
		local speed = math.random() * 1 + 2
		
		local shoplocker = SpawnPrefab("shoplocker")
		shoplocker.Physics:Teleport(x + cosa * 0.2,y,z + cosa * 0.2)
		shoplocker.Physics:SetVel(speed * cosa, math.random() * 0.8 + 5, speed * sina)
		shoplocker.components.finiteuses:SetUses(0)
	end
end

AddSimPostInit(function()
	-- shop_buyer

	local _restock = ToolUtil.GetUpvalue(Prefabs.shop_buyer.fn, "Restock")
	--local _GetNewProduct = ToolUtil.GetUpvalue(_restock, "GetNewProduct")

	local function GetNewProduct(inst)
		
		if inst.plrebalance_mayormandateitem then --mayor mandate
			local rv = inst.plrebalance_mayormandateitem
			OnUseMayorMandate(inst)
			return rv
		end
		
		if not inst.shop_type then
			return
		end
		local items = TheWorld.state.isfiesta and (SHOPTYPES[inst.shop_type .. "_fiesta"] or SHOPTYPES_PLREBALANCE[inst.shop_type .. "_fiesta"]) or SHOPTYPES[inst.shop_type] or SHOPTYPES_PLREBALANCE[inst.shop_type]
		local num = 0
		if items then
			num = #items
		end
		local otherItems = inst.plrebalance_otheritems
		if otherItems then
			num = num + #otherItems
		end
		local rng = math.random(1, num)
		if rng <= #items then
			return items[rng]
		else
			return otherItems[rng - #items]
		end
	end
	
	local function Restock(inst, force, ...)
		if inst.plrebalance_mayormandateitem and not force and inst.components.shopped:GetItemToSell() then return end --prevent restocking if has shoplocker
		return _restock(inst, force, ...)
	end
	
	-- ToolUtil.SetUpvalue(_restock, GetNewProduct, "GetNewProduct")
	-- ToolUtil.SetUpvalue(Prefabs.shop_buyer.fn, Restock, "Restock")
	ToolUtil.SetUpvalue(_restock, "GetNewProduct", GetNewProduct)
	ToolUtil.SetUpvalue(Prefabs.shop_buyer.fn, "Restock", Restock)
end)

local front_cost_visuals = --too lazy to get up value
{
    idle_traystand = true,
    idle_cablespool = true,
    idle_wagon = true,
    idle_cakestand_dome = true,
    idle_fridge_display = true,
    idle_mahoganycase = true,
    idle_stoneslab = true,
    idle_metal = true,
    idle_yotp = true,
    idle_marble_dome = true,
}

local function UpdateExtraVisualCharges(inst)
	local charges = inst.plrebalance_mayormandatecharges
	if charges and charges ~= 0 then
		inst:AddTag("plrebalance_saleitemlocked")
		if charges > 20 then
			inst.plrebalance_extravisual.AnimState:OverrideSymbol("SWAP_COST", "plrebalance_royalseal", "royalseal")
		elseif charges > 10 then
			inst.plrebalance_extravisual.AnimState:OverrideSymbol("SWAP_COST", "plrebalance_royalseal", "royalseal2")
		else
			inst.plrebalance_extravisual.AnimState:OverrideSymbol("SWAP_COST", "plrebalance_royalseal", "royalseal3")
		end
		inst.plrebalance_extravisual.AnimState:Show("SWAP_COST")
	else
		inst:RemoveTag("plrebalance_saleitemlocked")
		inst.plrebalance_extravisual.AnimState:Hide("SWAP_COST")
	end
end

local function UpdateExtraVisual(inst, anim)
    inst.AnimState:PlayAnimation(anim)
    if front_cost_visuals[anim] then
        inst.AnimState:SetFinalOffset(5)
        inst.Follower:FollowSymbol(inst.parentshelf.GUID, nil, 0, 0, 0.0021) -- 毫无疑问，这是为了解决层级bug的屎山，因为有时SetFinalOffset会失效（特别是在离0点特别远的位置）
    else
        inst.AnimState:SetFinalOffset(1)
        inst.Follower:FollowSymbol(inst.parentshelf.GUID, nil, 0, 0, 0.00051) -- 价格牌默认图层低于玻璃罩和物品，高于货架本体
    end
end

local function CreateExtraVisual(inst) -- extra display on cost
    local extravisual = SpawnPrefab("shop_buyer_costvisual")
    extravisual.parentshelf = inst
    extravisual.entity:SetParent(inst.entity)

	extravisual.UpdateVisual = UpdateExtraVisual
    extravisual:UpdateVisual(inst.animation)
	
    extravisual.AnimState:Hide("pedestal_sign") --remove unnecessary extra draws
    extravisual.AnimState:Hide("sign_overlay")
	extravisual.AnimState:Hide("SWAP_COST")

    return extravisual
end

local function UpdateCostVisualExtra(inst, anim, ...)
	UpdateExtraVisual(inst.plrebalance_extravisual, anim)
	inst:UpdateCostVisual_Old(anim, ...)
end

local function shopbuyer_postinit(inst)
	
	local _OnSave = inst.OnSave
	local _OnLoad = inst.OnLoad
	local _InitShop = inst.InitShop

	local function OnSave(inst, data)
		_OnSave(inst, data)
		--if inst.plrebalance_otheritems then data.plrebalance_otheritems = inst.plrebalance_otheritems end
		if inst.plrebalance_mayormandateitem then
			data.plrebalance_mayormandateitem = inst.plrebalance_mayormandateitem
			data.plrebalance_mayormandatecharges = inst.plrebalance_mayormandatecharges
		end
	end
	local function OnLoad(inst, data)
		_OnLoad(inst, data)
		if data then
			--if data.plrebalance_otheritems then inst.plrebalance_otheritems = data.plrebalance_otheritems end
			if data.plrebalance_mayormandateitem then inst.plrebalance_mayormandateitem = data.plrebalance_mayormandateitem	end
			if data.plrebalance_mayormandatecharges then 
				inst.plrebalance_mayormandatecharges = data.plrebalance_mayormandatecharges
				inst:PLRebalance_UpdateExtraVisualCharges()
			end
		end
		if inst.saleitem then inst:AddTag("plrebalance_saleitem") end
	end
	
	local function InitShop(inst, shop_type)
		_InitShop(inst, shop_type)
		if inst.saleitem then inst:AddTag("plrebalance_saleitem") end
	end
	
	inst.OnSave = OnSave
	inst.OnLoad = OnLoad
    inst.InitShop = InitShop
	
	inst:AddTag("plrebalance_shoppedlockable")

    if not TheWorld.ismastersim then
        return
    end
	
	inst:AddComponent("plrebalance_shoppedlockable")
	
	inst.plrebalance_extravisual = CreateExtraVisual(inst)
	inst.costvisual.plrebalance_extravisual = inst.plrebalance_extravisual
	inst.costvisual.UpdateCostVisual_Old = inst.costvisual.UpdateVisual
	inst.costvisual.UpdateVisual = UpdateCostVisualExtra
	inst.PLRebalance_UpdateExtraVisualCharges = UpdateExtraVisualCharges
	
	inst:DoStaticTaskInTime(0, function()
        inst.plrebalance_extravisual:UpdateVisual(inst.animation) -- 毫无疑问，这是为了解决层级bug的屎山，因为有时SetFinalOffset会失效（特别是在离0点特别远的位置）
    end)
end

AddPrefabPostInit("shop_buyer", shopbuyer_postinit)

MATERIALS.OINC = "OINC"
TUNING.OINC_REPAIR_VALUE = 1
TUNING.PLREBALANCE_MAXSHOPLOCK = 30

function PLREBALANCE_RefundMoney(inst, excess, fuelvalue) --Global Function
	local refundOincs = math.floor(excess / fuelvalue)
	local refundTenOincs = math.floor(refundOincs / 10)
	refundOincs = refundOincs - refundTenOincs * 10
    local inventory = inst.components.inventory
	while refundOincs > 0 do
		refundOincs = refundOincs - 1
		local coin = SpawnPrefab("oinc")
        inventory:GiveItem(coin)
	end
	while refundTenOincs > 0 do
		refundTenOincs = refundTenOincs - 1
		local coin = SpawnPrefab("oinc10")
        inventory:GiveItem(coin)
	end
end

local function oinc_postinit(inst)
	if not TheWorld.ismastersim then
		return
	end
	
    inst:AddComponent("plrebalance_shoppedlockingrefresher")
    inst:AddComponent("repairer")
    inst.components.repairer.repairmaterial = MATERIALS.OINC
    inst.components.repairer.finiteusesrepairvalue = TUNING.OINC_REPAIR_VALUE * inst.oincvalue
end

AddPrefabPostInit("oinc", oinc_postinit)
AddPrefabPostInit("oinc10", oinc_postinit)
AddPrefabPostInit("oinc100", oinc_postinit)

local SHOP_STAND_TAGS = {"shop_pedestal"}

function PigShopExpander.UpdateStock(inst)
	local x, y, z = inst.Transform:GetWorldPosition()
	local shops = TheSim:FindEntities(x, y, z, 30, SHOP_STAND_TAGS)
	for _, ent in ipairs(shops) do
		ent.plrebalance_otheritems = inst.plrebalance_otheritems
	end
end

function PigShopExpander.ExtraGoods_PostInit(inst, extradata)
	local _OnSave = inst.OnSave
	local _OnLoad = inst.OnLoad
	
	local function OnSave(inst, data)
		_OnSave(inst, data)
		if inst.plrebalance_itemsaccepted then data.plrebalance_itemsaccepted = inst.plrebalance_itemsaccepted end
	end
	
	local function OnLoad(inst, data)
		_OnLoad(inst, data)
		if data and data.plrebalance_itemsaccepted then
			inst.plrebalance_itemsaccepted = data.plrebalance_itemsaccepted
			inst.plrebalance_otheritems = {}
			for k, _ in pairs(inst.plrebalance_itemsaccepted) do
				inst.plrebalance_otheritems[#inst.plrebalance_otheritems + 1] = extradata[k]
			end
			inst:DoTaskInTime(0, PigShopExpander.UpdateStock, inst)
		end
	end
	
	inst.OnSave = OnSave
	inst.OnLoad = OnLoad
end

function PigShopExpander.AcceptExtraItem(inst, item, line, extradata)
	if inst.components.sleeper:IsAsleep() then
			return false
	end
	
	if extradata[item.prefab] then
		if inst.plrebalance_itemsaccepted and inst.plrebalance_itemsaccepted[item.prefab] then
			inst:SayLine(line)
			return false
		else
			return true
		end
	end
end

function PigShopExpander.OnAcceptExtraItem(inst, giver, item, line, extradata)
	if extradata[item.prefab] then
		inst:SayLine(line)
		inst.plrebalance_itemsaccepted = inst.plrebalance_itemsaccepted or {}
		inst.plrebalance_itemsaccepted[item.prefab] = true
		inst.plrebalance_otheritems = inst.plrebalance_otheritems or {}
		inst.plrebalance_otheritems[#inst.plrebalance_otheritems + 1] = extradata[item.prefab]
		PigShopExpander.UpdateStock(inst)
		return true
	end
	return false
end