local event = require 'event'
local vector = require 'vector'
local eventmanager = require'eventmanager'
local listener = require'listener'

-- a node for the matrix/graph. Can contain an orb.
local node = {}

-- create a new node
function node:new(x, y)
  local o = {loc = vector:new(x, y), edges = {}}
  setmetatable(o, self)
  self.__index = self
  
  function o:draw()
    if self.mouseHover then
      love.graphics.setColor(221, 205, 87)
    else
      love.graphics.setColor(206, 208, 227)
    end
    love.graphics.circle('fill', self.loc.x, self.loc.y, 15, 50)
    if self.mouseClick then
      love.graphics.setColor(189, 61, 61)
    else
      love.graphics.setColor(31, 72, 194)
    end
    love.graphics.circle('fill', self.loc.x, self.loc.y, 13, 50)
  end
  
  -- move if this is unstable, also move if the mouse is moving this
  function o:update()
    mouseloc = vector:new(love.mouse.getPosition())
    self.mouseHover = self.loc:distance(mouseloc) < 15
    if self.mouseClick then
      movedist = mouseloc - self.lastmouse
      self.loc = movedist + self.loc
      self.lastmouse = mouseloc
    end
    if self.unstable then
      oldLoc = vector:new(self.loc.x, self.loc.y)
      CEvent = event:new("CircleCollideEvent")
      CEvent.loc = self.loc
      CEvent.radius = 15
      CEvent.object = self
      eventmanager:sendEvent(CEvent)
      self.unstable = oldLoc ~= self.loc
    end
  end
  
  -- when the mouse is pressed, become grabbed if this contains no orb, otherwise it grabs the orb and goes away from this
  function o:mousedown(event)
    if self.disabled then return end
    mouseloc = vector:new(love.mouse.getPosition())
    self.mouseClick = self.loc:distance(mouseloc) < 15
    self.lastmouse = mouseloc
    if self.mouseClick and self.orb then
      self.orb.grabbed = false
      self.orb = nil 
      eventmanager:sendEvent(event:new("OrbRemovedEvent"))
      self.mouseClick = false
    end
    if self.mouseClick then
      return true 
    end
  end
  
  -- grab an orb if it's dropped within a reasonably close enough area
  function o:grabOrb(event)
    if not self.orb and self.loc:distance(event.orb.loc) < 15 then
      self.orb = event.orb
      self.orb.loc:set(self.loc)
      self.orb.unstable = false
      self.orb.grabbed = true
      eventmanager:sendEvent(event:new("OrbPlacedEvent"))
      return true
    end
  end
  
  -- if the mouse is released and we were grabbed then this get dropped
  function o:mouseup()
    if self.mouseClick then 
      self.unstable = true
      DEvent = event:new("NodeInBoundsEvent")
      DEvent.loc = self.loc
      DEvent.radius = 15
      eventmanager:sendEvent(DEvent)
    end
    self.mouseClick = false
  end
  
  -- Gathers bordering values and gives those to a node
  function o:giveNodeValueToCounter()
    if self.orb then
      self.orb:giveOrbValue(self.edges, self, "Counter")
    end
  end
  
  -- Same as above, but for goals instead of counters
  function o:giveNodeValueToGoal()
    if self.orb then
      self.orb:giveOrbValue(self.edges, self, "Goal")
    end
  end
  
  eventmanager:registerListener("DrawLayer2", listener:new(o, o.draw))
  eventmanager:registerListener("UpdateEvent", listener:new(o, o.update))
  eventmanager:registerListener("MouseReleasedEvent", listener:new(o, o.mouseup))
  eventmanager:registerListener("MousePressedEvent", listener:new(o, o.mousedown))
  eventmanager:registerListener("OrbDropEvent", listener:new(o, o.grabOrb))
  eventmanager:registerListener("UpdateCounterMatrix", listener:new(o, o.giveNodeValueToCounter))
  eventmanager:registerListener("UpdateGoalMatrix", listener:new(o, o.giveNodeValueToGoal))
  eventmanager:registerListener("CircleCollideEvent", listener:new(o, o.collideWithCircle))
  eventmanager:registerListener("DisableGameObjectsEvent", listener:new(o, o.Disable))
  return o
end

-- moves this and a colliding body if they're colliding
function node:collideWithCircle(event)
  loc = event.loc
  radius = event.radius
  if self ~= event.object and self.loc:distance(loc) < 15+radius then
    rotation = self.loc:getRotation(loc)
    move = vector:new(math.cos(rotation), math.sin(rotation))
    loc:addm(move)
    self.loc:subm(move)
    self.unstable = true
    if self.orb then
      self.orb.loc:subm(move)
    end
  end
end

-- checks to see if this is directly connected to another node
function node:HasEdgeTo(otherNode)
  local hasEdge = false
  table.foreach(self.edges, function(i, edge)
    hasEdge = edge:getOtherNode(self)==otherNode or hasEdge
  end)
  return hasEdge
end

-- make this node uninteractable
function node:Disable()
  if self.mouseClick then self:mouseup() end
  self.disabled = true
end

-- returns a node with nothing in it at the origin.
function node:empty()
  o = {loc = vector:vect0()}
  setmetatable(o, self)
  self.__index = self
  function o:draw() end
  return o 
end

return node
