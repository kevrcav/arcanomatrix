--[[ 
@module

]]

local listener = require 'listener'
local eventmanager = require 'eventmanager'

local timer = {timeSinceStart = 0, timers = {}}

function timer:load()
  eventmanager:registerListener("UpdateEvent", listener:new(self, timer.update))
end

function timer:update()
  self.timeSinceStart = self.timeSinceStart + love.timer.getDelta()
end

function timer:GetTime()
  return self.timeSinceStart
end

function timer:StartTimer(timerName)
  self.timers[timerName] = love.timer.getTime()
end

function timer:GetTimer(timerName)
  return love.timer.getTime() - (self.timers[timerName] or love.timer.getTime())
end

return timer