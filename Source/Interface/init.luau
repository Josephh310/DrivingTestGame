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

return InterfaceController
