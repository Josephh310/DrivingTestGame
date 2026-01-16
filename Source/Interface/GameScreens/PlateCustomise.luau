local PlateCustomise = {}

-- Dependencies
local InterfaceUtils = require(script.Parent.Parent.Utilities)

-- Constants
local Interface = InterfaceUtils.get_screen_gui("Interface")
local PlateCustomiseFrame = Interface.Screens.PlateCustomise
local FrameCloseButton = PlateCustomiseFrame.Topbar.Close

-- Functions
function PlateCustomise.hide()
	PlateCustomiseFrame.Visible = false
end

function PlateCustomise.show()
	PlateCustomiseFrame.Visible = true
end

function PlateCustomise._close_button_clicked()
	InterfaceUtils.toggle_screen("PlateCustomise")
end

function PlateCustomise.init()
	FrameCloseButton.MouseButton1Click:Connect(PlateCustomise._close_button_clicked)
end

return PlateCustomise
