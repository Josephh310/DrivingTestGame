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

-- Functions
function MusicController.modify_queue(self: MusicController, position_shift: number)
	if not self.song_queue then
		warn("No music queue to modify.")
		return
	end

	if self.current_song then
		self.current_song:Stop()
	end

	self.current_song_index = self.current_song_index or 1

	local old_song_index = self.current_song_index
	local queue_size = #self.song_queue

	self.current_song_index = (((old_song_index + position_shift) - 1) % queue_size) + 1

	self.current_song = self.song_queue[self.current_song_index]

	self:toggle_music(true)

	self:_edit_display(` #{self.current_song_index} - {self.current_song.Name}`, 16, "Ubuntu")
end
return MusicController
