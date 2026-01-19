local SkyworthyManager = Class(function(self, inst)
    self.inst = inst
	self.has_cityhammer = false
	self.has_citykey = false
	self.has_sillystring = false
	self.trinket_pigking = "sunken_boat_trinket_2"
	self.basket_tasks = {
		"Make a pick",
		"Dig that rock",
		"Great Plains",
		-- "Squeltch",
		"Beeeees!",
		-- "Speak to the king",
		"Forest hunters",
		-- "Badlands",
		"For a nice walk",
		-- "Lightning Bluff"
	}

	self.inst:DoTaskInTime(0, function()
        if TheWorld:HasTag("forest") and not self.has_sillystring then
			self:SpawnPorklandIntroBasket()
		end
    end)
end)

function SkyworthyManager:GetLootFromPigking()
	local loots = {"city_hammer", "key_to_city"}
	self.has_cityhammer = true
	self.has_citykey = true
	return loots
end

function SkyworthyManager:GetLootFromJunk()
	local loots = {}
	if not self.has_sillystring and math.random() < 0.5 then
		self.has_sillystring = true
		loots[#loots + 1] = "trinket_giftshop_4"
	else
		loots[#loots + 1] = self.trinket_pigking
	end
	return loots
end

function SkyworthyManager:SpawnPorklandIntroBasket()
    local max_attempts = 1000
    local attempts = 0
    
    while attempts < max_attempts do
        attempts = attempts + 1
        
        local land_point = TheWorld.Map:FindRandomPointOnLand(10)
		if land_point then
			local x, y, z = land_point.x, land_point.y, land_point.z
			local can_task = false

			local id, index = TheWorld.Map:GetTopologyIDAtPoint(x, y, z)
			local is_deploy_clear = TheWorld.Map:IsDeployPointClear(land_point, nil, 12)
			local is_nearbyocean = TheWorld.Map:GetNearbyOceanPointFromXZ(x, z, 12, 1)

			if id then
				for i = 1, #self.basket_tasks do
					if id:find(self.basket_tasks[i]) then
						can_task = true
						break
					end
				end
			end
			
			if can_task and is_deploy_clear and not is_nearbyocean then
				local basket = SpawnPrefab("porkland_intro_basket")
				local porkland_intro_scrape = SpawnPrefab("porkland_intro_scrape")
				basket.Transform:SetPosition(x, y, z)
				porkland_intro_scrape.Transform:SetPosition(x, y, z)
				self.has_sillystring = true
				-- print("tutu:spawned porkland_intro_basket", attempts)
				return
			end
		end
	end
	-- print("tutu:fail to spawn porkland_intro_basket on land")
end

function SkyworthyManager:OnSave()
	local data = {}
	data.has_cityhammer = self.has_cityhammer
	data.has_citykey = self.has_citykey
	data.has_sillystring = self.has_sillystring
	
	return data
end

function SkyworthyManager:OnLoad(data)
	if data then
		self.has_cityhammer = data.has_cityhammer
		self.has_citykey = data.has_citykey
		self.has_sillystring = data.has_sillystring
	end
end

return SkyworthyManager