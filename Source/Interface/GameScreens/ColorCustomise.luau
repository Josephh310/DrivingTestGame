local ColorCustomise = {}

-- Dependencies
local InterfaceUtils = require(script.Parent.Parent.Utilities)

-- Constants
local Interface = InterfaceUtils.get_screen_gui("Interface")
local ColorCustomiseFrame = Interface.Screens.ColorCustomise
local ColorWheelFrame = ColorCustomiseFrame.Selection.ColorWheel
local BrightnessFrame = ColorCustomiseFrame.Selection.BrightnessBar
local ColorSelector = ColorWheelFrame.Selector
local BrightnessSelector = BrightnessFrame.Selector
local FrameCloseButton = ColorCustomiseFrame.Topbar.Close

-- Functions
function ColorCustomise.hide()
	ColorCustomiseFrame.Visible = false
end

function ColorCustomise.show()
	ColorCustomiseFrame.Visible = true
end

function ColorCustomise._close_button_clicked()
	InterfaceUtils.toggle_screen("ColorCustomise")
end

local last_position = nil
function ColorCustomise._limit_color_selector(current_position: UDim2)
	local circle_radius = 0.5
	local x_position = current_position.X.Scale - 0.5
	local y_position = current_position.Y.Scale - 0.5
	local offset = math.sqrt(x_position ^ 2 + y_position ^ 2)
	if offset <= circle_radius then
		last_position = current_position
		return current_position
	else
		return last_position
	end
end

function ColorCustomise.init()
	-- Create drag detector for the color selector
	local color_drag_detector = Instance.new("UIDragDetector")
	color_drag_detector.ResponseStyle = Enum.UIDragDetectorResponseStyle.Scale
	color_drag_detector.Parent = ColorSelector
	color_drag_detector:AddConstraintFunction(1, ColorCustomise._limit_color_selector)

	-- Create drag detector for the brightness selector
	local brightness_drag_detector = Instance.new("UIDragDetector")
	brightness_drag_detector.DragStyle = Enum.UIDragDetectorDragStyle.TranslateLine
	brightness_drag_detector.DragAxis = Vector2.new(0, 1)
	brightness_drag_detector.BoundingUI = BrightnessFrame
	brightness_drag_detector.Parent = BrightnessSelector

	-- Button connections
	FrameCloseButton.MouseButton1Click:Connect(ColorCustomise._close_button_clicked)
end

return ColorCustomise
