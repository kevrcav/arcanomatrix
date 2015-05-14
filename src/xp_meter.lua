--[[ 
@module

]]

local bubblefx = require 'bubblefx'
local vector = require 'vector'
local listener = require 'listener'
local eventmanager = require 'eventmanager'
local event = require 'event'

local xp_meter = {xp = 0, xpToNextLevel = 100, xpToGain = 0, level = 1, updateFunction = nil}

function xp_meter:load(x, y, w, h)
  self.center = vector:new(x or 0, y or 0)
  self.size = vector:new(w or 0, h or 0)
  eventmanager:registerListener("UpdateEvent", listener:new(self, self.update))
  eventmanager:registerListener("LevelWonEvent", listener:new(self, self.awardXP))
  eventmanager:registerListener("DrawLayer0", listener:new(self, self.draw))
  eventmanager:registerListener("LevelUpCheatEvent", listener:new(self, self.ForceLevelUp))
  eventmanager:registerListener("LevelDownCheatEvent", listener:new(self, self.ForceLevelDown))
  self.fx = bubblefx:new(10, {x-w/2, y-h/2, x+w/2, y+h/2})
end

function xp_meter:update()
  self.fx:update()
  if self.updateFunction then
    self:updateFunction()
  end
end

function xp_meter:draw()
  love.graphics.setColor(255, 255, 255)
  love.graphics.setFont(constants.LARGEFONT)
  love.graphics.print("XP:", self.center.x - self.size.x/2+10, self.center.y-20)
  love.graphics.setFont(constants.SMALLFONT)
  --love.graphics.rectangle("line", self.center.x - self.size.x / 2, self.center.y - self.size.y / 2,
  --                        self.size.x, self.size.y)
  self.fx:StartFX()
  love.graphics.rectangle("fill", self.center.x - self.size.x / 3, self.center.y - self.size.y / 4,
                          self.size.x *5/6, self.size.y / 2)
  local percentDone = self.xp/self.xpToNextLevel
  love.graphics.setColor(0, 200, 0)
  love.graphics.rectangle("fill", self.center.x - self.size.x / 3, self.center.y - self.size.y / 4,
                          self.size.x *5/6 * percentDone, self.size.y / 2)
  self.fx.EndFX()
end

function xp_meter:gainXP()
  local xpThisTick = math.min(self.xpToNextLevel * 0.005, self.xpToGain)
  self.xp = xpThisTick + self.xp
  self.xpToGain = self.xpToGain - xpThisTick
  local xpevent = event:new("XPGainEvent")
  xpevent.xpGained = xpThisTick
  eventmanager:sendEvent(xpevent)
  if self.xp >= self.xpToNextLevel then
    self:levelUp()
  end
  if self.xpToGain <= 0 then
    self.xpToGain = 0
    self.updateFunction = nil
    eventmanager:sendEvent(event:new("XPGainFinishedEvent"))
  end
end

function xp_meter:awardXP(event)
  self.xpToGain = event.xp
  self.updateFunction = self.gainXP
end

function xp_meter:levelUp()
  if self.xp > self.xpToNextLevel then
    self.xp = self.xp % self.xpToNextLevel
  else
    self.xp = 0
  end
  self.xpToNextLevel = math.floor(self.xpToNextLevel * 1.25)
  self.level = self.level + 1
  local luevent = event:new("LevelUpEvent")
  luevent.level = self.level
  eventmanager:sendEvent(luevent)
end

function xp_meter:ForceLevelUp(e)
  self:levelUp()
  eventmanager:sendEvent(event:new("StartNextLevelEvent"))
end

function xp_meter:ForceLevelDown(e)
  if self.level <= 1 then return end
  if self.xp > self.xpToNextLevel then
    self.xp = self.xp % self.xpToNextLevel
  else
    self.xp = 0
  end
  self.xpToNextLevel = math.floor(self.xpToNextLevel / 1.25)
  self.level = self.level - 1
  local luevent = event:new("LevelUpEvent")
  luevent.level = self.level
  eventmanager:sendEvent(luevent)
  eventmanager:sendEvent(event:new("StartNextLevelEvent"))
end

return xp_meter
