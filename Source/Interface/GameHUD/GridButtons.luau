local GridButtons = {}

-- Dependencies
local InterfaceUtilities = require(script.Parent.Parent.Utilities)

-- Constants
local Interface = InterfaceUtilities.get_screen_gui("Interface")
local GridButtonsFrame = Interface.HUD.ButtonGrid

--Functions
function GridButtons._shop_button_clicked()
	InterfaceUtilities.toggle_screen("GameShop")
end

function GridButtons._inventory_button_clicked()
	InterfaceUtilities.toggle_screen("VehicleInventory")
end

function GridButtons.init()
	GridButtonsFrame.ShopButton.MouseButton1Click:Connect(GridButtons._shop_button_clicked)
	GridButtonsFrame.InventoryButton.MouseButton1Click:Connect(GridButtons._inventory_button_clicked)
end

return GridButtons
