local AddPrefabPostInit = AddPrefabPostInit
local AddSimPostInit = AddSimPostInit
GLOBAL.setfenv(1, GLOBAL)
------------------------------------------------------------

local cofig = {
    ["ancient_hulk"] = PL_CONFIG["ANCIENT_HULK_HP_MULTIPLIER"],
    ["pugalisk"] = PL_CONFIG["PUGALISK_HP_MULTIPLIER"],
    ["pugalisk_segment"] = PL_CONFIG["PUGALISK_HP_MULTIPLIER"],
    ["ancient_herald_base"] = PL_CONFIG["ANCIENT_HERALD_HP_MULTIPLIER"],
    ["antqueen"] = PL_CONFIG["ANTQUEEN_HP_MULTIPLIER"],
}

TUNING.ANTQUEEN_HEALTH = TUNING.ANTQUEEN_HEALTH * cofig["antqueen"]
TUNING.ANCIENT_HULK_HEALTH = TUNING.ANCIENT_HULK_HEALTH * cofig["ancient_hulk"]
TUNING.PUGALISK_HEALTH = TUNING.PUGALISK_HEALTH * cofig["pugalisk"]
TUNING.ANCIENT_HERALD_HEALTH = TUNING.ANCIENT_HERALD_HEALTH * cofig["ancient_herald_base"]

local extra_loot = {
    ["ancient_hulk"] = {"ruinshat", "armorruins"},
    ["pugalisk"] = {"orangeamulet", "yellowamulet", "greenamulet"},
    ["ancient_herald_base"] = {"dreadstonehat", "armordreadstone"},
    ["antqueen"] = {"greenstaff", "orangestaff", "yellowstaff"},
}

local function CalculateExtraLoots(boss, multiplier)
    local extra_loots = {}
    local chance = (multiplier == 3 and 0.33) or (multiplier == 4 and 1.00) or nil
    if chance and extra_loot[boss] then
        for _, loot in ipairs(extra_loot[boss]) do
            table.insert(extra_loots, {loot, chance})
        end
    end
    return extra_loots
end

-- 私有函数：合并、计算倍率、拆分掉落表，并添加额外奖励
local function CalculateLootTable(inst, base_loots, multiplier, extra_loots)
    -- 第一步：合并相同物品的概率
    local merged_items = {}
    
    for _, data in pairs(base_loots) do
        local item_name = data[1]
        local probability = data[2]
        
        if not merged_items[item_name] then
            merged_items[item_name] = 0
        end
        merged_items[item_name] = merged_items[item_name] + probability
    end
    
    -- 第二步：乘以倍率
    for item_name, total_prob in pairs(merged_items) do
        if not (item_name:find("_blueprint") or item_name == "pigcrownhat") then
            merged_items[item_name] = total_prob * (1 + (multiplier - 1) * 0.5)
        end
    end
    
    -- 第三步：拆分成原来的格式（每1单位一行，不满1单位也一行）
    local result_table = {}
    
    for item_name, total_prob in pairs(merged_items) do
        local integer_part = math.floor(total_prob)  -- 整数部分
        local decimal_part = total_prob - integer_part  -- 小数部分
        
        -- 添加整数部分（每个1单位一行）
        for i = 1, integer_part do
            table.insert(result_table, {item_name, 1.00})
        end
        
        -- 添加小数部分（如果大于0）
        if decimal_part > 0 then
            -- 四舍五入到小数点后四位
            local rounded_decimal = math.floor(decimal_part * 10000 + 0.5) / 10000
            table.insert(result_table, {item_name, rounded_decimal})
        end
    end
    
    -- 第四步：添加额外奖励（如果提供了extra_loot参数）
    if extra_loots then
        for _, extra_item in ipairs(extra_loots) do
            table.insert(result_table, extra_item)  -- 直接插入原表
        end
    end
    
    return result_table
end

AddSimPostInit(function()
    for boss, multiplier in pairs(cofig) do
        local base_loots = LootTables[boss] or {}
        if boss == "antqueen" then
            table.insert(base_loots ,{"royal_jelly", 1.00})
        end
        local extra_loots = CalculateExtraLoots(boss, multiplier)
        local loots = CalculateLootTable(boss, base_loots, multiplier, extra_loots)
        SetSharedLootTable(boss, loots)
    end
end)

AddPrefabPostInit("antqueen", function(inst)
    inst:AddTag("largecreature")
    if not TheWorld.ismastersim then
        return
    end
end)