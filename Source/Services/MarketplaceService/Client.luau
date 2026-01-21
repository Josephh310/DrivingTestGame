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
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceServiceShared = require(script.Parent.MarketplaceServiceShared)
local Networker = require(ReplicatedStorage.Packages.Networker)

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
