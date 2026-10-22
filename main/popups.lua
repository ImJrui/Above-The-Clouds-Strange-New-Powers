

require("popupmanager")

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