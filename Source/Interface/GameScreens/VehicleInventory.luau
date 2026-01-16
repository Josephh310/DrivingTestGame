local VehicleInventory = {}

-- Dependencies
local InterfaceUtils = require(script.Parent.Parent.Utilities)

-- Constants
local Interface = InterfaceUtils.get_screen_gui("Interface")
local VehicleInventoryFrame = Interface.Screens.VehicleInventory
local FrameCloseButton = VehicleInventoryFrame.Topbar.Close

-- Functions
function VehicleInventory.hide()
	VehicleInventoryFrame.Visible = false
end

function VehicleInventory.show()
	VehicleInventoryFrame.Visible = true
end

function VehicleInventory._close_button_clicked()
	InterfaceUtils.toggle_screen("VehicleInventory")
end

function VehicleInventory.init()
	FrameCloseButton.MouseButton1Click:Connect(VehicleInventory._close_button_clicked)
end

return VehicleInventory
