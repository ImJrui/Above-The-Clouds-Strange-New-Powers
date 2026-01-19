local AddPrefabPostInit = AddPrefabPostInit

GLOBAL.setfenv(1, GLOBAL)

local function postinit_fn(inst)
	if not TheWorld.ismastersim or not TheWorld:HasTag("forest") then
		return inst
	end

	local _onpickedfn = inst.components.pickable.onpickedfn

	inst.components.pickable.onpickedfn = function(inst, picker, loot)
		if picker and picker:IsValid() and picker:HasTag("player") then
			local skyworthymanager = TheWorld.components.skyworthymanager
			if skyworthymanager and math.random() < 0.02 then
				local _loot = skyworthymanager:GetLootFromJunk()
				if #_loot > 0 then
					for i = 1, #_loot do
						picker.components.inventory:GiveItem(SpawnPrefab(_loot[i]))
					end
					picker.components.talker:Say(STRINGS.CHARACTER_LINE.SUNKEN_BOAT_TRINKET_2)
				end
			end
		end
		if _onpickedfn then
			_onpickedfn(inst, picker, loot)
		end
	end
end

AddPrefabPostInit("junk_pile", postinit_fn)
AddPrefabPostInit("junk_pile_big", postinit_fn)
