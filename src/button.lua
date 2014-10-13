local constants = require 'constants'
local listener = require 'listener'
local eventmanager = require 'eventmanager'
local event = require 'event'
local vector = require 'vector'

-- a button is used to send a specific event when clicked. The event cannot contain any data.
-- TODO: Write a descrption for each method
local button = {center = vector:vect0(), size = vector:vect0(), name = "", eventtype = ""}

function button:new(name, eventtype, x, y, w, h, inactive, layer)
  local o = {center = vector:new(x, y), size = vector:new(w, h), name = name, eventtype = eventtype}
  setmetatable(o, self)
  self.__index = self
  o.inactive = inactive
  eventmanager:registerListener("MousePressedEvent", listener:new(o, o.mousedown))
  eventmanager:registerListener("MouseReleasedEvent", listener:new(o, o.mouseup))
  eventmanager:registerListener("DrawLayer"..layer, listener:new(o, o.draw))
  return o
end

function button:mousedown(e)
  if self.inactive then return end
  if self:pointWithin(e.x, e.y) then
    self.clicked = true
  end
end

function button:mouseup(e)
  if self.inactive then return end
  if self.clicked and self:pointWithin(e.x, e.y) then
    self.clicked = false
    eventmanager:sendEvent(event:new(self.eventtype))
  end
end

function button:draw()
  if self.inactive then return end
  love.graphics.setColor(56, 28, 48)
  love.graphics.rectangle("fill", self.center.x-self.size.x/2, self.center.y-self.size.y/2, self.size.x, self.size.y)
  love.graphics.setColor(192, 161, 114)
  love.graphics.rectangle("fill", self.center.x-self.size.x/2+3, self.center.y-self.size.y/2+3, self.size.x-6, self.size.y-6)
  love.graphics.setColor(0, 0, 0)
  love.graphics.setFont(constants.LARGEFONT)
  love.graphics.printf(self.name, self.center.x-self.size.x/2, self.center.y-20, self.size.x, 'center')
  love.graphics.setFont(constants.SMALLFONT)
end

function button:pointWithin(x, y)
  return x < self.center.x + self.size.x/2
     and x > self.center.x - self.size.x/2
     and y < self.center.y + self.size.y/2
     and y > self.center.y - self.size.y/2
end

return button

