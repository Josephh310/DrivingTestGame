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
local CoreGui = game:GetService("CoreGui")
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

function MarketplaceClient.product_purchased(self: MarketplaceClient, product_code: string)
	-- Get character root
	local player = Players.LocalPlayer
	local character = player.Character or player.CharacterAdded:Wait()
	local root = character.PrimaryPart

	-- Get client handlers
	local handlers = ProductHandlersClient[product_code]

	-- Launch fireworks
	Fireworks.launch_fireworks(root.CFrame)

	-- Send notification
	StarterGui:SetCore("SendNotification", {
		Title = "Success",
		Text = "Thank you for your support!",
		Icon = "rbxassetid://2022095751",
	})

	-- Call the product's on_recieved handler
	if handlers and handlers.on_recieved then
		handlers.on_recieved()
	end
end

function MarketplaceClient.purchase_product(self: MarketplaceClient, product_code: string)
	local success, response = self.networker:fetch("prompt_purchase", product_code)
	if not success then
		StarterGui:SetCore("SendNotification", {
			Title = "Error",
			Text = response,
			Icon = "rbxassetid://2022095316",
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
			Icon = "rbxassetid://2022095316",
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
