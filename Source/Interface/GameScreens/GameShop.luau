local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameShop = {}

-- Dependencies
local MarketplaceServiceClient = require(ReplicatedStorage.Shared.Services.MarketplaceService.MarketplaceServiceClient)
local InterfaceUtils = require(script.Parent.Parent.Utilities)

-- Constants
local Interface = InterfaceUtils.get_screen_gui("Interface")
local GameShopFrame = Interface.Screens.GameShop
local GameShopContent = GameShopFrame.Shop.ScrollingFrame
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
	-- TODO

	-- Get product information
	local starter_pack_info = MarketplaceServiceClient:get_product_data("starter_pack")
	local exclusive_vehicles_info = MarketplaceServiceClient:get_product_data("exclusive_vehicles")
	local plate_customisation_info = MarketplaceServiceClient:get_product_data("plate_customisation")
	local speed_boost_info = MarketplaceServiceClient:get_product_data("speed_boost")
	local color_customisation = MarketplaceServiceClient:get_product_data("color_customisation")
	local skip_1_info = MarketplaceServiceClient:get_product_data("skip_1")
	local skip_5_info = MarketplaceServiceClient:get_product_data("skip_5")
	local skip_10_info = MarketplaceServiceClient:get_product_data("skip_10")
	local skip_30_info = MarketplaceServiceClient:get_product_data("skip_30")

	-- Exclusive vehicles
	GameShopContent.Passes.ExclusiveVehicle.Buttons.BuyWithRobux.Price.Text = exclusive_vehicles_info.PriceInRobux

	-- Plate customisation
	GameShopContent.Passes.PlateCustomise.Buttons.BuyWithRobux.Price.Text = plate_customisation_info.PriceInRobux

	-- Speed boost
	GameShopContent.Passes.SpeedBoost.Buttons.BuyWithRobux.Price.Text = speed_boost_info.PriceInRobux

	-- Color customisation
	GameShopContent.Passes.ColorCustomise.Buttons.BuyWithRobux.Price.Text = color_customisation.PriceInRobux

	-- Skip 1
	GameShopContent.Skips.Content.Buttons.Skip1.BuyWithRobux.Price.Text = skip_1_info.PriceInRobux

	-- Skip 5
	GameShopContent.Skips.Content.Buttons.Skip5.BuyWithRobux.Price.Text = skip_5_info.PriceInRobux

	-- Skip 10
	GameShopContent.Skips.Content.Buttons.Skip10.BuyWithRobux.Price.Text = skip_10_info.PriceInRobux

	-- Skip 30
	GameShopContent.Skips.Content.Buttons.Skip30.BuyWithRobux.Price.Text = skip_30_info.PriceInRobux

	-- Button connections
	FrameCloseButton.MouseButton1Click:Connect(GameShop._close_button_clicked)
end

return GameShop
