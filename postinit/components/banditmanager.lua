local AddComponentPostInit = AddComponentPostInit

GLOBAL.setfenv(1, GLOBAL)

AddComponentPostInit("banditmanager", function(self)
    self.HasOrb = false
    self.SpawnOrbChance = 0

    local _old_OnSave = self.OnSave
    local _old_OnLoad = self.OnLoad
    local _old_GetLoot = self.GetLoot

    function self:GetLoot()
        local day = TheWorld.state.cycles
        local loot = _old_GetLoot and _old_GetLoot(self) or {}

        if not self.HasOrb then
            self.SpawnOrbChance = self.SpawnOrbChance + 0.05
            -- print("tutu:Orb spawn probability has been increased to", self.SpawnOrbChance)
        end

        if #loot >= 9 then
            return loot
        end

        -- spawn Orb
        if not self.HasOrb and math.random() < (self.SpawnOrbChance + day/100) then
            local new_loot = {}
            for k, v in pairs(loot) do
                new_loot[k] = v
            end
            new_loot.moonrockseed = 1
            self.HasOrb = true
            self.SpawnOrbChance = 0
            -- print("tutu:Spawn Orb")
            return new_loot
        end

        -- spawn moon shards
        if math.random() < 0.34 then
            local new_loot = {}
            for k, v in pairs(loot) do
                new_loot[k] = v
            end
            new_loot.moonglass = math.random(1, 15)
            -- print("tutu:Spawn Moon shards")
            return new_loot
        end

        return loot
    end

    function self:OnSave()
        local data, refs = _old_OnSave and _old_OnSave(self) or {}, {}
        data.HasOrb = self.HasOrb
        data.SpawnOrbChance = self.SpawnOrbChance
        return data, refs
    end

    function self:OnLoad(data)
        if _old_OnLoad then
            _old_OnLoad(self, data)
        end

        if data then
            self.HasOrb = data.HasOrb or false
            self.SpawnOrbChance = data.SpawnOrbChance or 0
        end
    end
end)