local StarterPack = {}

-- Dependancies
local InterfaceUtilities = require(script.Parent.Parent.Utilities)

-- Constants
local Interface = InterfaceUtilities.get_screen_gui("Interface")
local StarterPackFrame = Interface.Screens.StarterPackPopup

-- Functions
function StarterPack.hide()
	StarterPackFrame.Visible = false
end

function StarterPack.show()
	StarterPackFrame.Visible = true
end

function StarterPack.init()
	StarterPack.hide_ui_when_open = false
end

return StarterPack
