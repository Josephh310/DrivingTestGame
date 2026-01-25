--[[
    @Title: Marketplace client manager
    @Author: Joseph (BreakLoop)
    @Description: Fetch products from server and handle purchases
]]

local MarketplaceClient = {
	products_loaded = false,
	product_cache = {},
}

-- Dependencies
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local MarketplaceServiceShared = require(script.Parent.MarketplaceServiceShared)
local Networker = require(ReplicatedStorage.Packages.Networker)
local Fireworks = require(ReplicatedStorage.Shared.Modules.Fireworks)
local ProductHandlersClient =
	require(ReplicatedStorage.Shared.Services.MarketplaceService.ProductHandlers.ProductHandlersClient)

-- Types
export type MarketplaceClient = typeof(MarketplaceClient)

-- Functions
function MarketplaceClient.get_product_data(self: MarketplaceClient, product_code: string)
	-- Wait for products to finish loading
	if not self.products_loaded then
		repeat
			task.wait()
		until self.products_loaded == true
	end

	-- Get product entry, check if it exists
	local product_entry = MarketplaceServiceShared.products[product_code]
	if not product_entry then
		warn(`{product_code} is not a valid product.`)
		return
	end

	-- Get product data from product cache
	local product_id = product_entry.product_id
	local product_data = self.product_cache[product_id]

	-- Check the data is valid
	if not product_data then
		warn(`Failed to fetch product information for product with code {product_code}`)
	end

	return product_data
end

function MarketplaceClient.process_purchase(
	self: MarketplaceClient,
	product_code: string,
	purchaser_id: number,
	reciever_id: number
)
	-- Get character root
	local player = Players.LocalPlayer
	local character = player.Character or player.CharacterAdded:Wait()
	local root = character.PrimaryPart

	-- Launch fireworks
	Fireworks.launch_fireworks(root.CFrame)

	-- Logic

	if purchaser_id == player.UserId then
		StarterGui:SetCore("SendNotification", {
			Title = `{(reciever_id == player.UserId and "Purchase") or "Gift"} Successful`,
			Text = "Thank you for your support!",
			Icon = "rbxassetid://16776729560",
		})
	end

	-- If the player is the reciever of the product ....
	if reciever_id == player.UserId then
		-- Get product information
		local product_info = MarketplaceServiceShared.products[product_code]
		local product_data = self:get_product_data(product_code)

		-- Send notification
		local is_gamepass = product_info.purchase_type == MarketplaceServiceShared.product_types.single_purchase

		StarterGui:SetCore("SendNotification", {
			Title = "Notification",
			Text = `You've recieved {(is_gamepass and "the " .. product_data.Name .. " gamepass.") or product_data.Name}`,
			Icon = `rbxassetid://{product_data.IconImageAssetId}`,
		})

		-- Apply product effects
		-- Get client handlers
		local handlers = ProductHandlersClient[product_code]

		-- If a client handler exists for the product, call it
		if handlers and handlers.on_recieved then
			handlers.on_recieved()
		end
	end
end

function MarketplaceClient.purchase_product(self: MarketplaceClient, product_code: string)
	local success, response = self.networker:fetch("prompt_purchase", product_code)
	if not success then
		StarterGui:SetCore("SendNotification", {
			Title = "Error",
			Text = response,
			Icon = "rbxassetid://15121391092",
		})
	end
end

function MarketplaceClient.gift_product(self: MarketplaceClient, product_code: string, recipient: Player)
	if not recipient then
		return
	end
	local success, response = self.networker:fetch("prompt_gift_purchase", recipient, product_code)
	if not success then
		StarterGui:SetCore("SendNotification", {
			Title = "Error",
			Text = response,
			Icon = "rbxassetid://15121391092",
		})
	end
end

function MarketplaceClient.init(self: MarketplaceClient)
	-- Initialise networker
	self.networker = Networker.client.new("MarketplaceService", self)

	-- Load all developer products into product_cache
	task.defer(function()
		-- Get a pages object containing all developer products
		local products = MarketplaceService:GetDeveloperProductsAsync()

		-- Cycle through the product pages
		repeat
			local page_info = products:GetCurrentPage()

			-- Cycle through all products on the page and cache the data
			for index, product_data in page_info do
				self.product_cache[product_data.ProductId] = product_data
			end

			-- If there are pages remaining, continue to the next page
			if not products.IsFinished then
				products:AdvanceToNextPageAsync()
			end
		until products.IsFinished == true

		-- Flag products as loaded
		self.products_loaded = true
	end)
end

return MarketplaceClient
