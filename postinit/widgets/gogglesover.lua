local AddClassPostConstruct = AddClassPostConstruct
GLOBAL.setfenv(1, GLOBAL)

-- Keep the storm overlays attached to GogglesOver visible; only hide the goggles frame.
AddClassPostConstruct("widgets/gogglesover", function(self)
    if not self.owner then
        return
    end

    local function UpdateGogglesFrame(player)
        if player._plrebalance_ironlord_previous_forcegogglevision ~= nil then
            self.bg:Hide()
        else
            self.bg:Show()
        end
    end

    self.inst:ListenForEvent("plrebalance_ironlordgogglevision", UpdateGogglesFrame, self.owner)
    UpdateGogglesFrame(self.owner)
end)

