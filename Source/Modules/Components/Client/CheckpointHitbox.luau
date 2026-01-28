local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Observers = require(ReplicatedStorage.Packages.Observers)

return function(hitbox: BasePart)
	-- Reconcile attributes
	if not hitbox:GetAttribute("is_open") then
		hitbox:SetAttribute("is_open", false)
	end
	-- Observe is_open, changes based on obby objectives
	local stop_observing = Observers.observeAttribute(hitbox, "is_open", function()
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
	return stop_observing
end
