local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Observers = require(ReplicatedStorage.Packages.Observers)
local Fireworks = require(ReplicatedStorage.Shared.Modules.Utilities.Fireworks)

return function(hitbox: BasePart)
	-- Cleanup
	local observers = {}

	-- Reconcile attributes
	if not hitbox:GetAttribute("is_open") then
		hitbox:SetAttribute("is_open", false)
	end
	-- Observe is_open, changes based on obby objectives
	observers[#observers + 1] = Observers.observeAttribute(hitbox, "is_open", function()
		local is_open = hitbox:GetAttribute("is_open")
		if is_open then
			hitbox.CanCollide = false
			hitbox.Color = Color3.fromRGB(0, 255, 0)
			hitbox.Transparency = 0.5
		else
			hitbox.CanCollide = true
			hitbox.Color = Color3.fromRGB(215, 84, 85)
			hitbox.Transparency = 0.1
		end
	end)

	local unlock_criteria = hitbox:FindFirstChild("UnlockCriteria")
	if unlock_criteria and unlock_criteria:IsA("Configuration") then
		local values_registered = 0
		local values_true = 0
		for index, object_value in unlock_criteria:GetChildren() do
			if not object_value:IsA("ObjectValue") then
				continue
			end
			if not object_value.Value then
				object_value:GetPropertyChangedSignal("Value"):Wait()
			end
			if not object_value.Value:IsA("BoolValue") then
				continue
			end
			values_registered += 1
			observers[#observers + 1] = Observers.observeProperty(object_value.Value, "Value", function(value: boolean)
				if value == true then
					values_true += 1
				else
					values_true -= 1
				end
				if values_true == 0 then
					hitbox:SetAttribute("is_open", true)
					local character = Players.LocalPlayer.Character
					if not character then
						return
					end
					Fireworks.launch_fireworks(character.PrimaryPart.CFrame)
				else
					hitbox:SetAttribute("is_open", false)
				end
			end)
		end
	end
	return function()
		for index, stop_observing in observers do
			stop_observing()
		end
	end
end
