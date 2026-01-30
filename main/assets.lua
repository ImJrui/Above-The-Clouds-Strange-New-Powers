PrefabFiles = {
	"vortexeye",
	"wx78_newmodules",
	"seedofruin",
	"plrebalance_ruinsresetfx",
	"pondcoi",
	"skyworthy_shop",
	"plrebalance_deco",
	"newslingshotammo",
	"newspices",
	"newpreparedfoods",
	"newfoodbuffs",
	"new_veggies",
	"shoplocker",
	"dumbbell_iron",
	"skyworthy",
	"pl_trinkets",
	"plrebalance_planted_tree",
	"tuber_tree_sapling",
	"nettle_sapling",
}

Assets = {
	
	Asset("IMAGE", "images/hud/plrebalance_inventoryimages.tex"),
	Asset("ATLAS", "images/hud/plrebalance_inventoryimages.xml"),
	--for minisign
    Asset("ATLAS_BUILD", "images/hud/plrebalance_inventoryimages.xml", 256),
	
    Asset("ANIM", "anim/wx_circuits_porkland.zip"),
    --Asset("ANIM", "anim/seedofruin.zip"),
    Asset("ANIM", "anim/plrebalance_ruinsresetfx.zip"),
	Asset("ANIM", "anim/newslingshotammo.zip"),
	Asset("ANIM", "anim/newspices.zip"),
	Asset("ANIM", "anim/new_cook_pot_food.zip"),
	
	Asset("ANIM", "anim/plrebalance_royalseal.zip"),
	Asset("ANIM", "anim/sea_trinkets.zip"),
	Asset("ANIM", "anim/tuber_tree_sapling.zip"),
	Asset("ANIM", "anim/nettle_sapling.zip"),
	Asset("ANIM", "anim/nettle_sapling_item.zip"),
	Asset("ANIM", "anim/pl_swap_items.zip"),
}

GLOBAL.setfenv(1, GLOBAL)

ToolUtil.RegisterInventoryItemAtlas("images/hud/plrebalance_inventoryimages.xml")