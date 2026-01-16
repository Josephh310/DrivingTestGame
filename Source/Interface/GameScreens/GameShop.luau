local GameShop = {}

-- Dependencies
local InterfaceUtils = require(script.Parent.Parent.Utilities)

-- Constants
local Interface = InterfaceUtils.get_screen_gui("Interface")
local GameShopFrame = Interface.Screens.GameShop
local FrameCloseButton = GameShopFrame.Topbar.Close

-- Functions
function GameShop.hide()
	GameShopFrame.Visible = false
end

function GameShop.show()
	GameShopFrame.Visible = true
end

function GameShop._close_button_clicked()
	InterfaceUtils.toggle_screen("GameShop")
end

function GameShop.init()
	FrameCloseButton.MouseButton1Click:Connect(GameShop._close_button_clicked)
end

return GameShop
