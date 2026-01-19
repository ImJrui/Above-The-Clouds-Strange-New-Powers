预设物
AddPrefabPostInitAny(fn(inst))	
AddPrefabPostInit(prefab, fn(inst))		
AddMinimapAtlas(atlaspath)  --对应 inst.MiniMapEntity:SetIcon( "xxx.tex" )
玩家
AddPlayerPostInit(fn(player)) 
---gender:"FEMALE/MALE/ROBOT/NEUTRAL/PLURAL" modes:选人动画 loadoutselect.lua skinutils.lua
AddModCharacter(name, gender="NEUTRAL", modes=nil)	
组件 
AddComponentPostInit(component, fn(self)) --Class中的self，类比其他语言的this
AddReplicableComponent(component)	--例如xxx_replica.lua，就写"xxx"
动画、动作	
--componentaction客户端判断能否执行，执行运行stategraph，执行完回调acion
AddAction(id:string|Action, str, fn(act))	--actions.lua
---stategraph对应stategraphs文件夹下的文件(无SG)，联机版wilson和wilson_cient
---handle: ActionHandler(Action, "anim_name")	Action是自己注册的或ACTIONS.XXX
AddStategraphActionHandler(stategraph, handler)	
--actiontype: "SCENE/USEITEM/POINT/EQUIPPED/INVENTORY"  fn参数由actiontype决定
AddComponentAction(actiontype, component, fn(...)) --componentactions.lua

--参考 stategraph.lua	SGwilson.lua	SGwilson_client.lua
AddStategraphState(stategraph, state)
AddStategraphEvent(stategraph, event)
AddStategraphPostInit(stategraph, postfn) 
类
--class, globalclass，全路径文件名
AddClassPostConstruct(class, fn(self)) --普通class修改
--例 AddGlobalClassPostConstruct("mods","ModManager",function(self) end)
AddGlobalClassPostConstruct(globalclass, classname, fn(self)) --全局的class修改
大脑（AI）
AddBrainPostInit(brain, fn(self))  
游戏
--可以修改main.lua中的全局变量，不过最好先判空
AddGamePostInit(fn())	--先
AddSimPostInit(fn())	--后，常用于生成prefab	
--AddGameMode(...)	移除，在modinfo里改
物品栏制作
--这里的recipename、name等指Recipe的name，一般也是预设物名
--写法参照recipes.lua  repice.lua 即可
AddRecipe2(name, ingredients, tech, config, filters)	--添加物品配方
AddCharacterRecipe(name, ingredients, tech, config, extra_filters)	--filter是玩家
AddDeconstructRecipe(name, return_ingredients)	--分解掉落物
AddRecipeFilter(filter_def, index)	--自定义物品栏
AddRecipeToFilter(recipe_name, filter_name)	--添加物品配方自定义物品栏
RemoveRecipeFromFilter(recipe_name, filter_name)	
AddRecipePostInit(recipename, fn(self)) 
AddRecipePostInitAny(fn(self))
RegisterInventoryItemAtlas(atlas, prefabname) --tex名要和prefab一样，一般不用
烹饪
--食物的Prefab在prefabs/preparedfoods.lua和prefabs/preparedfoods_warly.lua
---cooker："cookpot/portablecookpot"
---recipe：参考scripts/preparedfoods.lua和scripts/preparedfoods_warly.lua
AddCookerRecipe(cooker, recipe)	--烹饪配方
AddIngredientValues(names, tags, cancook, candry)	--肉度/菜度等  参考cooking.lua
声音
RemapSoundEvent(name, new_name)
RemoveRemapSoundEvent(name)
RPC  --RPC，服务器和客户端交流的一种方式，另一种是用网络变量(netvar.lua)
---namespace用modname最好
---name：独一无二的函数名
---id_table：GetXXXRPC(...)
AddModRPCHandler(namespace, name, fn(...))
GetModRPCHandler(namespace, name)	--> Add时的fn
GetModRPC( namespace, name )	--> id_table
SendModRPCToServer( id_table, ... )	

AddClientModRPCHandler(namespace, name, fn(...))
GetClientModRPCHandler(namespace, name)	--> Add时的fn
GetClientModRPC( namespace, name )	--> id_table
SendModRPCToClient( id_table, ... )

AddShardModRPCHandler(namespace, name, fn(...))
GetShardModRPCHandler(namespace, name)	--> Add时的fn
GetShardModRPC( namespace, name )	--> id_table
SendModRPCToShard( id_table, ... )
命令、提示等
AddUserCommand(command_name, data)
AddVoteCommand(command_name, init_options_fn, process_result_fn, vote_timeout )
AddLoadingTip(stringtable, id, tipstring, controltipdata)
RemoveLoadingTip(stringtable, id)
SetLoadingTipCategoryWeights(weighttable, weightdata)
SetLoadingTipCategoryIcon(category, categoryatlas, categoryicon)
房间	--生成世界时用
AddRoomPreInit(name,function(room) end)
AddTaskPreInit()  
...
Shaders		--着色器
AddModShadersInit( fn )
AddModShadersSortAndEnable( fn )
...
————————————————

                            版权声明：本文为博主原创文章，遵循 CC 4.0 BY 版权协议，转载请附上原文出处链接和本声明。
                        
原文链接：https://blog.csdn.net/weixin_46068322/article/details/126352181