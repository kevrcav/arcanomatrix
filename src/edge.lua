local eventmanager = require'eventmanager'
local listener = require'listener'
local event = require 'event'
local vector = require 'vector'
local node = require'node'

-- an edge connects two nodes
local edge = {node1 = node:empty(), node2 = node:empty(), sharesNode = {}, colliding = {}, numberColliding = 0}

-- creates a new edge
function edge:new(nodea, nodeb)
  local o = {node1 = nodea, node2 = nodeb, sharesNode = {}, colliding = {}, numberColliding = 0}
  o.rotation = o.node1.loc:getRotation(o.node2.loc)
  setmetatable(o, self)
  self.__index = self
  
  function o:draw()
    love.graphics.push()
    love.graphics.translate(self.node1.loc.x, self.node1.loc.y)
    love.graphics.rotate(self.rotation)
    love.graphics.setColor(232, 65, 68)
    if o.numberColliding > 0 then
      love.graphics.setColor(65, 232, 68)  
    end
    love.graphics.rectangle("fill", 0, 0, 
                            (self.node2.loc-self.node1.loc):size() , 3)
    love.graphics.pop()
  end
  
  eventmanager:registerListener("DrawLayer1", listener:new(o, o.draw))
  eventmanager:registerListener("EdgeMoved", listener:new(o, o.EdgeMovedListener))
  table.insert(o.node1.edges, o)
  table.insert(o.node2.edges, o)
  
  return o
end

-- given a node, return the node on the other side
-- this assumes the given node is contained in this.
-- TODO: make this function safer
function edge:getOtherNode(node)
  if node==self.node1 then
    return self.node2
  else
    return self.node1
  end
end

function edge:NodeMoved()
  self.rotation = self.node1.loc:getRotation(self.node2.loc)
  local edgeMovedEvent = event:new('EdgeMoved')
  edgeMovedEvent.edge = self
  eventmanager:sendEvent(edgeMovedEvent)
end

function edge:EdgeMovedListener(e)
  if self.sharesNode[e.edge] then return end
  local isColliding = self:IsColliding(e.edge)
  if not isColliding and self.colliding[e.edge] then
    self.colliding[e.edge] = nil
    e.edge.colliding[self] = nil
    self.numberColliding = self.numberColliding - 1
    e.edge.numberColliding = e.edge.numberColliding - 1
    eventmanager:sendEvent(event:new("CounterResetEvent"))
  elseif isColliding and not self.colliding[e.edge] then
    self.colliding[e.edge] = true
    e.edge.colliding[self] = true
    self.numberColliding = self.numberColliding + 1 
    e.edge.numberColliding = e.edge.numberColliding + 1
    eventmanager:sendEvent(event:new("CounterResetEvent"))
    print(self.numberColliding)
  end
end

function edge:IsColliding(otherEdge)
  local p,q = self.node1.loc,otherEdge.node1.loc
  local r,s = self.node2.loc-p,otherEdge.node2.loc-q
  local qmp = q-p
  local t = (qmp:cross(s))/r:cross(s)
  local u = (qmp:cross(r))/r:cross(s)
  return t >= 0 and t <= 1 and u >= 0 and u <=1
end

function edge:GetOtherNodeNumValue(node)
  local otherNode = self:getOtherNode(node)
  if otherNode.orb then
    return otherNode.orb:getNumNodeValue() * (self.numberColliding + 1)
  end
  return 0
end

return edge