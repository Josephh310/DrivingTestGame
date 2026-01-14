--[[
	@Title: Collision groups configuration
	@Author: Joseph (BreakLoop)
	@Description: Holds info about which collision groups can collide with which.
]]

local CollisionGroups = {}

CollisionGroups.enums = {
	default = "Default",
	characters = "Characters",
	car_body = "CarBody",
	car_wheels = "CarWheels",
}

CollisionGroups.data = {
	--Default (map)
	--Everything can collide with the map.
	{
		CollisionGroups.enums.default,
		CollisionGroups.enums.default,
		true,
	},
	{
		CollisionGroups.enums.default,
		CollisionGroups.enums.characters,
		true,
	},
	{
		CollisionGroups.enums.default,
		CollisionGroups.enums.car_body,
		true,
	},
	{
		CollisionGroups.enums.default,
		CollisionGroups.enums.car_wheels,
		true,
	},
	--Characters
	{
		CollisionGroups.enums.characters,
		CollisionGroups.enums.characters,
		false,
	},
	{
		CollisionGroups.enums.characters,
		CollisionGroups.enums.car_body,
		false,
	},
	{
		CollisionGroups.enums.characters,
		CollisionGroups.enums.car_wheels,
		false,
	},
	--CarBody
	{
		CollisionGroups.enums.car_body,
		CollisionGroups.enums.car_body,
		false, -- Prevent vehicle collisions
	},
	{
		CollisionGroups.enums.car_body,
		CollisionGroups.enums.car_wheels,
		false,
	},
	--CarWheels
	{
		CollisionGroups.enums.car_wheels,
		CollisionGroups.enums.car_wheels,
		false, -- Prevent vehicle collisions
	},
}

return CollisionGroups
