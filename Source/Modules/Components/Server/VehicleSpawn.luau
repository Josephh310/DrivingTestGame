return function(spawn: BasePart)
	if not spawn:IsA("BasePart") then
		return
	end
	spawn.Transparency = 1
end
