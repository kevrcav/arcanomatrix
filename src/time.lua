local constants = require 'constants'
local event = require 'event'
local listener = require 'listener'
local eventmanager = require 'eventmanager'
local vector = require 'vector'

local time = {center = vector:vect0(), size = vector:vect0(), startingTime = 30, currentTime = 30, countUpTime = 0}

function time:load(x, y, w, h)
  eventmanager:registerListener("LevelWonEvent", listener:new(self, self.WinAchieved))
  self.updateListener = listener:new(self, self.update)
  eventmanager:registerListener("UpdateEvent", self.updateListener)
  eventmanager:registerListener("DrawLayer0", listener:new(self, self.draw))
  self.center = vector:new(x or 0, y or 0)
  self.size = vector:new(w or 0, h or 0)
end

function time:update()
  local dt = love.timer.getDelta()
  if self.timeOver then return end
  self.currentTime = self.currentTime - love.timer.getDelta()
  if self.currentTime <= 0 then
    self.timeOver = true
    eventmanager:sendEvent(event:new("TimeOverEvent"))
  end
end

function time:WinAchieved()
  self.updateListener.hook = self.drainTime
end

function time:drainTime()
  changeInTime = math.min(self.currentTime, love.timer.getDelta()*10)
  self.currentTime = self.currentTime - changeInTime
  DEvent = event:new("TimeDrainEvent")
  DEvent.timeDrained = changeInTime
  eventmanager:sendEvent(DEvent)
  if self.currentTime <= 0 then
    eventmanager:sendEvent(event:new("TimeFinishedDraining"))
    self.updateListener.hook = self.goToNextLevel
    self.countUpTime = 0
  end
end

function time:goToNextLevel()
  self.countUpTime = self.countUpTime + love.timer.getDelta()
  if self.countUpTime > 2 then
    eventmanager:sendEvent(event:new("StartNextLevelEvent"))
    self.updateListener.hook = self.update
  end
end

function time:reset(event)
  self.startingTime = event.time
  self.currentTime = event.time
end

function time:draw()
  love.graphics.setColor(255, 255, 255)
  love.graphics.setFont(constants.LARGEFONT)
  love.graphics.print("Time:", self.center.x - self.size.x/2+10, self.center.y-20)
  love.graphics.setFont(constants.SMALLFONT)
  --love.graphics.rectangle("line", self.center.x - self.size.x / 2, self.center.y - self.size.y / 2,
  --                        self.size.x, self.size.y)
  love.graphics.rectangle("fill", self.center.x - self.size.x / 3, self.center.y - self.size.y / 4,
                          self.size.x *5/6, self.size.y / 2)
  local percentDone = self.currentTime/self.startingTime
  love.graphics.setColor((1-percentDone)*255, percentDone*255, 0)
  love.graphics.rectangle("fill", self.center.x - self.size.x / 3, self.center.y - self.size.y / 4,
                          self.size.x *5/6 * percentDone, self.size.y / 2)
end

return time