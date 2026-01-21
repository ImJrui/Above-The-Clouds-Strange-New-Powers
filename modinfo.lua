local lang = locale
local function translate(String)  -- use this fn can be automatically translated according to the language in the table
	String.zhr = String.zh
	String.zht = String.zht or String.zh
	return String[lang] or String.en
end

--The name of the mod displayed in the 'mods' screen.
name = "云霄国度补丁(Original: Above The Clouds - Strange New Powers)"

--A description of the mod.
description = translate({
	en = "v3.3.1 \n original author：齐天大圣 \n Integrate DST-compatible content into Above the Cloud mod", 
	zh = "v3.3.1 \n 原作者：齐天大圣 \n 为云霄国度模组增加饥荒联机版适配内容"
})

--Who wrote this awesome mod?
author = "TUTU"

--A version number so you can ask people if they are running an old version of your mod.
version = "3.3.1"

--This lets other players know if your mod is out of date. This typically needs to be updated every time there's a new game update.
api_version = 10

dst_compatible = true

--This lets clients know if they need to get the mod from the Steam Workshop to join the game
all_clients_require_mod = true

--This determines whether it causes a server to be marked as modded (and shows in the mod list)
client_only_mod = false

--This lets people search for servers with this mod by these tags
server_filter_tags = {"Hamlet Rebalance", "Hamlet Strange New Powers", "云霄国度补丁", "above the clouds" }


priority = -20  --模组优先级0-10 mod 加载的顺序   0最后载入  覆盖大值

configuration_options={ --模组变量配置
	{
		name = "PUGALISK_HP_MULTIPLIER",--modmain脚本里调用变量
		hover = translate({en = "Increase boss HP to get more loot", zh = "提高boss血量将获得更多战利品"}),
		label = translate({en = "Pugalisk HP", zh = "大蛇血量"}),--游戏里显示的名字
		options ={	
					{description = "1X", data = 1},
					{description = "1.5X", data = 1.5},
					{description = "2X", data = 2},
					{description = "3X", data = 3},
					{description = "4X", data = 4},
				},
		default = 1
	},

    {
		name = "ANCIENT_HERALD_HP_MULTIPLIER",--modmain脚本里调用变量
		hover = translate({en = "Increase boss HP to get more loot", zh = "提高boss血量将获得更多战利品"}),
		label = translate({en = "Ancient Herald HP", zh = "远古先驱血量"}),--游戏里显示的名字
		options ={	
					{description = "1X", data = 1},
					{description = "1.5X", data = 1.5},
					{description = "2X", data = 2},
					{description = "3X", data = 3},
					{description = "4X", data = 4},
				},
		default = 1
	},

	{
		name = "ANTQUEEN_HP_MULTIPLIER",--modmain脚本里调用变量
		hover = translate({en = "Increase boss HP to get more loot", zh = "提高boss血量将获得更多战利品"}),
		label = translate({en = "Antqueen HP", zh = "蚁后血量"}),--游戏里显示的名字
		options ={	
					{description = "1X", data = 1},
					{description = "1.5X", data = 1.5},
					{description = "2X", data = 2},
					{description = "3X", data = 3},
					{description = "4X", data = 4},
				},
		default = 1
	},

    {
		name = "ANCIENT_HULK_HP_MULTIPLIER",--modmain脚本里调用变量
		hover = translate({en = "Increase boss HP to get more loot", zh = "提高boss血量将获得更多战利品"}),
		label = translate({en = "Ancient Hulk HP", zh = "废铁机器人血量"}),--游戏里显示的名字
		options ={	
					{description = "1X", data = 1},
					{description = "1.5X", data = 1.5},
					{description = "2X", data = 2},
					{description = "3X", data = 3},
					{description = "4X", data = 4},
				},
		default = 1
	},

	{
		name = "ENABLE_SKILLTREE",--modmain脚本里调用变量
		hover = translate({en = "Enable or Disable skill tree", zh = "启用或者禁用技能树"}),
		label = translate({en = "Enable Skilltree", zh = "启用技能树"}),--游戏里显示的名字
		options ={	
					{description = "YES", data = true},
					{description = "NO", data = false},
				},
		default = true
	},

	{
		name = "ENABLE_TERRARIUM",--modmain脚本里调用变量
		hover = translate({en = "Terrarium will become obtainable among a random deep rainforest", zh = "盒中泰拉将在随机的深雨林中生成"}),
		label = translate({en = "Spawn Terrarium", zh = "生成盒中泰拉"}),--游戏里显示的名字
		options ={	
					{description = "YES", data = true},
					{description = "NO", data = false},
				},
		default = false
	},

	{
		name = "ENABLE_TOUCHSTONE",--modmain脚本里调用变量
		hover = translate({en = "Touch stones will spawn on Island 1, Island 2, Island 3, and Island 5", zh = "试金石将会生成在1岛、2岛、3岛、5岛"}),
		label = translate({en = "Spawn TouchStone", zh = "生成试金石"}),--游戏里显示的名字
		options ={	
					{description = "YES", data = true},
					{description = "NO", data = false},
				},
		default = true
	},

	{
		name = "ENABLE_CRITTERLAB",--modmain脚本里调用变量
		hover = translate({en = "Rock Den will spawn on BFB Island", zh = "岩石巢穴将出现在大鹏岛"}),
		label = translate({en = "Spawn Rock Den", zh = "生成岩石巢穴"}),--游戏里显示的名字
		options ={	
					{description = "YES", data = true},
					{description = "NO", data = false},
				},
		default = true
	},

	{
		name = "APORKALYPSE_PERIOD_LENGTH",--modmain脚本里调用变量
		hover = translate({en = "Aporkalypse Period", zh = "毁灭季周期"}),
		label = translate({en = "Aporkalypse Period", zh = "毁灭季周期"}),--游戏里显示的名字
		options ={	
					{description = "30 days", data = 30},
					{description = "60 days", data = 60},
					{description = "90 days", data = 90},
					{description = "120 days", data = 120},
					{description = "999 days", data = 999},
				},
		default = 60
	},

	{
		name = "ENABLE_SKYWORTHY",--modmain脚本里调用变量
		hover = translate({en = "​You can travel to the Forest World by running a three-shard server", zh = "搭建3层世界服务器后可以穿越到森林世界"}),
		label = translate({en = "Three-Shard Mode Beta", zh = "双穿模式Beta"}),--游戏里显示的名字
		options ={	
					{description = "YES", data = true},
					{description = "NO", data = false},
				},
		default = false
	},
}

mod_dependencies = {
    {	
       	--only have a workshop dependency
        workshop = "workshop-3322803908",
    },
}

icon_atlas = "preview.xml"
icon = "preview.tex"