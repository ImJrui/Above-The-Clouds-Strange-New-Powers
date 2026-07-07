local duration = 1

local UpgradeModuleBuff = Class(function(self, inst)
    self.inst = inst

    self.auras = {}
    self.buffs = {}

    self.task = nil
    self.freq = 0.5

    self.inst:ListenForEvent("death", function() self:Disable() end)
    self.inst:ListenForEvent("onremove", function() self:Disable() end)
end)

--------------------------------------------------
-- update loop
--------------------------------------------------

function UpgradeModuleBuff:OnUpdate()

    -- aura tick
    for aura, data in pairs(self.auras) do
        self:AttachToTargets(aura, data)
    end

    -- decay tick
    for buffname in pairs(self.buffs) do
        self:DoDelta(buffname, self.freq)
    end

    -- 1. bonus update（每 tick 最多一次）
    for buffname, buff in pairs(self.buffs) do
        if buff._bonusdirty then
            buff._bonusdirty = false
            self:OnBonusUpdate(buffname)
        end
    end

    -- 2. detach（tick 末统一处理）
    for buffname, buff in pairs(self.buffs) do
        if next(buff.sources) == nil then
            self:OnDetach(buffname)
        end
    end

    -- auto disable
    if next(self.auras) == nil and next(self.buffs) == nil then
        self:Disable()
        self.inst:RemoveComponent("upgrademodulebuff")
    end
end

--------------------------------------------------
-- aura management
--------------------------------------------------

function UpgradeModuleBuff:AddAuraSource(key, data)
    self.auras[key] = data
    self:Enable()
end

function UpgradeModuleBuff:UpdateAura(key, data)
    if not self.auras[key] then return end
    for k, v in pairs(data) do
        self.auras[key][k] = v
    end
end

function UpgradeModuleBuff:RemoveAura(key)
    self.auras[key] = nil
end

function UpgradeModuleBuff:RemoveAllAuras()
    self.auras = {}
end

--------------------------------------------------
-- apply aura to targets
--------------------------------------------------

function UpgradeModuleBuff:AttachToTargets(buffname, data)
    local x, y, z = self.inst.Transform:GetWorldPosition()

    local players = {self.inst}
    if not TheNet:GetPVPEnabled() then
        players = FindPlayersInRange(x, y, z, data.radius, true)
    end

    for i = 1, #players do
        local player = players[i]

        if player and player:IsValid() and not player:HasTag("playerghost") then
            local comp = player.components.upgrademodulebuff
            if not comp then
                comp = player:AddComponent("upgrademodulebuff")
            end

            if comp.buffs[buffname] == nil then
                comp:Attach(buffname, data)
            else
                comp:Extend(buffname, data)
            end
        end
    end
end

--------------------------------------------------
-- tick decay（只负责标记变化）
--------------------------------------------------

function UpgradeModuleBuff:DoDelta(buffname, delta)
    local buff = self.buffs[buffname]
    if not buff then return end

    local changed = false

    for bonus, v in pairs(buff.sources) do
        v.timeleft = v.timeleft - delta

        if v.timeleft <= 0 then
            buff.sources[bonus] = nil
            changed = true
        end
    end

    if changed then
        buff._bonusdirty = true
    end
end

--------------------------------------------------
-- attach / extend
--------------------------------------------------

function UpgradeModuleBuff:Attach(buffname, data)
    self.buffs[buffname] = {
        sources = {
            [data.bonus] = {
                timeleft = duration,
            }
        },

        onattachedfn = data.onattachedfn,
        ondetachedfn = data.ondetachedfn,
        onupdatedfn = data.onupdatedfn,

        current_bonus = nil,

        _bonusdirty = true
    }

    if data.onattachedfn then
        data.onattachedfn(self.inst)
    end

	self:Enable()
end

function UpgradeModuleBuff:Extend(buffname, data)
    local buff = self.buffs[buffname]
    if not buff then return end

    local existed = (buff.sources[data.bonus] ~= nil)

    buff.sources[data.bonus] = {
        timeleft = duration,
    }

    -- 只有“新增 bonus”才影响结构
    if not existed then
        buff._bonusdirty = true
    end
end

--------------------------------------------------
-- recompute bonus（每 tick 最多一次）
--------------------------------------------------

function UpgradeModuleBuff:OnBonusUpdate(buffname)
    local buff = self.buffs[buffname]
    if not buff then return end

    local max_bonus = nil

    for bonus in pairs(buff.sources) do
        if max_bonus == nil or bonus > max_bonus then
            max_bonus = bonus
        end
    end

    local changed = (buff.current_bonus ~= max_bonus)
    buff.current_bonus = max_bonus

    if changed and buff.onupdatedfn then
        buff.onupdatedfn(self.inst, buff.current_bonus or 0)
    end
end

--------------------------------------------------
-- detach
--------------------------------------------------

function UpgradeModuleBuff:OnDetach(buffname)
    local buff = self.buffs[buffname]
    if not buff then return end

    if buff.ondetachedfn then
        buff.ondetachedfn(self.inst)
    end

    self.buffs[buffname] = nil
end

function UpgradeModuleBuff:RemoveAllBuffs()
    for buffname, buff in pairs(self.buffs) do
		if buff.current_bonus ~= nil then
			if buff.onupdatedfn then
				buff.onupdatedfn(self.inst, 0)
			end
		end
        self:OnDetach(buffname)
    end
end

--------------------------------------------------
-- lifecycle
--------------------------------------------------

function UpgradeModuleBuff:Enable()
    if not self.task then
        self.task = self.inst:DoPeriodicTask(self.freq, function()
            self:OnUpdate()
        end)
    end
end

function UpgradeModuleBuff:Disable()
    if self.task then
        self.task:Cancel()
        self.task = nil
    end

    self:RemoveAllAuras()
    self:RemoveAllBuffs()
end

--------------------------------------------------
-- save/load
--------------------------------------------------

function UpgradeModuleBuff:OnSave()
    return nil
end

function UpgradeModuleBuff:OnLoad(data)
end

--------------------------------------------------
--[[ Debug ]]
--------------------------------------------------

function UpgradeModuleBuff:Dump()
    print(string.format("===== UpgradeModuleBuff [%s] =====", self.inst.prefab))
    print("Component Enabled:", self.task ~= nil)

    -- Auras
    print("--- Auras ---")
    if next(self.auras) == nil then
        print("  (none)")
    else
        for name, data in pairs(self.auras) do
            print(string.format("  [%s] radius=%s, bonus=%s", tostring(name), tostring(data.radius), tostring(data.bonus)))
        end
    end

    -- Buffs
    print("--- Buffs ---")
    if next(self.buffs) == nil then
        print("  (none)")
    else
        for name, buff in pairs(self.buffs) do
            print(string.format("  Buff: %s", tostring(name)))
            print(string.format("    current_bonus = %s", tostring(buff.current_bonus)))
            print(string.format("    callbacks: onattached=%s, ondetached=%s, onupdated=%s",
                tostring(buff.onattachedfn ~= nil),
                tostring(buff.ondetachedfn ~= nil),
                tostring(buff.onupdatedfn ~= nil)))
            if next(buff.sources) == nil then
                print("    (no sources - should be detached this tick)")
            else
                for bonus, src in pairs(buff.sources) do
                    print(string.format("    source bonus=%s, timeleft=%.2f", tostring(bonus), src.timeleft))
                end
            end
        end
    end
    print("=========================================")
end

function UpgradeModuleBuff:GetDebugString()
    local auras_count = 0
    for _ in pairs(self.auras) do
		auras_count = auras_count + 1
	end
    local buffs_count = 0
    for _ in pairs(self.buffs) do
		buffs_count = buffs_count + 1
	end
    local active = self.task ~= nil and "ON" or "OFF"
    return string.format("UpgradeModuleBuff[%s] Auras:%d Buffs:%d %s", self.inst.prefab, auras_count, buffs_count, active)
end

return UpgradeModuleBuff