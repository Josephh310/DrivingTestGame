local ColorCustomise = {}

-- Dependencies
local InterfaceUtils = require(script.Parent.Parent.Utilities)

-- Constants
local Interface = InterfaceUtils.get_screen_gui("Interface")
local ColorCustomiseFrame = Interface.Screens.ColorCustomise
local FrameCloseButton = ColorCustomiseFrame.Topbar.Close

-- Functions
function ColorCustomise.hide()
	ColorCustomiseFrame.Visible = false
end

function ColorCustomise.show()
	ColorCustomiseFrame.Visible = true
end

function ColorCustomise._close_button_clicked()
	InterfaceUtils.toggle_screen("ColorCustomise")
end

function ColorCustomise.init()
	FrameCloseButton.MouseButton1Click:Connect(ColorCustomise._close_button_clicked)
end

return ColorCustomise
