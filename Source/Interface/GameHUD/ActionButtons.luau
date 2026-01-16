local ActionButtons = {}

-- Dependencies
local InterfaceUtilities = require(script.Parent.Parent.Utilities)

-- Constants
local Interface = InterfaceUtilities.get_screen_gui("Interface")
local ActionButtonsFrame = Interface.HUD.ActionButtons

--Functions
function ActionButtons._reset_vehicle_clicked()
	print("Reset vehicle clicked")
end

function ActionButtons._troll_clicked()
	-- Toggle troll shop
	InterfaceUtilities.toggle_screen("TrollShop")
end

function ActionButtons.init()
	ActionButtonsFrame.ResetVehicle.MouseButton1Click:Connect(ActionButtons._reset_vehicle_clicked)
	ActionButtonsFrame.TrollButton.MouseButton1Click:Connect(ActionButtons._troll_clicked)
end

return ActionButtons
