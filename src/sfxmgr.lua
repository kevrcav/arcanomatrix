--[[ 
@module

]]

local eventmanager = require 'eventmanager'
local event = require 'event'
local listener = require 'listener'

local sfxmgr = {sfx = {}, listeners = {}}

function sfxmgr:NewSFX(name, filename)
  self.sfx[name] = love.audio.newSource(filename, "static")
end

function sfxmgr:MakePlayListener(name, eventName)
  local sfxListener = listener:new(self, function(self, event)
    self.sfx[name]:play()
  end)
  self.listeners[name] = self.listeners[name] or {}
  table.insert(self.listeners[name], sfxListener)
  eventmanager:registerListener(eventName, sfxListener)
end

function sfxmgr:AddListeners(name, ...)
  for _,eventName in ipairs(arg) do
    sfxmgr:MakePlayListener(name, eventName)
  end
end

return sfxmgr