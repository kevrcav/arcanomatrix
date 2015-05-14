--[[ 
@module

]]

local event = require 'event'
local listener = require 'listener'
local eventmanager = require 'eventmanager'

local timer = {timeSinceStart = 0, timers = {}, countdownTimers = {}}

function timer:load()
  eventmanager:registerListener("UpdateEvent", listener:new(self, timer.update))
end

function timer:update()
  self.timeSinceStart = self.timeSinceStart + love.timer.getDelta()
  for name,i in pairs(self.countdownTimers) do
    self.countdownTimers[name] = i - love.timer.getDelta()
    if self.countdownTimers[name] < 0 then
      local coevent = event:new("TimerFinishedEvent")
      coevent.timer = name
      eventmanager:sendEvent(coevent)
      self.countdownTimers[name] = nil
    end
  end
end

function timer:GetTime()
  return self.timeSinceStart
end

function timer:StartTimer(timerName)
  self.timers[timerName] = love.timer.getTime()
end

function timer:StartCountdown(timerName, time)
  self.countdownTimers[timerName] = 2
end

function timer:GetTimer(timerName)
  return love.timer.getTime() - (self.timers[timerName] or love.timer.getTime())
end

function timer:GetCountdown(timerName)
  return self.countdownTimers[timerName] or 0
end

return timer