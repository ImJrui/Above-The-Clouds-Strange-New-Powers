GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------
local HerdMember = require("components/herdmember")

local _CreateHerd = HerdMember.CreateHerd
function HerdMember:CreateHerd()
    if not self.inst:IsValid() then
        return
    end
    _CreateHerd(self)
end