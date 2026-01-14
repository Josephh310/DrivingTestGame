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
-- Functions
function PhysicsServiceServer._on_character_added(self: PhysicsServiceServer, character: Model)
	-- Register all new characters to the character collision group for appropriate collisions
	-- Set all players to massless so their weight doesn't mess with vehicles
	self:set_collision_group(character, CollisionGroups.enums.characters)
	self:set_massless(character, true)
end

function PhysicsServiceServer.set_massless(self: PhysicsServiceServer, object: Instance, is_massless: boolean)
	-- Make the provided object massless
	-- Make descendants also massless (for objects like models)
	if object:IsA("BasePart") then
		object.Massless = is_massless
	end
	for index, descendant in object:GetDescendants() do
		if not descendant:IsA("BasePart") then
			continue
		end
		descendant.Massless = is_massless
	end
end

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
