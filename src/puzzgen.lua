local dataloader = require 'dataloader'
local edge = require 'edge'
local timer = require 'timer'
local timer = require 'timer'
local vector = require 'vector'
local orb = require 'orb'
local node = require 'node'
local listener = require 'listener'
local eventmanager = require 'eventmanager'
local event = require 'event'

local puzzgen = {orbData = {}, level = 1}

-- load in elements from text files and register a listener
function puzzgen:load()
    self.orbData = dataloader:loadOrbs("orbs.txt")
    self.names = dataloader:loadNames("names.txt")
    eventmanager:registerListener("NextLevelEvent", listener:new(self, self.makeRandomPuzzle))
    eventmanager:registerListener("LevelUpEvent", listener:new(self, self.NextLevel))
end

function puzzgen:NextLevel(e)
  self.level = e.level
end

-- creates a random puzzle depending on the current level.
-- TODO: Actually go in-depth on how this works
function puzzgen:makeRandomPuzzle(BEvent)
  nodeRect = self:makeRect(BEvent.board.matrixzone.center, BEvent.board.matrixzone.size)
  orbRect = self:makeRect(BEvent.board.orbzone.center, BEvent.board.orbzone.size)
  
  local nodes = {}
  local edges = {}
  local orbs = {}
  
  math.randomseed(os.time())
  
  for i = 1, self.level+2 do
    table.insert(nodes, node:new(math.random(nodeRect.left+15, nodeRect.right-15), 
                                 math.random(nodeRect.up+15, nodeRect.down-15)))
  end
  
  numElemNodes = math.random(math.ceil(#nodes/2)-1, math.floor(#nodes/2)+1)
  for i = 1, numElemNodes do
    local newOrbData = self.orbData[math.random(1, #self.orbData)]
    local newOrb = orb:newElementOrb(math.random(orbRect.left+13, orbRect.right-13),
                                     math.random(orbRect.up+13, orbRect.down-13), newOrbData.element, newOrbData.color)
    table.insert(orbs, newOrb)
    nodes[i].orb = newOrb
  end
  
  for i = 1, #nodes-numElemNodes do
    local newOrb = orb:newAmplifyOrb(math.random(orbRect.left+13, orbRect.right-13),
                                     math.random(orbRect.up+13, orbRect.down-13), 
                                     math.random(1, 3+math.floor(self.level)))
    table.insert(orbs, newOrb)
    nodes[i+numElemNodes].orb = newOrb
  end
  
  table.foreach(nodes, function(i, node)
    needsConnection=#node.edges == 0
    while(needsConnection) do
      potentialEdgeNode = nodes[math.random(1, #nodes)]
      if potentialEdgeNode.orb.type ~= node.orb.type then
        table.insert(edges, edge:new(potentialEdgeNode, node))
        needsConnection = false
      end
    end
  end)
  
  local maxNumberEdges = 1--#nodes*(#nodes-1)/2
  local edgesToMake = 1--math.random(#edges+1, maxNumberEdges)-#edges
  local nodesWithoutMaxEdges = {}
  table.foreach(nodes, function(i, node)
    if #node.edges < #nodes - 1 then
      table.insert(nodesWithoutMaxEdges, node)
    end
  end)
  for i = 1, edgesToMake do
    local node1 = math.random(1, #nodesWithoutMaxEdges)
    local node2 = math.random(1, #nodesWithoutMaxEdges)
    local needsEdge = true
    local tries = 0
    while needsEdge do
      if tries >= 10 then
        needsEdge = false
      elseif node1 == node2 then
        node2 = math.random(1, #nodesWithoutMaxEdges)
        tries = tries + 1
      elseif not nodesWithoutMaxEdges[node1]:HasEdgeTo(nodesWithoutMaxEdges[node2]) then
        table.insert(edges, edge:new(nodesWithoutMaxEdges[node1], 
                                     nodesWithoutMaxEdges[node2]))
        if #nodesWithoutMaxEdges[node1].edges == #nodes then
          table.remove(nodesWithoutMaxEdges, node1)
        end
        if #nodesWithoutMaxEdges[node2].edges == #nodes then
          table.remove(nodesWithoutMaxEdges, node2)
        end
        needsEdge = false
      else
        node2 = math.random(1, #nodesWithoutMaxEdges)
        tries = tries + 1
      end
    end
  end
  
  table.foreach(nodes, function(i, node)
    BEvent.board:addNode(node)
  end)
  table.foreach(orbs, function(i, orb)
    BEvent.board:addOrb(orb)
  end)
  table.foreach(edges, function(i, edge)
    BEvent.board:addEdge(edge)
    local function AddOtherEdges(i, otherEdge)
      edge.sharesNode[otherEdge] = true
    end
    table.foreach(edge.node1.edges, AddOtherEdges)
    table.foreach(edge.node2.edges, AddOtherEdges)
  end)
  table.foreach(edges, function(i, edge)
    edge:NodeMoved()
  end)
  
  eventmanager:sendEvent(event:new("NewGoalEvent"))
  table.foreach(nodes, function(i, node)
    node.orb = nil
    node.loc = vector:new(math.random(nodeRect.left+15, nodeRect.right-15), math.random(nodeRect.up+15, nodeRect.down-15))
  end)
  table.foreach(edges, function(i, edge)
    edge:NodeMoved()
  end)
  
  BEvent.board.goal.name = self:makeName(BEvent.board.goal.matrix)
  eventmanager:sendEvent(event:new("CounterResetEvent"))
  timer:StartTimer("LevelTimer")
  return
end

-- Helper function for creating a name using the elements generated from the name file
function puzzgen:makeName(matrix)
  local name = ""
  local i = 1
  local matrixLen = 0
  table.foreach(matrix, function(e,v) matrixLen = matrixLen + 1 end)
  for elem,value in pairs(matrix) do
    if i == matrixLen then
      name = name.." "..self.names[elem]["Appliance"][math.random(1, #self.names[elem]["Appliance"])]
    else 
      name = name.." "..self.names[elem]["Component"][math.random(1, #self.names[elem]["Component"])]
    end
    i = i+1
  end
  return name
end

-- makes a specific puzzle useful for testing
function puzzgen:makeNewPuzzle(event)
  board = event.board
  matrixzone = board.matrixzone
  orbzone = board.orbzone
  
  A, B, C, D = node:new(150, 300), node:new(200, 350), node:new(100, 375), node:new(75, 300)
  board:addEdge(edge:new(A, B))
  board:addEdge(edge:new(A, C))
  board:addEdge(edge:new(C, B))
  board:addEdge(edge:new(C, D))
  board:addEdge(edge:new(D, B))
  board:addNode(A)
  board:addNode(B)
  board:addNode(C)
  board:addNode(D)
  board:addOrb(orb:newElementOrb(400, 400, "Hi"))
  board:addOrb(orb:newElementOrb(400, 300, "Yes"))
  board:addOrb(orb:newAmplifyOrb(300, 400, 2))
  board:addOrb(orb:newAmplifyOrb(300, 300, 3))
  board.goal.name = "Yes! Hi 5!"
  board.timer.currentTime = 1000
  board.timer.startingTime = 1000
end

-- creates a rectangle from two vectors, a center and a size
function puzzgen:makeRect(center, size)
  rect = {}
  rect.left = center.x - size.x/2
  rect.right = center.x + size.x/2
  rect.up = center.y - size.y/2
  rect.down = center.y + size.y/2
  return rect
end

return puzzgen