return function(obstacle: Model | BasePart, hit: BasePart)
	local vehicle = hit.Parent
	local wheels = vehicle.Scripted.Wheels:GetChildren()
	for _, wheel in wheels do
		if wheel:IsA("BasePart") then
			wheel.Material = Enum.Material.Ice
		end
	end
	task.delay(3, function()
		for _, wheel in wheels do
			if wheel:IsA("BasePart") then
				wheel.Material = Enum.Material.SmoothPlastic
			end
		end
	end)
end
