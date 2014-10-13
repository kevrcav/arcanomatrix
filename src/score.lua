local constants = require 'constants'
local listener = require 'listener'
local event = require 'event'
local eventmanager = require 'eventmanager'
local vector = require 'vector'

-- the score keeps track of the player's score and the current level.
local score = {numberCleared=0, points=0, center = vector.vect0(), size = vector.vect0()}

function score:load(x, y, w, h)
  self.center = vector:new(x or 0, y or 0)
  self.size = vector:new(w or 0, h or 0)
  
  eventmanager:registerListener("TimeDrainEvent", listener:new(self, self.AddToScore))
  eventmanager:registerListener("NextLevelEvent", listener:new(self, self.IncrementLevel))
  eventmanager:registerListener("DrawLayer0", listener:new(self, self.draw))
  
end

function score:AddToScore(event)
  self.points = self.points + event.timeDrained*(self.numberCleared/4+1)
end

function score:IncrementLevel(event)
  self.numberCleared = self.numberCleared + 1
end

function score:draw()
  love.graphics.setColor(255, 255, 255)
  --love.graphics.rectangle("line", self.center.x - self.size.x / 2, self.center.y - self.size.y / 2,
  --                        self.size.x, self.size.y)
  love.graphics.setFont(constants.LARGEFONT)
  love.graphics.print("Level: "..self.numberCleared, self.center.x - self.size.x/2 + 5, self.center.y - 10)
  local stringToPrint = "Score: "..math.floor(self.points)
  love.graphics.print(stringToPrint, self.center.x + self.size.x/2 - 250, self.center.y - 10)
  love.graphics.setFont(constants.SMALLFONT)
end  

return score
