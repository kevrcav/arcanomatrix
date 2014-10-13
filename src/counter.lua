local vector = require 'vector'
local listener = require 'listener'
local event = require 'event'
local eventmanager = require 'eventmanager'

-- The counter calculates the value of the nodes within the graph.
-- TODO: Retrace steps through the maze of events I used to write this months ago
local counter = {loc = vector:vect0(), size = vector:vect0(), matrix = {}}

function counter:load(x, y, w, h)
  self.loc:set(vector:new(x, y))
  self.size:set(vector:new(w or 200, h or 100))
  eventmanager:registerListener("DrawLayer0", listener:new(self, self.draw))
  eventmanager:registerListener("GiveCounterNodeValueEvent", listener:new(self, self.getnodeinfo))
  eventmanager:registerListener("OrbPlacedEvent", listener:new(self, self.update))
  eventmanager:registerListener("OrbRemovedEvent", listener:new(self, self.update))
  eventmanager:registerListener("CounterResetEvent", listener:new(self, self.update))
end

-- update the counter each time the relevant bit of a gamestate changes
-- the simplest way to do so is recalculate every time
function counter:update()
  self.matrix = {}
  eventmanager:sendEvent(event:new("UpdateCounterMatrix"))
  eventmanager:sendEvent(event:new("WinCheckEvent"))
end

-- Extracts the info from a node
function counter:getnodeinfo(event)
  self.matrix[event.elem] = self.matrix[event.elem] or 0
  self.matrix[event.elem] = self.matrix[event.elem] + event.value
end

-- Draws the counter on the screen
function counter:draw()
  love.graphics.setColor(56, 28, 48)
  love.graphics.rectangle("fill", self.loc.x-self.size.x/2, self.loc.y-self.size.y/2, self.size.x, self.size.y)
  love.graphics.setColor(192, 161, 114)
  love.graphics.rectangle("fill", self.loc.x-self.size.x/2+3, self.loc.y-self.size.y/2+3, self.size.x-6, self.size.y-6)
  love.graphics.setColor(0, 0, 0)
  local i = 0
  local offset = 0
  table.foreach(self.matrix, function(i, l) offset = offset+1 end)
  offset = offset*5
  table.foreach(self.matrix, function(elem, value)
    love.graphics.print(elem..":", self.loc.x-self.size.x/2+10, self.loc.y-offset+17*i)
    love.graphics.print(value, self.loc.x, self.loc.y-offset+17*i)
    i=i+1
  end)
  love.graphics.print("Current Matrix", self.loc.x-self.size.x/2+10, self.loc.y-self.size.y/2 + 10)
end

return counter