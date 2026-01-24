--[[
    @Title: Marketplace server manager
    @Author: Joseph (BreakLoop)
    @Description: Fetch product info via MarketplaceService and handle purchase rewards.
]]

local MarketplaceServer = {
	purchase_intent = {},
}

-- Dependancies
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local DataServiceServer = require(ServerScriptService.Services.DataService.DataServiceServer)
local ProductHandlersServer =
	require(ServerScriptService.Services.MarketplaceService.ProductHandlers.ProductHandlersServer)
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
function MarketplaceServer._grant_product(
	self: MarketplaceServer,
	player: Player,
	product_code: string,
	reciept_info: ReceiptInfo
)
	-- Fetch the product info
	local product_info = MarketplaceServiceShared.products[product_code]

	-- If the product does not exist, abort
	-- This should not happen unless this function is called independantly
	if not product_info then
		warn(`The product with code {product_code} could not be granted as it does not exist.`)
	end

	-- Check if product is a 1-time purchase
	-- If so, add the product to the player's data store.
	if product_info.purchase_type == MarketplaceServiceShared.product_types.single_purchase then
		DataServiceServer:apply_change(player, { "products_owned" }, function(current_products)
			table.insert(current_products, product_code)
			return current_products
		end)
	end

	-- Fetch the server handler for the product
	local purchase_actions = ProductHandlersServer[product_code]

	-- If a server handler exists, use it
	if purchase_actions and purchase_actions.on_recieved then
		purchase_actions.on_recieved(player)
		print(`Called server on_recieved for {player.Name}`)
	end

	-- Pass the purchase to the client
	print(`Passed product purchase to the client`)
	self.networker:fire(player, "product_purchased", product_code)
end

function MarketplaceServer._process_receipt(self: MarketplaceServer, reciept_info: ReceiptInfo)
	-- Get the player who purchased
	local player = Players:GetPlayerByUserId(reciept_info.PlayerId)

	-- Check if the player has left
	-- If they have, leave the reciept unprocessed. It will be processed when they rejoin.
	if not player then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	-- Get product code by product id
	local product_code = nil
	for code, product_data in MarketplaceServiceShared.products do
		if product_data.product_id == reciept_info.ProductId then
			product_code = code
			break
		end
	end

	-- Check if a product code was found
	if not product_code then
		warn(`Unknown product purchased with product id {reciept_info.ProductId}`)
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	-- Get purchase intent
	local intent_key = reciept_info.PlayerId + reciept_info.ProductId
	local intent = self.purchase_intent[intent_key]

	-- If the intent is to gift, then gift to the player stored in the intent
	if intent and intent.type == MarketplaceServiceShared.intent_types.gift then
		self:_grant_product(intent.recipient, product_code, reciept_info)
		self.purchase_intent[intent_key] = nil
	else
		self:_grant_product(player, product_code, reciept_info)
	end

	return Enum.ProductPurchaseDecision.PurchaseGranted
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
	self.networker = Networker.server.new("MarketplaceService", self, {
		self.prompt_purchase,
		self.prompt_gift_purchase,
	})
	MarketplaceService.ProcessReceipt = function(...)
		return self:_process_receipt(...)
	end
end

return MarketplaceServer
