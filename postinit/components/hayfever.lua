GLOBAL.setfenv(1, GLOBAL)

local Hayfever = require("components/hayfever")

local _CanSneeze = Hayfever.CanSneeze
function Hayfever:CanSneeze()
    if self.inst:HasTag("immunehayfever") then
        return false
    end
    return _CanSneeze(self)
end
