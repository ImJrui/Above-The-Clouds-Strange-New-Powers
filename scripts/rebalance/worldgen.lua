--level世界 -- task分支 -- room地块/彩蛋等

local Terrarium = GetModConfigData("Terrarium")
local TouchStone = GetModConfigData("TouchStone")
local Critterlab = GetModConfigData("Critterlab")
local Teleportato_Base = true -- 默认添加


-- GLOBAL.setfenv(1, GLOBAL)
local AddLevelPreInitAny = AddLevelPreInitAny
local AddTaskPreInit = AddTaskPreInit
local AddRoom = AddRoom
local Layouts = require("map/layouts").Layouts
local StaticLayout = require("map/static_layout")

-- 1. 将Layouts加载移到全局（避免每次加载地图都重复加载）
Layouts["plrebalance_Terrarium"] = StaticLayout.Get("map/static_layouts/plrebalance_terrarium_layout")
Layouts["plrebalance_Critterlab"] = StaticLayout.Get("map/static_layouts/plrebalance_critterlab_layout")
Layouts["plrebalance_ResurrectionStone"] = StaticLayout.Get("map/static_layouts/plrebalance_resurrectionstone_layout")
Layouts["plrebalance_Teleportato_Base"] = StaticLayout.Get("map/static_layouts/plrebalance_teleportato_hamlet_base_layout")

-- 3. 创建配置映射表（清晰定义任务点与布局关系）
local TASK_CONFIG = {
    -- Terrarium = {
	-- 	enable = Terrarium,
    --     count = 1,
    --     tasks = { "Deep_lost_ruins4" },
    --     layout = "plrebalance_Terrarium"
    -- },
    TouchStone = {
		enable = TouchStone,
        count = 4,
        tasks = { 
            "rainforest_ruins",
            "wild_rainforest",
            "lost_rainforest",
            "Path_to_the_others"
        },
        layout = "plrebalance_ResurrectionStone"
    },
    Critterlab = {
		enable = Critterlab,
        count = 1,
        tasks = { "pincale" },
        layout = "plrebalance_Critterlab"
    },
    Teleportato_Base = {
        enable = Teleportato_Base,
        count = 1,
        tasks = {
            "Deep_rainforest",
            "Deep_rainforest_2",
            "Deep_rainforest_3",
            "Deep_lost_ruins4",
            "Deep_wild_ruins4",
            "wild_ancient_ruins",
        },
        layout = Terrarium and "plrebalance_Terrarium" or "plrebalance_Teleportato_Base"
    }
}

-- 重构关卡初始化逻辑
AddLevelPreInitAny(function(level)
    if level.location ~= "porkland" then return end

    -- 构建任务点配置聚合表
    local taskConfigurations = {}
    
    -- 处理所有配置项
    for configName, configData in pairs(TASK_CONFIG) do
        if configData.enable and #configData.tasks > 0 then
            -- 准备从任务列表中随机选择
            local randomTasks = {}
            
            -- 需要选择的数量：不超过实际任务数和配置要求的最小值
            local selectCount = math.min(configData.count, #configData.tasks)
            
            -- 制作临时任务列表（避免修改原始数据）
            local taskList = {}
            for _, task in ipairs(configData.tasks) do
                table.insert(taskList, task)
            end
            
            -- 随机选择指定数量的任务
            for i = 1, selectCount do
                if #taskList > 0 then
                    -- 生成随机索引
                    local randIdx = math.random(#taskList)
                    
                    -- 将选中的任务添加到结果集
                    table.insert(randomTasks, taskList[randIdx])
                    
                    -- 从临时列表中移除已选项
                    table.remove(taskList, randIdx)
                end
            end
            
            -- 将选中的任务和布局关联起来
            for _, taskName in ipairs(randomTasks) do
                taskConfigurations[taskName] = taskConfigurations[taskName] or {}
                table.insert(taskConfigurations[taskName], configData.layout)
            end
        end
    end

    -- 应用配置到任务点
    for taskName, layouts in pairs(taskConfigurations) do
        AddTaskPreInit(taskName, function(task)
            task.set_pieces = task.set_pieces or {}
            for _, layout in ipairs(layouts) do
                table.insert(task.set_pieces, {name = layout})
            end
        end)
    end
end)