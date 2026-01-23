-- Dependencies
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Networker = require(ReplicatedStorage.Packages.Networker)
local DataServiceServer = require(ServerScriptService.Services.DataService.DataServiceServer)
local BadgeService = game:GetService("BadgeService")

local badges = {
    welcome = 1333398432526365, 
    stage_10 = 2586291309616850,
    stage_20 = 1799699978815083,
    stage_30 = 3736276348916623,
    stage_40 = 2807234818059701,
    stage_50 = 3247666506209402,
    winning = 1298548968862929
}

local BadgeServiceServer = {}

-- Types
export type BadgeServiceServer = typeof(BadgeServiceServer)

function BadgeServiceServer.award_badge(self: BadgeServiceServer, player: Player, badge_name: string)
    local badge_id = badges[badge_name]
    if not badge_id then
        warn(`Attempt to award invalid badge: {badge_name}`)
        return
    end
    local success, error_message = pcall(BadgeService.AwardBadgeAsync, BadgeService, player.UserId, badge_id)
    if not success then
        error(error_message)
    end
    DataServiceServer:apply_change(player, { "badges" }, function(current: { string })
        table.insert(current, badge_name)
        return current
    end)
end

function BadgeServiceServer.init(self: BadgeServiceServer)
    self.networker = Networker.server.new("BadgeService")
end

return BadgeServiceServer