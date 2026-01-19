local AddComponentPostInit = AddComponentPostInit
GLOBAL.setfenv(1, GLOBAL)

AddComponentPostInit("weather", function(self, inst)
    if TheWorld:HasTag("porkland") then return end
    
    if not TheWorld.ismastersim then
        return
    end

    local OnSendLightningStrike_base = inst:GetEventCallbacks("ms_sendlightningstrike", TheWorld, "scripts/components/weather.lua")

    if not OnSendLightningStrike_base then
        return
    end
    
    local LIGHTNINGSTRIKE_CANT_TAGS = ToolUtil.GetUpvalue(OnSendLightningStrike_base, "LIGHTNINGSTRIKE_CANT_TAGS")
    local LIGHTNINGSTRIKE_ONEOF_TAGS = ToolUtil.GetUpvalue(OnSendLightningStrike_base, "LIGHTNINGSTRIKE_ONEOF_TAGS")
    local LIGHTNINGSTRIKE_SEARCH_RANGE = ToolUtil.GetUpvalue(OnSendLightningStrike_base, "LIGHTNINGSTRIKE_SEARCH_RANGE")

    inst:RemoveEventCallback("ms_sendlightningstrike", OnSendLightningStrike_base, TheWorld)

    local function OnSendLightningStrike_New(src, pos)
        local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, LIGHTNINGSTRIKE_SEARCH_RANGE, nil, LIGHTNINGSTRIKE_CANT_TAGS, LIGHTNINGSTRIKE_ONEOF_TAGS)
        for _, v in pairs(ents) do
            if v:GetIsInInterior() then
                SpawnPrefab("thunder").Transform:SetPosition(pos:Get())
                return
            end
        end

        return OnSendLightningStrike_base(src, pos)
    end
    
    inst:ListenForEvent("ms_sendlightningstrike", OnSendLightningStrike_New, TheWorld)
end) 

AddComponentPostInit("weather", function(self, inst)
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
            
            local removed_umbrella_tags = {}
            if is_in_interior and ThePlayer and ThePlayer.replica and ThePlayer.replica.inventory then
                local hand_umbrella = ThePlayer.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
                if hand_umbrella and hand_umbrella:HasTag("umbrella") then
                    hand_umbrella:RemoveTag("umbrella")
                    removed_umbrella_tags.hands = hand_umbrella
                end
                
                local head_umbrella = ThePlayer.replica.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
                if head_umbrella and head_umbrella:HasTag("umbrella") then
                    head_umbrella:RemoveTag("umbrella")
                    removed_umbrella_tags.head = head_umbrella
                end
            end
            
            _OriginalOnUpdate(self, dt)
            
            if next(removed_umbrella_tags) and ThePlayer and ThePlayer.replica and ThePlayer.replica.inventory then
                if removed_umbrella_tags.hands then
                    local hand_umbrella = ThePlayer.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
                    if hand_umbrella and not hand_umbrella:HasTag("umbrella") then
                        hand_umbrella:AddTag("umbrella")
                    end
                end
                
                if removed_umbrella_tags.head then
                    local head_umbrella = ThePlayer.replica.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
                    if head_umbrella and not head_umbrella:HasTag("umbrella") then
                        head_umbrella:AddTag("umbrella")
                    end
                end
            end
        end
    end)
end) 