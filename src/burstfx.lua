--[[ 
@module

]]

local constants = require 'constants'
local listener = require 'listener'
local edge = require 'edge'
local eventmanager = require 'eventmanager'
local vector = require 'vector'
local shaders = require 'shaders'
local burstShader = shaders.color_burst

local burstfx = {}

function burstfx:new(x, y, r, lifetime, color)
  local o = {loc = vector:new(x, y), radius = r, t = 0, lifetime = lifetime, color = color}
  setmetatable(o, self)
  self.__index = self
  eventmanager:registerListener("DrawLayer3", listener:new(o, o.draw))
  eventmanager:registerListener("UpdateEvent", listener:new(o, o.update))
  return o
end

function burstfx:draw()
  love.graphics.setShader(burstShader)
  love.graphics.setColor(self.color.r, self.color.g, self.color.b)
  burstShader:send("t", self.t)
  burstShader:send("burst_center", {self.loc.x, constants.HEIGHT-self.loc.y})
  burstShader:send("radius", self.radius)
  love.graphics.circle("fill", self.loc.x, self.loc.y, self.radius)
  love.graphics.setShader()
end

function burstfx:update()
  self.t = self.t + love.timer.getDelta()
  if self.t > self.lifetime then
    eventmanager:removeListenersForObject(self)
  end
end

return burstfx