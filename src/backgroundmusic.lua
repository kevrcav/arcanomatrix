local backgroundmusic = {}

function backgroundmusic:SetMusic(filename)
  self.music = love.audio.newSource(filename)
  self.music:play()
end

function backgroundmusic:SetVolume(val)
  self.music:setVolume(val)
end

return backgroundmusic