-- Dependancies
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Signal = require(ReplicatedStorage.Packages.Signal)
local TopbarPlus = require(ReplicatedStorage.Packages.TopbarPlus)

local MusicController = {
	song_queue = nil :: { Sound }?,
	current_song = nil :: Sound?,
	current_song_index = nil :: number?,
	music_changed = nil :: Signal.Signal<Sound, number>?,
	_ended_connection = nil,
	music_topbar = nil,
	menu = nil,
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
