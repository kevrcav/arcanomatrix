local eventmanager = require'eventmanager'
local listener = require'listener'
local node = require'node'

-- an edge connects two nodes
local edge = {node1 = node:empty(), node2 = node:empty()}

-- creates a new edge
function edge:new(nodea, nodeb)
  local o = {node1 = nodea, node2 = nodeb}
  o.rotation = o.node1.loc:getRotation(o.node2.loc)
  setmetatable(o, self)
  self.__index = self
  
  function o:draw()
    love.graphics.push()
    love.graphics.translate(self.node1.loc.x, self.node1.loc.y)
    love.graphics.rotate(self.rotation)
    love.graphics.setColor(232, 65, 68)
    love.graphics.rectangle("fill", 0, 0, 
                            (self.node2.loc-self.node1.loc):size() , 3)
    love.graphics.pop()
  end
  
  -- adjust to line up between its two nodes
  function o:update()
    self.rotation = self.node1.loc:getRotation(self.node2.loc)
  end
  
  eventmanager:registerListener("DrawLayer1", listener:new(o, o.draw))
  eventmanager:registerListener("UpdateEvent", listener:new(o, o.update))
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

return edge