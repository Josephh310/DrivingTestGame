--[[
    @Title: Utilities for game UI 
    @Author: BreakLoop
]]

local InterfaceUtilities = {}

-- Dependencies
local Players = game:GetService("Players")
local Interface = require(script.Parent)

-- Constants
local player = Players.LocalPlayer
local player_gui = player.PlayerGui

-- Functions
function InterfaceUtilities.get_screen_gui(name: string)
	return player_gui:FindFirstChild(name)
end
return InterfaceUtilities
