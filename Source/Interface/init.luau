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
local StarterGui = game:GetService("StarterGui")
local Observers = require(ReplicatedStorage.Packages.Observers)

-- Types
export type InterfaceController = typeof(InterfaceController)

-- Functions
function InterfaceController._set_coregui_rules(self: InterfaceController, state: boolean)
	repeat
		local success = pcall(function()
			StarterGui:SetCore("ResetButtonCallback", state)
			StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)
		end)
		task.wait()
	until success
end

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

	-- Disable reset button
	self:_set_coregui_rules(false)
end

return InterfaceController
