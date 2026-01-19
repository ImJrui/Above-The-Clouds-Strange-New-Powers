local AddComponentPostInit = AddComponentPostInit
GLOBAL.setfenv(1, GLOBAL)

AddComponentPostInit("ambientsound", function(self, inst)
    if TheWorld:HasTag("porkland") then return end
    
    if TheNet:IsDedicated() then
        return
    end
    
    inst:DoTaskInTime(0.1, function()
        if not self.OnUpdate then
            return
        end
        
        local _OriginalOnUpdate = self.OnUpdate
        
        function self:OnUpdate(dt)
            local is_in_interior = false
            if ThePlayer and ThePlayer:IsValid() then
                if ThePlayer.GetIsInInterior then
                    is_in_interior = ThePlayer:GetIsInInterior()
                elseif ThePlayer:HasTag("inside_interior") then
                    is_in_interior = true
                elseif TheWorld.components and TheWorld.components.interiorspawner then
                    local x, _, z = ThePlayer.Transform:GetWorldPosition()
                    is_in_interior = TheWorld.components.interiorspawner:IsInInteriorRegion(x, z)
                end
            end
            
            _OriginalOnUpdate(self, dt)
            
            if is_in_interior then
                if inst.SoundEmitter then
                    inst.SoundEmitter:KillSound("waves")
                end
            end
        end
    end)
end) 