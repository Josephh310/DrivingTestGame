local CameraServiceServer = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Networker = require(ReplicatedStorage.Packages.Networker)

export type CameraService = typeof(CameraServiceServer)

function CameraServiceServer.apply_shake(self: CameraService, players: Player | { Player }, shake_preset: string)
	self.networker:fire(players, "apply_shake", shake_preset)
end

function CameraServiceServer.init(self: CameraService)
	self.networker = Networker.server.new("CameraService", self, {})
end

return CameraServiceServer
