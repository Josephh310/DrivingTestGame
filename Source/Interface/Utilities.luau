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
function InterfaceUtilities.multiply_udim_2(_udim: UDim2, multiplier: number)
	return UDim2.new(
		_udim.X.Scale * multiplier,
		_udim.X.Offset * multiplier,
		_udim.Y.Scale * multiplier,
		_udim.Y.Offset * multiplier
	)
end

function InterfaceUtilities.format_with_commas(num: number)
	local formatted = tostring(num)
	while true do
		local updated, count = formatted:gsub("^(-?%d+)(%d%d%d)", "%1,%2")
		formatted = updated
		if count == 0 then
			break
		end
	end
	return formatted
end

function InterfaceUtilities.get_element_color_property(element: GuiObject)
	if element:IsA("ImageLabel") or element:IsA("ImageButton") then
		return "ImageColor3"
	end
	return "BackgroundColor3"
end

function InterfaceUtilities.multiply_color3(_color3: Color3, multiplier: number)
	return Color3.new(_color3.R * multiplier, _color3.G * multiplier, _color3.B * multiplier)
end

function InterfaceUtilities.get_screen_gui(name: string)
	return player_gui:WaitForChild(name)
end

function InterfaceUtilities.hide_all_screens()
	for screen_name, screen_data in Interface.GameScreens do
		if screen_data.screen_active then
			screen_data.hide()
			screen_data.screen_active = false
		end
	end
end

function InterfaceUtilities.toggle_overlapping_ui(state: boolean)
	if state == true then
		Interface.GameHUD.Topbar.show()
	else
		Interface.GameHUD.Topbar.hide()
	end
end

function InterfaceUtilities.toggle_screen(name: string, ...)
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
		if screen_data.hide_ui_when_open ~= false then
			InterfaceUtilities.toggle_overlapping_ui(false)
		end
		InterfaceUtilities.hide_all_screens()
		screen_data.show(...)
		screen_data.screen_active = true
	else
		if not screen_data.hide then
			warn("Screen data for " .. name .. " does not have a 'hide' function")
			return
		end
		InterfaceUtilities.toggle_overlapping_ui(true)
		screen_data.hide(...)
		screen_data.screen_active = false
	end
end

return InterfaceUtilities
