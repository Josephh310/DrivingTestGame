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

function InterfaceUtilities.hide_all_screens()
	for screen_name, screen_data in Interface.GameScreens do
		if screen_data.screen_active then
			screen_data.hide()
			screen_data.screen_active = false
		end
	end
end

function InterfaceUtilities.toggle_screen(name: string)
	local screen_data = Interface.GameScreens[name]
	if not screen_data then
		warn("Could not find screen data for screen " .. name)
		return
	end
	if not screen_data.screen_active then
		if not screen_data.show then
			warn("Screen data for " .. name .. " does not have a 'show' function")
			return
		end
		InterfaceUtilities.hide_all_screens()
		screen_data.show()
		screen_data.screen_active = true
	else
		if not screen_data.hide then
			warn("Screen data for " .. name .. " does not have a 'hide' function")
			return
		end
		screen_data.hide()
		screen_data.screen_active = false
	end
end

return InterfaceUtilities
