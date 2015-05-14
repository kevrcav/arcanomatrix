--[[ 
@module

]]

local event = require 'event'
local listener = require 'listener'
local eventmanager = require 'eventmanager'

local cheats = {}

function cheats:load()
  eventmanager:registerListener("KeyPressedEvent", listener:new(self, self.ChangeLevel))
end

function cheats:ChangeLevel(e)
  if e.key == "n" then
    eventmanager:sendEvent(event:new("LevelUpCheatEvent"))
  elseif e.key == "c" then
    eventmanager:sendEvent(event:new("LevelDownCheatEvent"))
  end
end

return cheats