local AddPrefabPostInit = AddPrefabPostInit

GLOBAL.setfenv(1, GLOBAL)

--Wishing Well

local item_values = {
    oinc = 1, -- 4%
    oinc10 = 10, -- 40%
    oinc100 = 100, -- 100%
    goldnugget = 20, -- 80%
    dubloon = 5, -- 20%
}

local item_prefabs = {
	["warly"] = {
		{"garlic_seeds",				5 ,		0.50},	--{item, count, chance}
		{"onion_seeds",					5 ,		0.50},
		{"tomato_seeds",				5 ,		0.50},
		{"potato_seeds",				5 ,		0.50},
		{"pepper_seeds",				5 ,		0.50},
		{"saltrock",					5 ,		0.50},
	},
	["webber"] = {
		{"mutator_dropper",				2 ,		0.50},
		{"mutator_hider",				2 ,		0.50},
		{"mutator_spitter",				2 ,		0.50},
		{"mutator_moon",				2 ,		0.50},
		{"mutator_water",				2 ,		0.50},
		{"disguisehat",					1 ,		0.50},
		{"spidereggsack",				1 ,		0.50},
	},
	["wortox"] = {
		{"disguisehat",					1 ,		0.30},
		{"messagebottleempty",			1 ,		0.40},
		-- {"snake_bone",					2 ,		0.50},
	},
	["wanda"] = {
		{"restore_item_states",			1 ,		0.40},
		-- {"snake_bone",					4 ,		0.50},
	},
	["willow"] = {
		{"restore_item_states",			1 ,		0.25},
	},
	["waxwell"] = {
		{"restore_item_states",			1 ,		0.20},
	},
	["wormwood"] = {
		{"soil_amender",				1 ,		0.40},
		{"seeds",						10,		0.50},
	},
	["walter"] = {
		{"slingshotammo_gold",			20,		0.75},
		{"slingshotammo_marble",		20,		0.50},
		{"slingshotammo_thulecite",		20,		0.33},
		{"woby_treat",					2 ,		0.50},
	},
	["wurt"] = {
		{"pondfish",					2 ,		0.40},
		{"tentaclespots",				2 ,		0.40},
	},
	["wathgrithr"] = {
		{"restore_item_states",			1 ,		0.40},
		{"character_event",				1 ,		0.40},
	},
	["woodie"] = {
		{"clawpalmtree_sapling_item",	5 ,		0.50},
		{"burr",						5 ,		0.50},
		{"pinecone",					5 ,		0.50},
		{"acorn",						5 ,		0.50},
	},
	["wendy"] = {
		{"character_event",				1 ,		0.40},
	},
	["wolfgang"] = {
		{"character_event",				1 ,		0.40},
	},
	["wx78"] = {
		{"character_event",				1 ,		0.60},
	},
	["wickerbottom"] = {
		{"character_event",				1 ,		0.50},
	},
	["winona"] = {
		{"restore_item_states",			1 ,		0.40},
	}
}

local CharacterItems = {
	["wanda"] = {
		["pocketwatch_heal"] = STRINGS.CHARACTER_LINE.WISHINGWELL.WANDA,
		["pocketwatch_revive"] = STRINGS.CHARACTER_LINE.WISHINGWELL.WANDA,
		["pocketwatch_warp"] = STRINGS.CHARACTER_LINE.WISHINGWELL.WANDA,
		["pocketwatch_recall"] = STRINGS.CHARACTER_LINE.WISHINGWELL.WANDA,
	},
	["waxwell"] = {
		["waxwelljournal"] = STRINGS.CHARACTER_LINE.WISHINGWELL.MAXWELL,
	},
	["willow"] = {
		["lighter"] = STRINGS.CHARACTER_LINE.WISHINGWELL.WILLOW_LIGHTER,
		["bernie_inactive"] = STRINGS.CHARACTER_LINE.WISHINGWELL.WILLOW_BERNIE,
	},
	["wathgrithr"] = {
		["spear_wathgrithr"] = STRINGS.CHARACTER_LINE.WISHINGWELL.WATHGRITHR_SPEAR,
		["spear_wathgrithr_lightning"] = STRINGS.CHARACTER_LINE.WISHINGWELL.WATHGRITHR_SPEAR,
		["wathgrithrhat"] = STRINGS.CHARACTER_LINE.WISHINGWELL.WATHGRITHR_HELMET,
		["wathgrithr_improvedhat"] = STRINGS.CHARACTER_LINE.WISHINGWELL.WATHGRITHR_HELMET,
		["wathgrithr_shield"] = STRINGS.CHARACTER_LINE.WISHINGWELL.WATHGRITHR_SHIELD,
	},
	["winona"] = {
        ["winona_telebrella"] = STRINGS.CHARACTER_LINE.WISHINGWELL.WINONA_TELEBRELLA,
        ["winona_storage_robot"] = STRINGS.CHARACTER_LINE.WISHINGWELL.WINONA_STORAGE_ROBOT,
        ["winona_remote"] = STRINGS.CHARACTER_LINE.WISHINGWELL.WINONA_REMOTE,
    }
}

local function RestoreItemStates(giver, must_item, has_tag)
	if not (CharacterItems[giver.prefab] and giver.components.inventory and giver:IsValid()) then
        return
    end

	local line

	local function RestoreFn(item)
		if not (item and CharacterItems[giver.prefab][item.prefab]) then
            return false
        end

		if must_item and item.prefab ~= must_item then
            return false
        end

		if item.components.rechargeable and not item.components.rechargeable:IsCharged() then
			item.components.rechargeable:SetCharge(item.components.rechargeable.total)
			line = line or CharacterItems[giver.prefab][item.prefab]
		end

		if item.components.fueled and not item.components.fueled:IsFull() then
			item.components.fueled:SetPercent(1)
			line = line or CharacterItems[giver.prefab][item.prefab]
		end

		if item.components.armor and item.components.armor:IsDamaged() then
			item.components.armor:SetPercent(1)
			line = line or CharacterItems[giver.prefab][item.prefab]
		end

		if item.components.finiteuses and item.components.finiteuses:GetPercent() < 1 then
			item.components.finiteuses:SetPercent(1)
			line = line or CharacterItems[giver.prefab][item.prefab]
		end
	end

	local handitem = giver.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	if not line and handitem then
		RestoreFn(handitem)
	end

	local headitem = giver.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
	if not line and headitem then
		RestoreFn(headitem)
	end

	local inv = giver.components.inventory.itemslots
	for slot,item in pairs(inv) do
		if line then break end
		RestoreFn(item)
	end

    for k, equipped in pairs(giver.components.inventory.equipslots) do
        if equipped.components.container ~= nil then
			for slot,item in pairs(equipped.components.container.slots) do
				if line then break end
				RestoreFn(item)
			end
		end
    end

	if line then
		giver.components.talker:Say(line)
	end
end

local function Character_events(giver)
    if giver.prefab == "wendy" and giver.components.ghostlybond then
        if math.random() < 0.33 then
            local level = giver.components.ghostlybond.bondlevel
            local maxlevel = giver.components.ghostlybond.maxbondlevel
            if level < maxlevel then
                level = math.min(level + 1, maxlevel)
                giver.components.ghostlybond:SetBondLevel(level)
                giver.components.talker:Say(STRINGS.CHARACTER_LINE.WISHINGWELL.WENDY_BONDLEVEL)
            end
        elseif giver.components.ghostlybond.ghost and not giver.components.ghostlybond.ghost:HasTag("INLIMBO") then
            local health = giver.components.ghostlybond.ghost.components.health
            if health:IsHurt() then
                giver.components.ghostlybond.ghost.components.health:DoDelta(health.maxhealth, true, "wishingwell")
                giver.components.talker:Say(STRINGS.CHARACTER_LINE.WISHINGWELL.WENDY_GHOST_HEAL)
            end
        end
    end
    if giver.prefab == "wathgrithr" and giver.components.singinginspiration then
        if giver.components.singinginspiration:GetPercent() < 1 then
            giver.components.singinginspiration:SetPercent(1)
            giver.components.talker:Say(STRINGS.CHARACTER_LINE.WISHINGWELL.WATHGRITHR_INSPIRATION)
        end
    end
    if giver.prefab == "wolfgang" and giver.components.mightiness then
        if giver.components.mightiness:GetPercent() < 1 then
            giver.components.mightiness:SetPercent(1)
            giver.components.talker:Say(STRINGS.CHARACTER_LINE.WISHINGWELL.WOLFGANG_MIGHTINESS)
        end
    end
    if giver.prefab == "wx78" then
        if math.random() < 0.5 then
            if giver.components.upgrademoduleowner and not giver.components.upgrademoduleowner:ChargeIsMaxed() then
                giver.components.upgrademoduleowner:AddCharge(1)
                giver.components.talker:Say(STRINGS.CHARACTER_LINE.WISHINGWELL.WX78_CHARGE)
            end
        else
            if giver.components.moisture:IsWet() then
                giver.components.moisture:ForceDry(true, nil)
                giver.components.talker:Say(STRINGS.CHARACTER_LINE.WISHINGWELL.WX78_DRY)
            end
        end
    end
	if giver.prefab == "wickerbottom" then
		local knockouttestfn = giver.components.grogginess.knockouttestfn
		if math.random() < 0.20 then
			giver.components.talker:Say(STRINGS.CHARACTER_LINE.WISHINGWELL.WICKERBOTTOM_KNOCKOUT)
			giver.components.sanity:DoDelta(99, true)
			giver.components.grogginess:SetKnockOutTest(function (inst) return true end)
			giver.components.grogginess:AddGrogginess(giver.components.grogginess:GetResistance())
			giver.components.grogginess:SetKnockOutTest(knockouttestfn)
		else
			giver.components.talker:Say(STRINGS.CHARACTER_LINE.WISHINGWELL.WICKERBOTTOM_GROGGINESS)
			giver.components.sanity:DoDelta(33, true)
			giver.components.grogginess:AddGrogginess(giver.components.grogginess:GetResistance())
		end
	end
end

local function OnGetItemFromPlayer_Wishing(inst, giver, item, ...)
	inst.components.trader.plrebalance_oldonaccept(inst, giver, item, ...)

    local value = item_values[item.prefab] or 0

	if giver.prefab == "wanda" and math.random() < (value / 25) then
		RestoreItemStates(giver, "pocketwatch_heal")
	end

	local itempool = item_prefabs[giver.prefab]
	if not itempool then
		-- print("tutu:Wishing Well: Character " .. giver.prefab .. " has no wish pool")
		return
	end

    inst:DoTaskInTime(1, function()
		local reward = itempool[math.random(#itempool)]
		local success = false

		if reward[1] == "restore_item_states" then
			for i = 1, reward[2] do
				if math.random() < ((value / 25) * reward[3]) then
					RestoreItemStates(giver, nil)
					success = true
				end
			end
		elseif reward[1] == "character_event" then
			for i = 1, reward[2] do
				if math.random() < ((value / 25) * reward[3]) then
					Character_events(giver)
					success = true
				end
			end
		else
			for i = 1, reward[2] do
				if math.random() < ((value / 25) * reward[3]) then
					-- print("tutu:Wishing Well: Rewarding " .. reward[1] .. " to " .. giver.prefab)
					local spawn_point = inst:GetPosition() + Vector3(0, 2, 0)
					local x, y, z = spawn_point:Get()
					local angle = (math.random() * 360) * DEGREES
					if giver ~= nil and giver:IsValid() then
						angle = 180 - giver:GetAngleToPoint(x, 0, z)
					end
					local speed = math.random() * 4 + 2
					local payout = SpawnPrefab(reward[1])
					payout.Transform:SetPosition(x, y, z)
					payout.Physics:SetVel(speed * math.cos(angle), math.random() * 2 + 18, speed * math.sin(angle))
					success = true
				end
			end
		end
		if success then
			inst.AnimState:PlayAnimation("splash")
			inst.AnimState:PushAnimation("idle_full", true)
		end
    end)
end

local function deco_ruins_fountain_postinit(inst)
	if not TheWorld.ismastersim then
		return
	end

	inst:AddTag("watersource")
    inst:AddComponent("watersource")
    inst.components.watersource.available = true

	if not inst.components.trader then return end
	inst.components.trader.plrebalance_oldonaccept = inst.components.trader.onaccept
	inst.components.trader.onaccept = OnGetItemFromPlayer_Wishing
end

AddPrefabPostInit("deco_ruins_fountain", deco_ruins_fountain_postinit)