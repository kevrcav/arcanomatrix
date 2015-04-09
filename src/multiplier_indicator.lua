--[[ 
@module

]]

local listener = require 'listener'
local eventmanager = require 'eventmanager'
local vector = require 'vector'

local multiplier_indicator = {loc = vector:vect0(), mult = 2}

function multiplier_indicator:new(loc, mult, edge1, edge2)
  local o = {loc = loc, mult = mult}
  setmetatable(o, self)
  self.__index = self
  eventmanager:registerListener("DrawLayer1", listener:new(o, o.draw))
  return o
end

function multiplier_indicator:draw()
    love.graphics.setColor(40, 180, 48)
    love.graphics.circle('fill', self.loc.x, self.loc.y, 13, 50)
    love.graphics.setColor(255, 255, 255)
    love.graphics.print(self.mult.."x", self.loc.x-12, self.loc.y-15)
end

function multiplier_indicator:clearListeners()
  eventmanager:removeListenersForObject(self)
end

return multiplier_indicator