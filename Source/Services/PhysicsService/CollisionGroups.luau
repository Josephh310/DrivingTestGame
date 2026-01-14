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

return CollisionGroups
