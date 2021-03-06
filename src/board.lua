local button = require 'button'
local score = require 'score'
local timer = require 'timer'
local xp_meter = require 'xp_meter'
local time = require 'time'
local goal = require 'goal'
local constants = require 'constants'
local listener = require 'listener'
local event = require 'event'
local eventmanager = require 'eventmanager'
local zone = require 'zone'
local counter = require 'counter'

-- The board contains all the details about nodes, orbs, edges, and ensures
-- they stay in play. It also holds onto the other zones.
-- Since everything communicates as events, this is effectively storage.
-- TODO: Write descriptions for methods
local board = {matrixzone = zone:new(constants.WIDTH*3/8, constants.HEIGHT*5/8,
                                     constants.WIDTH*3/4-10, constants.HEIGHT*3/4-10, true), 
               orbzone = zone:new(constants.WIDTH*7/8, constants.HEIGHT*3/4,
                                  constants.WIDTH/4-10, constants.HEIGHT/2-10, true), 
               goal = goal, counter = counter, timer = time, score = score,
               nodes = {}, orbs = {}, edges = {}, announceText = "", 
               creditButton = button:new("Credits", "ToggleCreditsEvent", constants.WIDTH*3/32, 
                                      constants.HEIGHT/16, constants.WIDTH*3/16-10, constants.HEIGHT/8-10, false, 0),
               resetButton = button:new("Retry", "GameResetEvent", constants.WIDTH/2,
                                      constants.HEIGHT*2/3, constants.WIDTH*3/16-10, constants.HEIGHT/8-10, true, 3),
               winPhrases = {"Yes. Perfect.", "Just As Planned", "We are Great!", "Got It in One", "Too Fabulous to Stop"},
               creditsOn = false,
               multipliers = {},
               level = 1}

function board:load()
  self.counter:load(constants.WIDTH*7/8, constants.HEIGHT*3/8, constants.WIDTH/4-10, constants.HEIGHT/4-10)
  self.goal:load(constants.WIDTH*7/8, constants.HEIGHT*1/8, constants.WIDTH/4-10, constants.HEIGHT/4-10)
  xp_meter:load(constants.WIDTH*3/8, constants.HEIGHT*3/16, constants.WIDTH*3/4-10, constants.HEIGHT/7)
  self.score:load(constants.WIDTH*15/32, constants.HEIGHT*1/16, constants.WIDTH*9/16-10, constants.HEIGHT/8-10)
  eventmanager:registerListener("WinCheckEvent", listener:new(self, self.CheckForWin))
  eventmanager:registerListener("NodeInBoundsEvent", listener:new(self, self.ensureNodeInPlay))
  eventmanager:registerListener("OrbInBoundsEvent", listener:new(self, self.ensureOrbInPlay))
  eventmanager:registerListener("TimeOverEvent", listener:new(self, self.GameOver))
  eventmanager:registerListener("DrawLayer3", listener:new(self, self.draw))
  eventmanager:registerListener("StartNextLevelEvent", listener:new(self, self.clearBoard))
  eventmanager:registerListener("GameResetEvent", listener:new(self, self.reset))
  eventmanager:registerListener("ToggleCreditsEvent", listener:new(self, self.toggleCredits))
  eventmanager:registerListener("LevelUpEvent", listener:new(self, self.NextLevel))
  eventmanager:registerListener("GetClearXPEvent", listener:new(self, self.GetClearXP))
  eventmanager:registerListener("XPGainFinishedEvent", listener:new(self, self.WaitForSwitch))
  eventmanager:registerListener("TimerFinishedEvent", listener:new(self, self.OnTimerFinished))
end

function board:addNode(node)
  table.insert(self.nodes, node)
end

function board:addOrb(orb)
  table.insert(self.orbs, orb)
end

function board:addEdge(edge)
  table.insert(self.edges, edge)
end

function board:ensureNodeInPlay(event)
  loc = event.loc
  radius = event.radius
  if not self.matrixzone:circleWithin(loc, radius) then
    self.matrixzone:moveToWithin(loc, radius)
  end
end

function board:draw()
  love.graphics.setColor(255, 255, 255)
  love.graphics.setFont(constants.HUGEFONT)
  local scale = 1
  if self.levelUpFanfare then
    love.graphics.push()
    local t = timer:GetCountdown("LevelUpFanfare")
    scale = scale + math.max(math.sin((t+1)*math.pi), 0)*0.15
    love.graphics.scale(scale)
  end
  love.graphics.printf(self.announceText, 0, constants.HEIGHT/3 * 1/scale, constants.WIDTH * 1/scale, 'center')
  love.graphics.setFont(constants.SMALLFONT)
  if self.levelUpFanfare then
    love.graphics.pop()
  end
  if not self.creditsOn then return end
  love.graphics.setColor(0, 0, 0)
  love.graphics.printf("Designed and Programmed by Kabanaw.", self.matrixzone.center.x - self.matrixzone.size.x/2+10, 
                                                              self.matrixzone.center.y + self.matrixzone.size.y/2 - 90, 
                                                              self.matrixzone.size.x, 'left')
  love.graphics.printf("Inspired by Let's Play 13th Age.", self.matrixzone.center.x - self.matrixzone.size.x/2+10,
                                                              self.matrixzone.center.y + self.matrixzone.size.y/2 - 75, 
                                                              self.matrixzone.size.x, 'left')
  love.graphics.printf("13th Age is property of Pelgraine Press and Fire Opal Media.", self.matrixzone.center.x - self.matrixzone.size.x/2+10,
                                                              self.matrixzone.center.y + self.matrixzone.size.y/2 - 60, 
                                                              self.matrixzone.size.x, 'left')
  love.graphics.printf("Thanks to Medibot in particular for the idea of Arcanomatrices", self.matrixzone.center.x - self.matrixzone.size.x/2+10,
                                                              self.matrixzone.center.y + self.matrixzone.size.y/2 - 45, 
                                                              self.matrixzone.size.x, 'left')
  love.graphics.printf("and the victory lines.", self.matrixzone.center.x - self.matrixzone.size.x/2+10,
                                                              self.matrixzone.center.y + self.matrixzone.size.y/2 - 30, 
                                                              self.matrixzone.size.x, 'left')
end

function board:toggleCredits()
  self.creditsOn = not self.creditsOn
end

function board:reset()
  table.foreach(self.nodes, function(i, node)
    eventmanager:removeListenersForObject(node)
  end)
  table.foreach(self.orbs, function(i, orb)
    eventmanager:removeListenersForObject(orb)
  end)
  table.foreach(self.edges, function(i, edge)
    eventmanager:removeListenersForObject(edge)
  end)
  self.nodes = {}
  self.orbs = {}
  self.edges = {}
  self.announceText = ""
  self.score.points = 0
  self.score.numberCleared = 0
  self.resetButton.inactive = true
  self.timer.timeOver = false
  NLEvent = event:new("NextLevelEvent")
  NLEvent.board = self
  eventmanager:sendEvent(NLEvent)
  
end

function board:GameOver()
  eventmanager:sendEvent(event:new("DisableGameObjectsEvent"))
  self.resetButton.inactive = false
  self.announceText = "GAME OVER"
end

function board:ensureOrbInPlay(event)
  loc = event.loc
  radius = event.radius
  local inMatrix = self.matrixzone:circleWithin(loc, radius) 
  local inOrb = self.orbzone:circleWithin(loc, radius)
  if inMatrix or inOrb then
    return
  elseif self.orbzone.center:distance(loc) < self.matrixzone.center:distance(loc) then
    self.orbzone:moveToWithin(loc, radius)
  else
    self.matrixzone:moveToWithin(loc, radius)
  end
end

function board:CheckForWin()
  self.winState = true
  table.foreach(self.goal.matrix, function(elem, value)
    self.winState = value == self.counter.matrix[elem] and self.winState
  end)
  table.foreach(self.counter.matrix, function(elem, value)
    self.winState = value == self.goal.matrix[elem] and self.winState
  end)
  if self.winState then 
    eventmanager:sendEvent(event:new("DisableGameObjectsEvent")) 
    local levent = event:new("LevelWonEvent")
    levent.xp = self:GetClearXP()
    eventmanager:sendEvent(levent)
    self.announceText = self.winPhrases[math.random(1, #self.winPhrases)]
  end
end

function board:WaitForSwitch()
  timer:StartCountdown("LevelSwitchTimer", 2)
end

function board:OnTimerFinished(e)
  if e.timer == "LevelSwitchTimer" then
    if self.leveledUp then
      timer:StartCountdown("LevelUpFanfare", 2)
      self.levelUpFanfare = true
      self.leveledUp = false
      self.announceText = "LEVEL UP!"
    else
      eventmanager:sendEvent(event:new("StartNextLevelEvent"))
    end
  elseif e.timer == "LevelUpFanfare" then
    self.levelUpFanfare = false
    eventmanager:sendEvent(event:new("StartNextLevelEvent"))
  end
end

function board:NextLevel(e)
  self.level = e.level
  self.leveledUp = true
end

function board:GetClearXP(e)
  local timeTaken = timer:GetTimer("LevelTimer")
  local clearXP = (self.level+4) * 4 + math.max((self.level + 4) * 10 - timeTaken, 0)
  if e then
    e.xp = clearXP
  else
    return clearXP
  end
end

function board:clearBoard()
  table.foreach(self.nodes, function(i, node)
    eventmanager:removeListenersForObject(node)
  end)
  table.foreach(self.orbs, function(i, orb)
    eventmanager:removeListenersForObject(orb)
    orb:RemoveSprite()
  end)
  table.foreach(self.edges, function(i, edge)
    edge:clearListeners()
  end)
  self.nodes = {}
  self.orbs = {}
  self.edges = {}
  self.announceText=""
  NLEvent = event:new("NextLevelEvent")
  NLEvent.board = self
  eventmanager:sendEvent(NLEvent)
end

function board:BuildEdgeCollideTables()
  function BuildCollideTable(iToRemove)
    
  end
  for i,edge in ipairs(self.edges) do
    
  end
end

return board