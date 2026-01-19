local function _Translator(string)
	return string["EN"]
end

return {
	ACTIONS = {
		PORKLANDREBALANCE_REPICK = _Translator({EN = "Reincarnate", CN = "重选"}),
		PORKLANDREBALANCE_REGENERATERUINS = _Translator({EN = "Regenerate", CN = "重置"}),
		PORKLANDREBALANCE_LOCKSHOP = _Translator({EN = "Commission {item}", CN = "佣金 {item}"}),
		PORKLANDREBALANCE_LOCKSHOPREFRESH = _Translator({EN = "Refresh Commission", CN = "刷新佣金"}),
		PORKLANDREBALANCE_WALTERAIMEDSHOT = _Translator({EN = "Aim At", CN = "瞄准"}),
	},
	NAMES = {
		WX78MODULE_PORKLANDREBALANCE_FAN = _Translator({EN = "Convection Circuit", CN = "对流电路"}),
		WX78MODULE_PORKLANDREBALANCE_FILTER = _Translator({EN = "Purifying Circuit", CN = "净化电路"}),
		SEEDOFRUIN = _Translator({EN = "Seed of Ruin", CN = "遗迹种子"}),
		SKYWORTHY_SHOP = _Translator({EN = "Skyworthy Shop", CN = "天空之椅商店"}),
		SKYWORTHY_SHOP_RECIPE = _Translator({EN = "Skyworthy Shop", CN = "天空之椅商店"}), --avoid crash
		PIG_SHOP_SKYWORTHY = _Translator({EN = "Skyworthy Shop", CN = "天空之椅商店"}),
		PROP_DOOR_HAMPORTAL = _Translator({EN = "Skyworthy Shop", CN = "天空之椅商店"}),
		SKYWORTHY = _Translator({EN = "Skyworthy", CN = "天空之椅"}),
		SKYWORTHY_KIT = _Translator({EN = "Skyworthy Kit", CN = "天空之椅套装"}),
		SLINGSHOTAMMO_SHADOW = _Translator({EN = "Shadow Rounds", CN = "暗影弹丸"}),
		SLINGSHOTAMMO_INFUSED = _Translator({EN = "Infused Rounds", CN = "注能弹丸"}),
		SLINGSHOTAMMO_ALLOY = _Translator({EN = "Alloy Rounds", CN = "合金弹丸"}),
        SPICE_LOTUS = _Translator({EN = "Lotus Herb", CN = "半边莲"}),
        SPICE_LOTUS_FOOD = _Translator({EN = "Bitter {food}", CN = "苦味{food}"}),
		FROGFISHBOWL_HAMLET = _Translator({EN = "Fish Cordon Bleu", CN = "蓝带鱼排"}),
		SWEETANDSOURCARP = _Translator({EN = "Sweet and Sour Carp", CN = "糖醋鲤鱼"}),
		ALOE_OVERSIZED = _Translator({EN = "Giant Aloe Plant", CN = "巨型芦荟"}),
		ALOE_OVERSIZED_WAXED = _Translator({EN = "Waxed Giant Aloe Plant", CN = "打过蜡的 巨型芦荟"}),
		ALOE_OVERSIZED_ROTTEN = _Translator({EN = "Rotting Giant Aloe Plant", CN = "巨型腐烂芦荟"}),
		RADISH_OVERSIZED = _Translator({EN = "Giant Radish Plant", CN = "巨型水萝卜"}),
		RADISH_OVERSIZED_WAXED = _Translator({EN = "Waxed Giant Radish Plant", CN = "打过蜡的 巨型水萝卜"}),
		RADISH_OVERSIZED_ROTTEN = _Translator({EN = "Giant Rotting Radish Plant", CN = "巨型腐烂水萝卜"}),
		SHOPLOCKER = _Translator({EN = "Mayoral Mandate", CN = "镇长命令"}),
		DUMBBELL_IRON = _Translator({EN = "Iron Dumbbell", CN = "钢铁哑铃"}),
		SUNKEN_BOAT_TRINKET_2 = _Translator({EN = "Toy Boat", CN = "玩具船"}),
		TUBER_TREE_SAPLING = _Translator({EN = "Tuber Sapling", CN = "块茎树苗"}),
		TUBER_TREE_SAPLING_ITEM = _Translator({EN = "Tuber Sapling", CN = "块茎树苗"}),
		NETTLE_SAPLING = _Translator({EN = "Nettle Sapling", CN = "荨麻苗"}),
		NETTLE_SAPLING_ITEM = _Translator({EN = "Nettle Seeds", CN = "荨麻籽"}),
		PORTAL = _Translator({EN = "Florid Postern", CN = "绚丽之门"}),
	},
	RECIPE_DESC = {
		WX78MODULE_PORKLANDREBALANCE_FAN = _Translator({EN = "Blow that fog away!", CN = "把雾吹散！"}),
		WX78MODULE_PORKLANDREBALANCE_FILTER = _Translator({EN = "Even a soulless automaton requires a filter.", CN = "即使是没有灵魂的机器也需要过滤器。"}),
		SEEDOFRUIN = _Translator({EN = "It all started with a small seed...", CN = "好久以前，一切都像这只小混沌"}),
		SKYWORTHY_SHOP = _Translator({EN = "A Walmart-like supermarket", CN = "一座像沃尔玛一样的超市"}),
		PIG_SHOP_SKYWORTHY = _Translator({EN = "A Walmart-like supermarket", CN = "一座像沃尔玛一样的超市"}),
		SKYWORTHY_KIT = _Translator({EN = "Hop on board. What could possibly go wrong?", CN = "快上船，有什么可能出错呢？"}),
		SLINGSHOTAMMO_SHADOW = _Translator({EN = "Summon tentacles from the ancient past.", CN = "召唤远古时代的触手"}),
		SLINGSHOTAMMO_INFUSED = _Translator({EN = "Contains a mysterious energy that explodes when it hits.", CN = "里面蕴含某种神秘的力量，当击中目标时会产生爆炸。"}),
		SLINGSHOTAMMO_ALLOY = _Translator({EN = "It is made of the highest quality alloy.", CN = "它是由最优质的合金制成的"}),
		SPICE_LOTUS = _Translator({EN = "A kind of traditional Chinese medicine, it can be immune to the hayfever and venom.", CN = "一味中药，它可以免疫花粉过敏和中毒。"}),
		
		SHOPLOCKER = _Translator({EN = "Install it on the store's shelves,always keep it in stock!", CN = "安装在商店货架之上，确保货品永不断供！"}),
		
		DUMBBELL_IRON = _Translator({EN = "A weight as steely as your muscles.", CN = "锻炼你的肌肉，让它像钢铁一样坚强"}),

		TRANSMUTE_MOSQUITOSACK = _Translator({EN = "Transmute Spider Gland into Mosquito Sack", CN = "将蜘蛛腺转换为蚊子血囊"}),
		TRANSMUTE_SPIDERGLAND = _Translator({EN = "Transmute  Mosquito Sack into Spider Gland", CN = "将蚊子血囊转换为蜘蛛腺"}),
		TRANSMUTE_WEEVOLE_CARAPACE = _Translator({EN = "Transmute Chitin into Weevole Carapace", CN = "将甲壳质转换为象鼻鼠虫壳"}),
		TRANSMUTE_CHITIN= _Translator({EN = "Transmute Weevole Carapace into Chitin", CN = "将象鼻鼠虫壳转换为甲壳质"}),
		TRANSMUTE_BEARDHAIR = _Translator({EN = "Transmute Spider Silk into Beard Hair", CN = "将蜘蛛丝转换为胡须"}),
		TRANSMUTE_SILK = _Translator({EN = "Transmute Beard Hair into Spider Silk", CN = "将胡须转换为蜘蛛丝"}),

		TUBER_TREE_SAPLING_ITEM = _Translator({EN = "Cultivate a tuber tree", CN = "培育一颗块茎树"}),
	},
	UI = {
		SAVEINTEGRATION = {
			CHOOSE_DEST_TITLE = _Translator({EN = "Travel to another world?", CN = "要前往另一个世界吗？"}), 
			CHOOSE_DEST_BODY = _Translator({EN = "Where would you like to travel to?", CN = "你想要去哪里呢？"}),
			NODESTINATIONS = _Translator({EN = "There is no world for you to travel to.", CN = "没有世界可供前往。"}),
			OK = _Translator({EN = "OK", CN = "好的"}),
			CANCEL = _Translator({EN = "Cancel", CN = "取消"}),
			FOREST = _Translator({EN = "Forest", CN = "森林"}),
			CAVE = _Translator({EN = "Caves", CN = "洞穴"}),
			ISLAND = _Translator({EN = "Shipwrecked", CN = "海难"}),
			VOLCANO = _Translator({EN = "Volcano", CN = "火山"}),
			PORKLAND = _Translator({EN = "Hamlet", CN = "猪镇"}),
			UNKNOWN = _Translator({EN = "Unknown", CN = "未知"}),
		},
	},
	SKILLTREE = {
		WILSON = {
			WILSON_ALCHEMY_9_DESC = _Translator({
				EN = "Transform 2 Beard Hair into Spider Silk.\nTransform 2 Spider Silk into Beard Hair.",
				CN = "将2个胡须转换为蜘蛛丝\n将2个蜘蛛丝转换为胡须"}),
			WILSON_ALCHEMY_8_DESC = _Translator({
				EN = "Transform 2 Spider Glands into Mosquito Sack.\nTransform 2 Mosquito Sacks into Spider Gland.\nTransform 2 Chitin into Weevole Carapace.\nTransform 2 Weevole Carapace into Chitin.",
				CN = "将2个蜘蛛腺体转换为蚊子血囊。\n将2个蚊子血囊转换为蜘蛛腺体。\n将2个甲壳质转换为象鼻鼠虫壳。\n将2个象鼻鼠虫壳转换为甲壳质。"}),
		},
		WURT = {
			WURT_MERMKINGSHOULDERS_DESC = _Translator({
				EN = "Add stony armor or tin suit to the King's statuesque shoulders for greater stoutness in your merm soldiers.",
				CN = "为国王的雕塑般的肩膀上添加石甲/铁制护肩，让你的鱼人士兵更加强壮。"
			}),
			WURT_MERMKINGTRIDENT_DESC = _Translator({
				EN = "Offer Trident or Pugalisk Wand, and your merms will attack with the deftness of three.",
				CN = "为国王献上翘鼻蛇怪权杖/三叉戟，你的鱼人将以三连拍的方式灵巧攻击。"
			}),
		}
	},
	CITY_PIG_SOW_ACCEPT_SEEDS = _Translator({EN = "YON SEED REQUIRE'TH CULTIVATION?", CN = "你的种子需要栽培吗？"}),
	CITY_PIG_SOW_ALREADY_HAVE_SEEDS = _Translator({EN = "YE STRAIN IS ALREADY CULTIVATED", CN = "这个品种已经被培育出来了"}),
	CITY_PIG_STOREOWNER_ACCEPT_ITEM = _Translator({EN = "Ah, excellent produce! The quality is superb. Here's your payment, my friend.", CN = "哇，上等的农产品！品质极佳。这是给你的报酬，朋友。"}),
	CITY_PIG_STOREOWNER_ACCEPT_ITEM_STALE = _Translator({EN = "Hmm... this is a bit past its prime. I'll still take it, but for a reduced price.", CN = "嗯...这有点不新鲜了。我仍然会收下，但价格会低一些。"}),
	CITY_PIG_STOREOWNER_ACCEPT_ITEM_SPOILED = _Translator({EN =  "Eww! This is spoiled! Well, I'll give you one oinc for it, but don't tell anyone!", CN = "噫！这东西坏了！好吧，我给你一个呼噜币，但别告诉别人！"}),
	
	CHARACTER_LINE = {
		WISHINGWELL = {
			WANDA = _Translator({EN = "The temporal fracture is mended!", CN = "时间裂隙被修复了"}),
			MAXWELL = _Translator({EN = "The ancient writings... they're glowing!", CN = "古老的文字在发光..."}),
			WILLOW_BERNIE = _Translator({EN = "Bernie's ready for action again!", CN = "伯尼又可以陪我战斗了！"}),
			WILLOW_LIGHTER = _Translator({EN = "No more cold nights. Let's light up the world!", CN = "没有寒冷的夜了，让我们点燃世界吧！"}),
			WATHGRITHR_SPEAR = _Translator({EN = "My spare thirsts for new battles!", CN = "我的长矛渴望着新的战斗！"}),
			WATHGRITHR_HELMET = _Translator({EN = "A clear mind is a warrior's best armor.", CN = "清醒的头脑是战士最好的盔甲."}),
			WATHGRITHR_SHIELD = _Translator({EN = "My shield is my oath to stand unbroken!", CN = "我的盾牌是我屹立不倒的誓言！"}),
			WINONA_TELEBRELLA = _Translator({EN = "Back in action! Gotta stay mobile for the job.", CN = "又能用了！工作需要随时保持机动性。"}),
			WINONA_STORAGE_ROBOT = _Translator({EN = "My bot's purring like new! Efficiency restored.", CN = "我的机器人像新的一样！工作效率恢复了。"}),
			WINONA_REMOTE = _Translator({EN = "Signal's crystal clear! No more faulty connections.", CN = "信号清晰无比！再也不会连接故障了。"}),
			WENDY_BONDLEVEL = _Translator({EN = "Our bond grows stronger, Abigail!", CN = "阿比盖尔，我们的羁绊更深了！"}),
			WENDY_GHOST_HEAL = _Translator({EN = "Rest now, dear sister...", CN = "好好休息吧，我亲爱的妹妹..."}),
			WATHGRITHR_INSPIRATION = _Translator({EN = "My battle song resonates within!", CN = "战斗之歌在我心中回响！"}),
			WOLFGANG_MIGHTINESS = _Translator({EN = "Wolfgang is strongest again!", CN = "沃尔夫冈又是最强壮的了！"}),
			WX78_CHARGE = _Translator({EN = "POWER LEVELS MAXIMIZED", CN = "能量水平达到最大值"}),
			WX78_DRY = _Translator({EN = "MOISTURE DETECTED: PURGING", CN = "检测到水分：清除中"}),
			WICKERBOTTOM_KNOCKOUT = _Translator({EN = "Finally... sweet unconsciousness...", CN = "终于...沉入了无意识的甜梦..."}),
			WICKERBOTTOM_GROGGINESS = _Translator({EN = "This sleeplessness... it's draining me...", CN = "这无眠之夜...正在耗尽我的精力..."}),
		},
		SUNKEN_BOAT_TRINKET_2 = _Translator({EN = "In this junk pile, lies the treasure of the Pig King!", CN = "在这堆垃圾里，竟藏着猪王的珍宝！"}),
	},
	CHARACTERS = {
		GENERIC = {
			DESCRIBE = {
				TUBER_TREE_SAPLING = {
					GENERIC = _Translator({EN = "A tiny tuber sprout,waiting to grow.", CN = "一株小小的块茎嫩芽，等待着生长。"}),
					WRONG_SEASON = _Translator({EN = "Ah, perhaps it's not yet the season for blooming.", CN = "啊，或许还没到开花的季节。"}),
					WRONG_TILE = _Translator({EN = "I need to plant this in the right place.", CN = "我得把它种在对的地方。"}),
				},
				NETTLE_SAPLING = {
					GENERIC = _Translator({EN = "Ah, a nettle sprout. Best not to touch it barehanded.", CN = "啊，是荨麻的幼苗。最好别空手去碰它。"}),
					WRONG_SEASON = _Translator({EN = "Ah, perhaps it's not yet the season for blooming.", CN = "啊，或许还没到开花的季节。"}),
					WRONG_TILE = _Translator({EN = "I need to plant this in the right place.", CN = "我得把它种在对的地方。"}),
					WRONG_TOODRY = _Translator({EN = "The soil is too dry, it needs more moisture to grow.", CN = "这土壤太干燥了，需要更多水分才能生长。"}),
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