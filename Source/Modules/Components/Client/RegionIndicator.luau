local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Observers = require(ReplicatedStorage.Packages.Observers)
local Fireworks = require(ReplicatedStorage.Shared.Modules.Utilities.Fireworks)

return function(indicator_root: BasePart)
	-- Constants
	local values = indicator_root.Parent.Values :: Folder
	local sides = indicator_root.Parent.Sides :: Folder
	local border_color = values.BorderColor :: Color3Value
	local success = false

	-- Color observer
	local stop_observing_color = Observers.observeProperty(border_color, "Value", function()
		for _, Part in sides:GetChildren() do
			for _, SurfaceGui in Part:GetChildren() do
				SurfaceGui.Frame.UIGradient.Color = ColorSequence.new(border_color.Value)
			end
		end
	end)

	local touched_connection = indicator_root.Touched:Connect(function(touched: BasePart)
		if touched.Name ~= "Body" or touched.Parent.Name ~= Players.LocalPlayer.Name then
			return
		end
		print("valid body touching")
		local is_touching = true
		local touch_stopped_connection = nil
		touch_stopped_connection = indicator_root.TouchEnded:Connect(function(ex_touched: BasePart)
			if ex_touched == touched then
				print("stopped touching")
				is_touching = false
				touch_stopped_connection:Disconnect()
			end
		end)
		repeat
			task.wait()
			local parts = workspace:GetPartsInPart(indicator_root)
			if table.find(parts, touched) then
				print("SUCCESS YAY!!!!")
				Fireworks.launch_fireworks(touched.CFrame)
				success = true
			end
		until is_touching == false or success == true
	end)

	return function()
		stop_observing_color()
		touched_connection:Disconnect()
	end
end
