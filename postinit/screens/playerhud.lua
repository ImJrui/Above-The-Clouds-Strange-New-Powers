local PlayerHud = require("screens/playerhud")
local SkyworthyConfirmScreen = require("screens/redux/skyworthyconfirmscreen")

-- PlayerHud:OpenBalatroScreen(target, jokers, cards)
function PlayerHud:OpenSkyworthyScreen(title, text, buttons)
    self:CloseSkyworthyScreen()
    self.skyworthyconfirmscreen = SkyworthyConfirmScreen(self.owner, title, text, buttons)
    self:OpenScreenUnderPause(self.skyworthyconfirmscreen)
    return true
end

function PlayerHud:CloseSkyworthyScreen()
    if self.skyworthyconfirmscreen ~= nil then
        if self.skyworthyconfirmscreen.inst:IsValid() then
            TheFrontEnd:PopScreen(self.skyworthyconfirmscreen)
		end
        self.skyworthyconfirmscreen = nil
    end
end