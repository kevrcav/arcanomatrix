local eventmanager = require 'eventmanager'
local listener = require 'listener'
local shaders = require 'shaders'
local vector = require 'vector'

-- a zone is an area of the screen nodes and circles can reside. 
local zone = {center = vector:vect0(), size = vector:vect0()}

-- create a zone with the given rect and see if it should be drawn.
function zone:new(x, y, width, height, renderBorder)
  local o = {center = vector:new(x, y), size = vector:new(width, height)}
  setmetatable(o, self)
  self.__index = self
  if renderBorder then
    eventmanager:registerListener("DrawLayer1", listener:new(o, o.draw))
  end
  return o
end

-- is the given circle within this?
function zone:circleWithin(loc, radius)
  return loc.x + radius < self.center.x + self.size.x/2
     and loc.x - radius > self.center.x - self.size.x/2
     and loc.y + radius < self.center.y + self.size.y/2
     and loc.y - radius > self.center.y - self.size.y/2
end
 
 -- draw a border around this
function zone:draw()
  love.graphics.setColor(41, 45, 44)
  love.graphics.rectangle("fill", self.center.x-self.size.x/2, self.center.y-self.size.y/2, self.size.x, self.size.y)
  love.graphics.setColor(103, 114, 111)
  love.graphics.rectangle("fill", self.center.x-self.size.x/2+3, self.center.y-self.size.y/2+3, self.size.x-6, self.size.y-6)
end

-- moves a point with the given radius to the closest place within this.
function zone:moveToWithin(loc, radius)
  if loc.x + radius > self.center.x + self.size.x/2 then
    loc.x = self.center.x + self.size.x/2 - radius
  elseif loc.x - radius < self.center.x - self.size.x/2 then
    loc.x = self.center.x - self.size.x/2 + radius
  end
  if loc.y + radius > self.center.y + self.size.y/2 then
    loc.y = self.center.y + self.size.y/2 - radius
  elseif loc.y - radius < self.center.y - self.size.y/2 then
    loc.y = self.center.y - self.size.y/2 + radius
  end
end

return zone
