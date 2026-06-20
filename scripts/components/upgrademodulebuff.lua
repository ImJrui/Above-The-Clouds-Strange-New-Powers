local duration = 1

local UpgradeModuleBuff = Class(function(self, inst)
    self.inst = inst

	self.buffers = {}
	self.buffs = {}

	self.task = nil
	self.freq = 0.5

	self.inst:ListenForEvent("death", function() self:Disable() end)
	self.inst:ListenForEvent("onremove", function() self:Disable() end)
end)

function UpgradeModuleBuff:OnUpdate()
	for buffname, data in pairs(self.buffers) do
		self:AttachToTargets(buffname, data)
	end

	for buffname, data in pairs(self.buffs) do
		self:DoDelta(buffname, self.freq)
	end

	if next(self.buffers) == nil and next(self.buffs) == nil then
		self:Disable()
		self.inst:RemoveComponent("upgrademodulebuff")
	end
end

function UpgradeModuleBuff:SetBuffer(buffname, data)
	self.buffers[buffname] = data
	self:Enable()
end

function UpgradeModuleBuff:UpdateBuffer(buffname, data)
	for k, v in pairs(data) do
		if self.buffers[buffname] then
			self.buffers[buffname][k] = v
		end
	end
end

function UpgradeModuleBuff:RemoveBuffer(buffname)
	self.buffers[buffname] = nil
end

function UpgradeModuleBuff:RemoveAllBuffers()
	for buffname in pairs(self.buffers) do
		self.buffers[buffname] = nil
	end
end

function UpgradeModuleBuff:AttachToTargets(buffname, data)
	local x, y, z = self.inst.Transform:GetWorldPosition()
	local players = not TheNet:GetPVPEnabled() and FindPlayersInRange(x, y, z, data.radius, true) or {}
	for i = 1, #players do
		local player = players[i]
		if player and player:IsValid() and not player:HasTag("playerghost") then
			if not player.components.upgrademodulebuff then
				player:AddComponent("upgrademodulebuff")
			end
			if player.components.upgrademodulebuff.buffs[buffname] == nil then
				player.components.upgrademodulebuff:Attach(buffname, data)
			else
				player.components.upgrademodulebuff:Extend(buffname)
			end
		end
	end
end

function UpgradeModuleBuff:DoDelta(buffname, delta)
	if self.buffs[buffname] then
		self.buffs[buffname].timeleft = self.buffs[buffname].timeleft - delta
		if self.buffs[buffname].timeleft <= 0 then
			self:OnDetach(buffname)
		end
	end
end

function UpgradeModuleBuff:Attach(buffname, data)
	self.buffs[buffname] = {
		timeleft = duration,
		onattachedfn = data.onattachedfn,
		ondetachedfn = data.ondetachedfn,
	}
	if data.onattachedfn then
		data.onattachedfn(self.inst)
	end
	self:Enable()
end

function UpgradeModuleBuff:Extend(buffname)
	self.buffs[buffname]["timeleft"] = duration
end

function UpgradeModuleBuff:OnDetach(buffname)
	if self.buffs[buffname] then
		self.buffs[buffname].ondetachedfn(self.inst)
	end
	self.buffs[buffname] = nil
end

function UpgradeModuleBuff:RemoveAllBuffs()
	for buffname in pairs(self.buffs) do
		self:OnDetach(buffname)
	end
	self.buffs = {}
end

function UpgradeModuleBuff:Enable()
	if self.task == nil then
		self.task = self.inst:DoPeriodicTask(self.freq, function() self:OnUpdate() end)
	end
end

function UpgradeModuleBuff:Disable()
	if self.task ~= nil then
		self.task:Cancel()
		self.task = nil
	end

	self:RemoveAllBuffers()
	self:RemoveAllBuffs()
end

function UpgradeModuleBuff:OnSave()
    return nil
end

function UpgradeModuleBuff:OnLoad(data)
end

return UpgradeModuleBuff
