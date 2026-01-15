--[[
    @Title: Client interface handler
    @Author: Joseph (BreakLoop)
    @Description: Initialize and control client UI
]]

local InterfaceController = {}

-- Dependancies
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Observers = require(ReplicatedStorage.Packages.Observers)

-- Types
export type InterfaceController = typeof(InterfaceController)

function InterfaceController.init(self: InterfaceController) end
-- Functions
function InterfaceController.init(self: InterfaceController)
	-- Load UI modules
	require(script.GameHUD.ActionButtons).init()
	require(script.GameHUD.CustomTopbar).init()
	require(script.GameHUD.GridButtons).init()
	require(script.GameHUD.StarterPack).init()
	require(script.GameHUD.TopbarPlus).init()
	require(script.GameScreens.ColorCustomise).init()
	require(script.GameScreens.GameShop).init()
	require(script.GameScreens.PlateCustomise).init()
	require(script.GameScreens.StarterPackPopup).init()
	require(script.GameScreens.TrollShop).init()
	require(script.GameScreens.VehicleInventory).init()
end

return InterfaceController
