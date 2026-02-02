local Debris = game:GetService("Debris")

return function(part: BasePart, sound: Sound)
	local new_sound = sound:Clone()
	new_sound.Parent = part
	new_sound:Play()
	Debris:AddItem(new_sound, new_sound.TimeLength)
end
