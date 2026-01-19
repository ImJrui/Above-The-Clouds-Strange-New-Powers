

require("popupmanager")

-- POPUPS.BALATRO.fn = function(inst, show, target, joker1, joker2, joker3, card1, card2, card3, card4, card5)
local skyworthy_popup = GLOBAL.PopupManagerWidget()
skyworthy_popup.id = "SKYWORTHY"
skyworthy_popup.fn = function(inst, show, title, text, buttons)
    if inst.HUD then
        if not show then
            inst.HUD:CloseSkyworthyScreen()
        elseif not inst.HUD:OpenSkyworthyScreen(title, text, buttons) then
            POPUPS.SKYWORTHY:Close(inst)
        end
    end
end
AddPopup(skyworthy_popup)