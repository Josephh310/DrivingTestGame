local StarterPack = {}

-- Dependencies
local InterfaceUtils = require(script.Parent.Parent.Utilities)

-- Constants
local Interface = InterfaceUtils.get_screen_gui("Interface")
local StarterPackButton = Interface.HUD.StarterPackButton

-- Functions
function StarterPack.button_clicked()
	InterfaceUtils.toggle_screen("StarterPackPopup")
end

function StarterPack.init()
	StarterPackButton.MouseButton1Click:Connect(StarterPack.button_clicked)
end

return StarterPack
