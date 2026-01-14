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

return PhysicsServiceServer
