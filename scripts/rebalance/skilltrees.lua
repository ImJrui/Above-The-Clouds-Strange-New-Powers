local AddSimPostInit = AddSimPostInit
GLOBAL.setfenv(1, GLOBAL)

if not PL_CONFIG["ENABLE_SKYWORTHY"] then return end

local skilltreedefs = require("prefabs/skilltree_defs")
local DEBUG_REBUILD = skilltreedefs.DEBUG_REBUILD

local TGIdirty
if not TheGlobalInstance then
    TGIdirty = true
    TheGlobalInstance = CreateEntity("TheGlobalInstance")
end

DEBUG_REBUILD()
print("Skilltree rebuild complete")

if TGIdirty then
    TheGlobalInstance:Remove()
    TheGlobalInstance = nil
    TGIdirty = false
end

--------------------------------------------------------
local SkillTreeToast = require("widgets/skilltreetoast")
local ScrapbookToast = require("widgets/scrapbooktoast")

local down_pos = -200

-- Those two are the popup on top left corner of the HUD
function SkillTreeToast:UpdateElements()
    local from = self.root:GetPosition()

    if not self.controller_hide and not self.craft_hide and self.owner.player_classified and ThePlayer.new_skill_available_popup then 
        if not self.opened then
            self.controls:ManageToast(self)
            TheFrontEnd:GetSound():PlaySound("wilson_rework/ui/skillpoint_dropdown")
            self.opened = true
            local to = Vector3(0, down_pos, 0)

            -- We don't need to move if we're already in position
            if from ~= to then
                TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/Together_HUD/skin_drop_slide_gift_DOWN")
                self.root:MoveTo(from, to, 1.0,  function() self:EnableClick() end)
            end
        end
    elseif self.opened then
        self.opened = false
        local to = Vector3(0, 0, 0)
        self:DisableClick()
        if from ~= to then
            if self:IsVisible() then
                TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/Together_HUD/skin_drop_slide_gift_UP")
            end

            self.root:MoveTo(from, to, 0.5, function() self.controls:ManageToast(self,true) end)
        end
    end
    self:UpdateControllerHelp()
end

function ScrapbookToast:UpdateElements()
	if self.hasnewupdate and not (self.controller_hide or self.craft_hide) and self.shownotification then
		if not self.opened then
			self.controls:ManageToast(self)
			TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/scrapbook_dropdown")
			self.tab_gift:Show()
			self.opened = true
			self.tab_gift.animstate:PlayAnimation("pre")
		end
	elseif self.opened then
		self.tab_gift:Hide()
		self.controls:ManageToast(self, true)
		self.opened = false
    end
end

