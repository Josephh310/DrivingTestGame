local Topbar = {}

-- Dependencies
local TweenService = game:GetService("TweenService")
local InterfaceUtils = require(script.Parent.Parent.Utilities)

-- Constants
local Interface = InterfaceUtils.get_screen_gui("Interface")
local TopbarFrame = Interface.HUD.Topbar
local HideTween = TweenService:Create(
	TopbarFrame,
	TweenInfo.new(0.25),
	{ Position = UDim2.fromScale(TopbarFrame.Position.X.Scale, -0.5) }
)
local ShowTween = TweenService:Create(
	TopbarFrame,
	TweenInfo.new(0.25),
	{ Position = UDim2.fromScale(TopbarFrame.Position.X.Scale, 0.01) }
)

-- Functions
function Topbar._update_current_stage(new_value: number)
	local stage_formatted = string.format("%02d", new_value)
	TopbarFrame.StageIndicator.StageLabel.Text = "STAGE " .. stage_formatted
end

function Topbar._next_stage_clicked()
	print("Next stage clicked")
end

function Topbar._previous_stage_clicked()
	print("Previous stage clicked")
end

function Topbar._skip_all_clicked()
	print("Skip all clicked")
end

function Topbar.hide()
	if ShowTween.PlaybackState == Enum.PlaybackState.Playing then
		ShowTween.Completed:Wait()
	end
	HideTween:Play()
end

function Topbar.show()
	if HideTween.PlaybackState == Enum.PlaybackState.Playing then
		HideTween.Completed:Wait()
	end
	ShowTween:Play()
end

function Topbar.init()
	TopbarFrame.Next.MouseButton1Click:Connect(Topbar._next_stage_clicked)
	TopbarFrame.Previous.MouseButton1Click:Connect(Topbar._previous_stage_clicked)
	TopbarFrame.SkipAll.MouseButton1Click:Connect(Topbar._skip_all_clicked)
end

return Topbar
