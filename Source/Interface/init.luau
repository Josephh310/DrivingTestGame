--[[
    @Title: Client interface handler
    @Author: Joseph (BreakLoop)
    @Description: Initialize and control client UI
]]

local InterfaceController = {
	GameScreens = {},
	GameHUD = {},
}

-- Dependancies
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Observers = require(ReplicatedStorage.Packages.Observers)

-- Types
export type InterfaceController = typeof(InterfaceController)

-- Functions
function InterfaceController.init(self: InterfaceController)
	-- Load and cache game HUD
	for _, module in script.GameHUD:GetChildren() do
		if not module:IsA("ModuleScript") then
			continue
		end
		self.GameHUD[module.Name] = require(module)
		self.GameHUD[module.Name].init()
	end

	-- Load and cache game screens
	for _, module in script.GameScreens:GetChildren() do
		if not module:IsA("ModuleScript") then
			continue
		end
		self.GameScreens[module.Name] = require(module)
		self.GameScreens[module.Name].init()
	end

	-- Load UI components
	for _, component_module in script.Components:GetChildren() do
		local component_observer = require(component_module)
		Observers.observeTag(component_module.Name, component_observer)
	end
end

return InterfaceController
