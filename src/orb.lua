local event = require 'event'
local listener = require 'listener'
local eventmanager = require 'eventmanager'
local vector = require 'vector'


local orb = {loc = vector:vect0(), label = "", value = 0, type = "", color = {r=0, g=0, b=0}}


local function makeNewElementOrb(neworb)
  function neworb:giveOrbValue(edges, nodeSelfIsOn, CounterOrGoal)
    NEvent = event:new("Give"..CounterOrGoal.."NodeValueEvent")
    NEvent.elem = self.label
    local totalValue = 0
    table.foreach(edges, function(i, edge)
      otherNode = edge:getOtherNode(nodeSelfIsOn)
      if otherNode.orb then
        totalValue = totalValue + otherNode.orb:getNumNodeValue()
      end
    end)
    NEvent.value = totalValue
    eventmanager:sendEvent(NEvent)
  end
  
  function neworb:getNumNodeValue()
    return 0
  end
  
  return neworb
end

local function makeNewAmplifyOrb(neworb)
  function neworb:giveOrbValue(edges, nodeSelfIsOn)
    
  end
  
  function neworb:getNumNodeValue()
    return self.value
  end
  
  return neworb 
end

function orb:newElementOrb(x, y, label, color)
  return makeNewElementOrb(self:new(x, y, label, "Element", color))
end

function orb:newAmplifyOrb(x, y, value)
  neworb = makeNewAmplifyOrb(self:new(x, y, tostring(value), "Value", {r=255, g=255, b=255}))
  neworb.value = value
  return neworb
end

function orb:new(x, y, label, type, color)
   local o = {loc = vector:new(x, y), label = label, type = type, color = color}
   setmetatable(o, self)
   self.__index = self
   
  function o:draw()
    love.graphics.setColor(self.color.r, self.color.g, self.color.b)
    love.graphics.circle('fill', self.loc.x, self.loc.y, 13, 50)
    love.graphics.setColor(0, 0, 0)
    love.graphics.printf(self.label:sub(1, 1), self.loc.x-13, self.loc.y-13, 26, 'center')
  end
  
  function o:update()
    mouseloc = vector:new(love.mouse.getPosition())
    self.mouseHover = self.loc:distance(mouseloc) < 13
    if self.mouseClick then
      movedist = mouseloc - self.lastmouse
      self.loc = movedist + self.loc
      self.lastmouse = mouseloc
    end
    if self.unstable then
      oldLoc = vector:new(self.loc.x, self.loc.y)
      CEvent = event:new("CircleCollideEvent")
      CEvent.loc = self.loc
      CEvent.radius = 13
      CEvent.object = self
      eventmanager:sendEvent(CEvent)
      self.unstable = oldLoc ~= self.loc
    end
  end
  
  function o:mousedown(event)
    if self.disabled then return end
    mouseloc = vector:new(love.mouse.getPosition())
    self.mouseClick = self.loc:distance(mouseloc) < 13
    self.lastmouse = mouseloc
    return self.mouseClick
  end
  
  function o:mouseup()
    if self.mouseClick then
      self.unstable = true
      self.mouseClick = false
      DEvent = event:new("OrbDropEvent")
      BEvent = event:new("OrbInBoundsEvent")
      BEvent.loc = self.loc
      BEvent.radius = 13
      DEvent.orb = self
      eventmanager:sendConsumableEvent(DEvent)
      eventmanager:sendConsumableEvent(BEvent)
    end
  end
  
  eventmanager:registerListener("DrawLayer2", listener:new(o, o.draw))
  eventmanager:registerListener("UpdateEvent", listener:new(o, o.update))
  eventmanager:registerListener("MouseReleasedEvent", listener:new(o, o.mouseup))
  eventmanager:registerListener("MousePressedEvent", listener:new(o, o.mousedown))
  eventmanager:registerListener("CircleCollideEvent", listener:new(o, o.collideWithCircle))
  eventmanager:registerListener("DisableGameObjectsEvent", listener:new(o, o.Disable))
  return o
end

function orb:Disable()
  if self.mouseClick then self:mouseup() end
  self.disabled = true
end


function orb:collideWithCircle(event)
  loc = event.loc
  radius = event.radius
  if not self.grabbed and self ~= event.object and self.loc:distance(loc) < 13+radius then
    rotation = self.loc:getRotation(loc)
    move = vector:new(math.cos(rotation), math.sin(rotation))
    loc:addm(move)
    self.loc:subm(move)
    self.unstable = true
    if event.object.orb then
      event.object.orb.loc:addm(move)
    end
  end
end

return orb

