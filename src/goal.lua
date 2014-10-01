local event = require 'event'
local listener = require 'listener'
local eventmanager = require 'eventmanager'
local vector = require 'vector'

local goal = {loc = vector:vect0(), size = vector:vect0(), matrix = {}, name = ""}

function goal:load(x, y, w, h)
  self.loc:set(vector:new(x, y))
  self.size:set(vector:new(w or 200, h or 100))
  eventmanager:registerListener("DrawLayer0", listener:new(self, self.draw))
  eventmanager:registerListener("GiveGoalNodeValueEvent", listener:new(self, self.addType))
  eventmanager:registerListener("NewGoalEvent", listener:new(self, self.newGoal))
end

function goal:addType(event)
  self.matrix[event.elem] = self.matrix[event.elem] or 0
  self.matrix[event.elem] = self.matrix[event.elem] + event.value
end

function goal:newGoal()
  self.matrix = {}
  eventmanager:sendEvent(event:new("UpdateGoalMatrix"))
  eventmanager:sendEvent(event:new("NewNameEvent"))
end

function goal:draw()
  love.graphics.setColor(56, 28, 48)
  love.graphics.rectangle("fill", self.loc.x-self.size.x/2, self.loc.y-self.size.y/2, self.size.x, self.size.y)
  love.graphics.setColor(192, 161, 114)
  love.graphics.rectangle("fill", self.loc.x-self.size.x/2+3, self.loc.y-self.size.y/2+3, self.size.x-6, self.size.y-6)
  love.graphics.setColor(0, 0, 0)
  local i = 0
  local offset = 0
  table.foreach(self.matrix, function(i, l) offset = offset+1 end)
  offset = offset*2
  table.foreach(self.matrix, function(elem, value)
    love.graphics.print(elem..":", self.loc.x-self.size.x/2+10, self.loc.y-offset+17*i)
    love.graphics.print(value, self.loc.x, self.loc.y-offset+17*i)
    i=i+1
  end)
  love.graphics.printf(self.name, self.loc.x-self.size.x/2+10, self.loc.y-self.size.y/2 + 10, self.size.x-20, 'center')
end

return goal