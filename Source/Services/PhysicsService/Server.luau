--[[
    @Title: Physics service
    @Author: Joseph (BreakLoop)
    @Description: Controls physics-related processes
]]

local PhysicsServiceServer = {}

-- Dependancies
local PhysicsService = game:GetService("PhysicsService")
local Players = game:GetService("Players")
local CollisionGroups = require(script.Parent.CollisionsServer)

-- Types
export type PhysicsServiceServer = typeof(PhysicsServiceServer)

function PhysicsServiceServer.init() end
function PhysicsServiceServer.set_collision_group(self: PhysicsServiceServer, object: Instance, group: string)
	-- Make the provided object a member of collision group <group>
	-- Make all descendants also a member of this collision group (for objects like models)
	if object:IsA("BasePart") then
		object.CollisionGroup = group
	end
	for index, descendant in object:GetDescendants() do
		if not descendant:IsA("BasePart") then
			continue
		end
		descendant.CollisionGroup = group
	end
end

return PhysicsServiceServer
