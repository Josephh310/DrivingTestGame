-- Dependancies
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Signal = require(ReplicatedStorage.Packages.Signal)
local TopbarPlus = require(ReplicatedStorage.Packages.TopbarPlus)
local MusicController = {
}
-- Types
export type MusicController = typeof(MusicController)

-- Functions
function MusicController._edit_display(self: MusicController, text: string, text_size: number, font: string)
	self.music_topbar.container:setTextFont(font)
	self.music_topbar.container:setTextSize(text_size)
	self.music_topbar.container:setLabel(text)
end
return MusicController
