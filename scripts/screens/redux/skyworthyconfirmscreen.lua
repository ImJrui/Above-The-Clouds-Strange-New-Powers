local PopupDialogScreen = require("screens/redux/popupdialog")

local function BuildButtons(buttons_data)
	local buttons = {}
	for _,data in pairs(buttons_data) do
		table.insert(buttons, {
			text = data.text,
			cb = function()
				if data.cb then
					SendModRPCToServer(GetModRPC("porkland", "ConfirmSkyWorthy"), data.cb)
				end
				TheFrontEnd:PopScreen()
			end,
			control = data.control,
		})
	end

	return buttons
end

-- riftworthyconfirmscreen.lua
local SkyworthyConfirmScreen = Class(PopupDialogScreen, function(self, owner, title, text, buttons)
	local buttons = BuildButtons(DecodeAndUnzipString(buttons))
	PopupDialogScreen._ctor(self, title, text, buttons, nil, nil, nil)

	self.owner = owner
	self.controldown = {}
	self.tick0 = GetStaticTick()

	SetAutopaused(true)
end)

function SkyworthyConfirmScreen:OnDestroy()
	SetAutopaused(false)
	POPUPS.SKYWORTHY:Close(self.owner)
	self._base.OnDestroy(self)
end

function SkyworthyConfirmScreen:OnControl(control, down)
	--NOTE: PopupDialogScreen's base, not our own base (which would just be PopupDialogScreen)
	if PopupDialogScreen._base.OnControl(self, control, down) then return true end

	--Only handle control up if the down was also tracked by us.
	--Otherwise, controllers may open this dialog with (B) down,
	--only to have it instantly cancel itself on (B) up.
	if down then
		if GetStaticTick() - self.tick0 > 1 then
			self.controldown[control] = true
		end
		return false
	elseif not self.controldown[control] then
		return true
	else
		self.controldown[control] = nil
		return self.oncontrol_fn(control, down)
	end
end

return SkyworthyConfirmScreen
