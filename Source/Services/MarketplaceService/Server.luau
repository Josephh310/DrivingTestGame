--[[
    @Title: Marketplace server manager
    @Author: Joseph (BreakLoop)
    @Description: Fetch product info via MarketplaceService and handle purchase rewards.
]]

local MarketplaceServer = {
}

-- Dependancies
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local DataServiceServer = require(ServerScriptService.Services.DataService.DataServiceServer)
local Networker = require(ReplicatedStorage.Packages.Networker)
local MarketplaceServiceShared = require(ReplicatedStorage.Shared.Services.MarketplaceService.MarketplaceServiceShared)

-- Types
export type MarketplaceServer = typeof(MarketplaceServer)
export type ReceiptInfo = {
	PlayerId: number,
	PlaceIdWherePurchased: number,
	PurchaseId: string,
	ProductId: number,
	CurrencyType: Enum.CurrencyType,
	CurrencySpent: number,
}

-- Functions
end

function MarketplaceServer.prompt_purchase(self: MarketplaceServer, player: Player, product_code: string)
	-- Check for the product data, reject the request if it doesn't exist
	local product_data = MarketplaceServiceShared.products[product_code]
	if not product_data then
		warn(`No product data exists for product with code {product_code}`)
		return false, MarketplaceServiceShared.error_codes.product_not_found
	end

	-- Check if the product is already owned
	-- If it's still a one-time purchase, reject the request
	if product_data.purchase_type == MarketplaceServiceShared.product_types.single_purchase then
		local owned_passes = DataServiceServer:get_value(player, { "products_owned" })
		if table.find(owned_passes, product_code) then
			warn(`Product with code {product_code} is already owned and is a one-time purchase.`)
			return false, MarketplaceServiceShared.error_codes.already_owned
		end
	end

	-- Prompt the purchase
	local success, err = pcall(function()
		MarketplaceService:PromptProductPurchase(player, product_data.product_id)
	end)

	if not success then
		warn(`Failed to prompt purchase: {err}`)
		return false, MarketplaceServiceShared.error_codes.marketplace_service_down
	end

	print(`Prompted {player.Name} to buy {product_code}`)
	return true, nil
end

function MarketplaceServer.prompt_gift_purchase(
	self: MarketplaceServer,
	gifter: Player,
	recipient_id: number,
	product_code: string
)
	-- Check the gifter is not gifting to themselves. If so, abort.
	if gifter.UserId == recipient_id then
		return false, MarketplaceServiceShared.error_codes.cannot_gift_to_self
	end

	-- Get the product data and check it exists. If not. abort
	local product_data = MarketplaceServiceShared.products[product_code]
	if not product_data then
		return false, MarketplaceServiceShared.error_codes.product_not_found
	end

	-- Get the recipient's player. If they're not in the same server, abort.
	local recipient = Players:GetPlayerByUserId(recipient_id)
	if not recipient then
		return false, MarketplaceServiceShared.error_codes.invalid_recipient
	end

	-- Check if it is a one-time purchase
	-- If so, ensure that the recipient doesn't already own the gamepass
	if product_data.purchase_type == MarketplaceServiceShared.product_types.single_purchase then
		local products_owned = DataServiceServer:get_value(recipient, { "products_owned" })
		if table.find(products_owned, product_code) then
			return false, MarketplaceServiceShared.error_codes.recipient_owns_product
		end
	end

	-- Prompt the purchase
	local success, err = pcall(function()
		return MarketplaceService:PromptProductPurchase(
			gifter,
			product_data.product_id,
			false,
			Enum.CurrencyType.Robux,
			recipient_id
		)
	end)

	if not success then
		warn(`Failed to prompt gift purchase: {err}`)
		return MarketplaceServiceShared.error_codes.marketplace_service_down
	end

	-- Add purchase intent
	self.purchase_intent[gifter.UserId + product_data.product_id] = {
		type = MarketplaceServiceShared.intent_types.gift,
		recipient = recipient,
	}

	print(`Prompted {gifter.Name} to buy {product_code} for {recipient.Name}`)
	return true, nil
end

function MarketplaceServer.init(self: MarketplaceServer)
	self.networker = Networker.server.new("MarketplaceService", self, {})
end

return MarketplaceServer
