GLOBAL.setfenv(1, GLOBAL)

return {
	ACTIONS = {
		PORKLANDREBALANCE_REPICK = en_zh({EN = "Reincarnate", CN = "重选"}),
		PORKLANDREBALANCE_REGENERATERUINS = en_zh({EN = "Regenerate", CN = "重置"}),
		PORKLANDREBALANCE_LOCKSHOP = en_zh({EN = "Commission {item}", CN = "佣金 {item}"}),
		PORKLANDREBALANCE_LOCKSHOPREFRESH = en_zh({EN = "Refresh Commission", CN = "刷新佣金"}),
		PORKLANDREBALANCE_WALTERAIMEDSHOT = en_zh({EN = "Aim At", CN = "瞄准"}),
	},
	NAMES = {
		WX78MODULE_PORKLANDREBALANCE_FAN = en_zh({EN = "Convection Circuit", CN = "对流电路"}),
		WX78MODULE_PORKLANDREBALANCE_FILTER = en_zh({EN = "Purifying Circuit", CN = "净化电路"}),
		SEEDOFRUIN = en_zh({EN = "Seed of Ruin", CN = "遗迹种子"}),
		SKYWORTHY_SHOP = en_zh({EN = "Skyworthy Shop", CN = "天空之椅商店"}),
		SKYWORTHY_SHOP_RECIPE = en_zh({EN = "Skyworthy Shop", CN = "天空之椅商店"}), --avoid crash
		PIG_SHOP_SKYWORTHY = en_zh({EN = "Skyworthy Shop", CN = "天空之椅商店"}),
		PROP_DOOR_HAMPORTAL = en_zh({EN = "Skyworthy Shop", CN = "天空之椅商店"}),
		SKYWORTHY = en_zh({EN = "Skyworthy", CN = "天空之椅"}),
		SKYWORTHY_KIT = en_zh({EN = "Skyworthy Kit", CN = "天空之椅套装"}),
		SLINGSHOTAMMO_SHADOW = en_zh({EN = "Shadow Rounds", CN = "暗影弹丸"}),
		SLINGSHOTAMMO_INFUSED = en_zh({EN = "Infused Rounds", CN = "注能弹丸"}),
		SLINGSHOTAMMO_ALLOY = en_zh({EN = "Alloy Rounds", CN = "合金弹丸"}),
        SPICE_LOTUS = en_zh({EN = "Lotus Herb", CN = "半边莲"}),
        SPICE_LOTUS_FOOD = en_zh({EN = "Bitter {food}", CN = "苦味{food}"}),
		FROGFISHBOWL_HAMLET = en_zh({EN = "Fish Cordon Bleu", CN = "蓝带鱼排"}),
		SWEETANDSOURCARP = en_zh({EN = "Sweet and Sour Carp", CN = "糖醋鲤鱼"}),
		ALOE_OVERSIZED = en_zh({EN = "Giant Aloe Plant", CN = "巨型芦荟"}),
		ALOE_OVERSIZED_WAXED = en_zh({EN = "Waxed Giant Aloe Plant", CN = "打过蜡的 巨型芦荟"}),
		ALOE_OVERSIZED_ROTTEN = en_zh({EN = "Rotting Giant Aloe Plant", CN = "巨型腐烂芦荟"}),
		RADISH_OVERSIZED = en_zh({EN = "Giant Radish Plant", CN = "巨型水萝卜"}),
		RADISH_OVERSIZED_WAXED = en_zh({EN = "Waxed Giant Radish Plant", CN = "打过蜡的 巨型水萝卜"}),
		RADISH_OVERSIZED_ROTTEN = en_zh({EN = "Giant Rotting Radish Plant", CN = "巨型腐烂水萝卜"}),
		SHOPLOCKER = en_zh({EN = "Mayoral Mandate", CN = "镇长命令"}),
		DUMBBELL_IRON = en_zh({EN = "Iron Dumbbell", CN = "钢铁哑铃"}),
		SUNKEN_BOAT_TRINKET_2 = en_zh({EN = "Toy Boat", CN = "玩具船"}),
		TUBER_TREE_SAPLING = en_zh({EN = "Tuber Sapling", CN = "块茎树苗"}),
		TUBER_TREE_SAPLING_ITEM = en_zh({EN = "Tuber Sapling", CN = "块茎树苗"}),
		NETTLE_SAPLING = en_zh({EN = "Nettle Sapling", CN = "荨麻苗"}),
		NETTLE_SAPLING_ITEM = en_zh({EN = "Nettle Seeds", CN = "荨麻籽"}),
		PORTAL = en_zh({EN = "Florid Postern", CN = "绚丽之门"}),
	},
	RECIPE_DESC = {
		WX78MODULE_PORKLANDREBALANCE_FAN = en_zh({EN = "Blow that fog away!", CN = "把雾吹散！"}),
		WX78MODULE_PORKLANDREBALANCE_FILTER = en_zh({EN = "Even a soulless automaton requires a filter.", CN = "即使是没有灵魂的机器也需要过滤器。"}),
		SEEDOFRUIN = en_zh({EN = "It all started with a small seed...", CN = "好久以前，一切都像这只小混沌"}),
		SKYWORTHY_SHOP = en_zh({EN = "A Walmart-like supermarket", CN = "一座像沃尔玛一样的超市"}),
		PIG_SHOP_SKYWORTHY = en_zh({EN = "A Walmart-like supermarket", CN = "一座像沃尔玛一样的超市"}),
		SKYWORTHY_KIT = en_zh({EN = "Hop on board. What could possibly go wrong?", CN = "快上船，有什么可能出错呢？"}),
		SLINGSHOTAMMO_SHADOW = en_zh({EN = "Summon tentacles from the ancient past.", CN = "召唤远古时代的触手"}),
		SLINGSHOTAMMO_INFUSED = en_zh({EN = "Contains a mysterious energy that explodes when it hits.", CN = "里面蕴含某种神秘的力量，当击中目标时会产生爆炸。"}),
		SLINGSHOTAMMO_ALLOY = en_zh({EN = "It is made of the highest quality alloy.", CN = "它是由最优质的合金制成的"}),
		SPICE_LOTUS = en_zh({EN = "A kind of traditional Chinese medicine, it can be immune to the hayfever and venom.", CN = "一味中药，它可以免疫花粉过敏和中毒。"}),
		
		SHOPLOCKER = en_zh({EN = "Install it on the store's shelves,always keep it in stock!", CN = "安装在商店货架之上，确保货品永不断供！"}),
		
		DUMBBELL_IRON = en_zh({EN = "A weight as steely as your muscles.", CN = "锻炼你的肌肉，让它像钢铁一样坚强"}),

		TRANSMUTE_MOSQUITOSACK = en_zh({EN = "Transmute Spider Gland into Mosquito Sack", CN = "将蜘蛛腺转换为蚊子血囊"}),
		TRANSMUTE_SPIDERGLAND = en_zh({EN = "Transmute  Mosquito Sack into Spider Gland", CN = "将蚊子血囊转换为蜘蛛腺"}),
		TRANSMUTE_WEEVOLE_CARAPACE = en_zh({EN = "Transmute Chitin into Weevole Carapace", CN = "将甲壳质转换为象鼻鼠虫壳"}),
		TRANSMUTE_CHITIN= en_zh({EN = "Transmute Weevole Carapace into Chitin", CN = "将象鼻鼠虫壳转换为甲壳质"}),
		TRANSMUTE_BEARDHAIR = en_zh({EN = "Transmute Spider Silk into Beard Hair", CN = "将蜘蛛丝转换为胡须"}),
		TRANSMUTE_SILK = en_zh({EN = "Transmute Beard Hair into Spider Silk", CN = "将胡须转换为蜘蛛丝"}),
		TRANSMUTE_GEARS = en_zh({EN = "Transmute Alloy and Goldnugget into Gears", CN = "将合金和金块转换为齿轮"}),

		TUBER_TREE_SAPLING_ITEM = en_zh({EN = "Cultivate a tuber tree", CN = "培育一颗块茎树"}),
	},
	UI = {
		SAVEINTEGRATION = {
			CHOOSE_DEST_TITLE = en_zh({EN = "Travel to another world?", CN = "要前往另一个世界吗？"}), 
			CHOOSE_DEST_BODY = en_zh({EN = "Where would you like to travel to?", CN = "你想要去哪里呢？"}),
			NODESTINATIONS = en_zh({EN = "There is no world for you to travel to.", CN = "没有世界可供前往。"}),
			OK = en_zh({EN = "OK", CN = "好的"}),
			CANCEL = en_zh({EN = "Cancel", CN = "取消"}),
			FOREST = en_zh({EN = "Forest", CN = "森林"}),
			CAVE = en_zh({EN = "Caves", CN = "洞穴"}),
			ISLAND = en_zh({EN = "Shipwrecked", CN = "海难"}),
			VOLCANO = en_zh({EN = "Volcano", CN = "火山"}),
			PORKLAND = en_zh({EN = "Hamlet", CN = "猪镇"}),
			UNKNOWN = en_zh({EN = "Unknown", CN = "未知"}),
		},
	},
	SKILLTREE = {
		WILSON = {
			WILSON_ALCHEMY_9_DESC = en_zh({
				EN = "Transform 2 Beard Hair into Spider Silk.\nTransform 2 Spider Silk into Beard Hair.",
				CN = "将2个胡须转换为蜘蛛丝\n将2个蜘蛛丝转换为胡须"}),
			WILSON_ALCHEMY_8_DESC = en_zh({
				EN = "Transform 2 Spider Glands into Mosquito Sack.\nTransform 2 Mosquito Sacks into Spider Gland.\nTransform 2 Chitin into Weevole Carapace.\nTransform 2 Weevole Carapace into Chitin.",
				CN = "将2个蜘蛛腺体转换为蚊子血囊。\n将2个蚊子血囊转换为蜘蛛腺体。\n将2个甲壳质转换为象鼻鼠虫壳。\n将2个象鼻鼠虫壳转换为甲壳质。"}),
		},
		WURT = {
			WURT_MERMKINGSHOULDERS_DESC = en_zh({
				EN = "Add stony armor or tin suit to the King's statuesque shoulders for greater stoutness in your merm soldiers.",
				CN = "为国王的雕塑般的肩膀上添加石甲/铁制护肩，让你的鱼人士兵更加强壮。"
			}),
			WURT_MERMKINGTRIDENT_DESC = en_zh({
				EN = "Offer Trident or Pugalisk Wand, and your merms will attack with the deftness of three.",
				CN = "为国王献上翘鼻蛇怪权杖/三叉戟，你的鱼人将以三连拍的方式灵巧攻击。"
			}),
		}
	},
	CITY_PIG_SOW_ACCEPT_SEEDS = en_zh({EN = "YON SEED REQUIRE'TH CULTIVATION?", CN = "你的种子需要栽培吗？"}),
	CITY_PIG_SOW_ALREADY_HAVE_SEEDS = en_zh({EN = "YE STRAIN IS ALREADY CULTIVATED", CN = "这个品种已经被培育出来了"}),
	CITY_PIG_STOREOWNER_ACCEPT_ITEM = en_zh({EN = "Ah, excellent produce! The quality is superb. Here's your payment, my friend.", CN = "哇，上等的农产品！品质极佳。这是给你的报酬，朋友。"}),
	CITY_PIG_STOREOWNER_ACCEPT_ITEM_STALE = en_zh({EN = "Hmm... this is a bit past its prime. I'll still take it, but for a reduced price.", CN = "嗯...这有点不新鲜了。我仍然会收下，但价格会低一些。"}),
	CITY_PIG_STOREOWNER_ACCEPT_ITEM_SPOILED = en_zh({EN =  "Eww! This is spoiled! Well, I'll give you one oinc for it, but don't tell anyone!", CN = "噫！这东西坏了！好吧，我给你一个呼噜币，但别告诉别人！"}),
	
	CHARACTER_LINE = {
		WISHINGWELL = {
			WANDA = en_zh({EN = "The temporal fracture is mended!", CN = "时间裂隙被修复了"}),
			MAXWELL = en_zh({EN = "The ancient writings... they're glowing!", CN = "古老的文字在发光..."}),
			WILLOW_BERNIE = en_zh({EN = "Bernie's ready for action again!", CN = "伯尼又可以陪我战斗了！"}),
			WILLOW_LIGHTER = en_zh({EN = "No more cold nights. Let's light up the world!", CN = "没有寒冷的夜了，让我们点燃世界吧！"}),
			WATHGRITHR_SPEAR = en_zh({EN = "My spare thirsts for new battles!", CN = "我的长矛渴望着新的战斗！"}),
			WATHGRITHR_HELMET = en_zh({EN = "A clear mind is a warrior's best armor.", CN = "清醒的头脑是战士最好的盔甲."}),
			WATHGRITHR_SHIELD = en_zh({EN = "My shield is my oath to stand unbroken!", CN = "我的盾牌是我屹立不倒的誓言！"}),
			WINONA_TELEBRELLA = en_zh({EN = "Back in action! Gotta stay mobile for the job.", CN = "又能用了！工作需要随时保持机动性。"}),
			WINONA_STORAGE_ROBOT = en_zh({EN = "My bot's purring like new! Efficiency restored.", CN = "我的机器人像新的一样！工作效率恢复了。"}),
			WINONA_REMOTE = en_zh({EN = "Signal's crystal clear! No more faulty connections.", CN = "信号清晰无比！再也不会连接故障了。"}),
			WENDY_BONDLEVEL = en_zh({EN = "Our bond grows stronger, Abigail!", CN = "阿比盖尔，我们的羁绊更深了！"}),
			WENDY_GHOST_HEAL = en_zh({EN = "Rest now, dear sister...", CN = "好好休息吧，我亲爱的妹妹..."}),
			WATHGRITHR_INSPIRATION = en_zh({EN = "My battle song resonates within!", CN = "战斗之歌在我心中回响！"}),
			WOLFGANG_MIGHTINESS = en_zh({EN = "Wolfgang is strongest again!", CN = "沃尔夫冈又是最强壮的了！"}),
			WX78_CHARGE = en_zh({EN = "POWER LEVELS MAXIMIZED", CN = "能量水平达到最大值"}),
			WX78_DRY = en_zh({EN = "MOISTURE DETECTED: PURGING", CN = "检测到水分：清除中"}),
			WICKERBOTTOM_KNOCKOUT = en_zh({EN = "Finally... sweet unconsciousness...", CN = "终于...沉入了无意识的甜梦..."}),
			WICKERBOTTOM_GROGGINESS = en_zh({EN = "This sleeplessness... it's draining me...", CN = "这无眠之夜...正在耗尽我的精力..."}),
		},
		SUNKEN_BOAT_TRINKET_2 = en_zh({EN = "In this junk pile, lies the treasure of the Pig King!", CN = "在这堆垃圾里，竟藏着猪王的珍宝！"}),
	},
	CHARACTERS = {
		GENERIC = {
			DESCRIBE = {
				TUBER_TREE_SAPLING = {
					GENERIC = en_zh({EN = "A tiny tuber sprout,waiting to grow.", CN = "一株小小的块茎嫩芽，等待着生长。"}),
					WRONG_SEASON = en_zh({EN = "Ah, perhaps it's not yet the season for blooming.", CN = "啊，或许还没到开花的季节。"}),
					WRONG_TILE = en_zh({EN = "I need to plant this in the right place.", CN = "我得把它种在对的地方。"}),
				},
				NETTLE_SAPLING = {
					GENERIC = en_zh({EN = "Ah, a nettle sprout. Best not to touch it barehanded.", CN = "啊，是荨麻的幼苗。最好别空手去碰它。"}),
					WRONG_SEASON = en_zh({EN = "Ah, perhaps it's not yet the season for blooming.", CN = "啊，或许还没到开花的季节。"}),
					WRONG_TILE = en_zh({EN = "I need to plant this in the right place.", CN = "我得把它种在对的地方。"}),
					WRONG_TOODRY = en_zh({EN = "The soil is too dry, it needs more moisture to grow.", CN = "这土壤太干燥了，需要更多水分才能生长。"}),
				},
			},
		},
	},
}

--[[
STRINGS.ACTIONS.PORKLANDREBALANCE_REPICK = "Reincarnate"

STRINGS.CHARACTERS.GENERIC.DESCRIBE.VORTEXEYE = "I..I don't feel so good.."
STRINGS.CHARACTERS.WILSON.DESCRIBE.VORTEXEYE = "A familiar presence?"
STRINGS.CHARACTERS.WILLOW.DESCRIBE.VORTEXEYE = "It's cold..too cold..."
STRINGS.CHARACTERS.WENDY.DESCRIBE.VORTEXEYE = "Will this take me to Abigail?"
STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.VORTEXEYE = "Wolfgang does not like spooky eye."
STRINGS.CHARACTERS.WX78.DESCRIBE.VORTEXEYE = "ERROR: CANNOT PERCEIVE THROUGH THE BEYOND."
STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.VORTEXEYE = "This trinket somehow reminds me of the post-Vedic myths of Samsara."
STRINGS.CHARACTERS.WOODIE.DESCRIBE.VORTEXEYE = "It looks cold, eh, Lucy?"
STRINGS.CHARACTERS.WAXWELL.DESCRIBE.VORTEXEYE = "No doubt the work of Them."
STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.VORTEXEYE = "The maw of Hel."
STRINGS.CHARACTERS.WEBBER.DESCRIBE.VORTEXEYE = "It's so cold inside!"
STRINGS.CHARACTERS.WARLY.DESCRIBE.VORTEXEYE = "Maman..."
STRINGS.CHARACTERS.WORMWOOD.DESCRIBE.VORTEXEYE = "So cold."
STRINGS.CHARACTERS.WINONA.DESCRIBE.VORTEXEYE = "C-charlie? Are you there?"
STRINGS.CHARACTERS.WORTOX.DESCRIBE.VORTEXEYE = "Hyuyu! To another adventure!"
STRINGS.CHARACTERS.WALTER.DESCRIBE.VORTEXEYE = "Yeeeep. It's cursed."
STRINGS.CHARACTERS.WURT.DESCRIBE.VORTEXEYE = "Feel weeeeeeeeeeeeak..."
STRINGS.CHARACTERS.WANDA.DESCRIBE.VORTEXEYE = "It's time for Them to take me, isn't it?"]]--