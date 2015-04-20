--[[ 
@module

]]

local constants = require 'constants'
local shaders = require 'shaders'
local vector = require 'vector'



local bubblefx = {bubbles = {}, bubblesVel = {}, bubblesAccel = {}, boundingRect = {0, 0, constants.WIDTH, constants.HEIGHT}}

function bubblefx:new(n, boundingRect)
  local o = {bubbles = {}, bubblesVel = {}, bubblesAccel = {}, boundingRect = boundingRect}
  o.boundingRect[2] = constants.HEIGHT - o.boundingRect[2]
  o.boundingRect[4] = constants.HEIGHT - o.boundingRect[4]
  o.boundingRect[2], o.boundingRect[4] = o.boundingRect[4], o.boundingRect[2]
  setmetatable(o, self)
  self.__index = self
  for i=1,(n or 10) do
    o:makeBubble(i)
  end
  return o
end

function bubblefx:update()
  for _,bubble in ipairs(self.bubbles) do
    bubble[1] = bubble[1] + self.bubblesVel[_][1]
    self.bubblesVel[_][1] = math.min(math.max(self.bubblesVel[_][1] + self.bubblesAccel[_][1], -1.5), 1.5)
    bubble[2] = bubble[2] + self.bubblesVel[_][2]
    if bubble[2] > self.boundingRect[4]+10 then
      self:makeBubble(_)
    end
  end
end

function bubblefx:makeBubble(i)
  self.bubbles[i] = {math.random(self.boundingRect[1], self.boundingRect[3]), 
                     self.boundingRect[2]-10}
  self.bubblesVel[i] = {math.random()*1-0.5, math.random()*2+1}
  self.bubblesAccel[i] = {math.random()*2-1, 0}
end

function bubblefx:StartFX()
  shaders.xpBarBubble:send("_bubbles", self.bubbles[1], self.bubbles[2], self.bubbles[3], self.bubbles[4],
                                       self.bubbles[5], self.bubbles[6], self.bubbles[7], self.bubbles[8],
                                       self.bubbles[9], self.bubbles[10])
  love.graphics.setShader(shaders.xpBarBubble)
end

function bubblefx.EndFX()
  love.graphics.setShader()
end

return bubblefx