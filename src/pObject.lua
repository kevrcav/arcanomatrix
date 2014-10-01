local Vector = require'vector'
local HitBoxF = require'hitbox'
local HitBox = HitBoxF[1]
local constants = require'constants'

vect0 =  Vector.vect0

local PObject = {v = vect0(), a = vect0(), col = HitBox:new(vect0(), vect0())}

function PObject:new(nx, nv, na, size)
  local o = {v = nv, a = na, col = HitBox:new(nx, size)}
  setmetatable(o, self)
  self.__index = self
  return o
end

-- returns the first entity this collides with, if none returns nil
function PObject:firstCollide(entities)
  for i, e in ipairs(entities) do
    if e.body.col:boxCollide(self.col) then
      return e
    end
  end
end

function PObject:update(platforms, t)
  self.v:addm(Vector:multc(self.a, t))
  move = Vector:multc(self.v, t)
  self.col:move(move)
  sideHits = {}
  canJump = false
  table.foreach(platforms, function(i, p)
    if p:collide(self.col) then
      self.col:moveBack(move)
      sideHit = p:moveTo(self.col, move)
      table.insert(sideHits, sideHit)
      if sideHit ~= 0 then
        canJump = sideHit
      end
    end
  end)
  for i, sideHit in ipairs(sideHits) do
    if sideHit == 1 or sideHit == 3 then
      self.v = Vector:new(0.01*self.v.x, self.v.y)
    elseif sideHit == 2 or sideHit == 4 then
      if math.abs(self.a.x)<100 or self.a.x*self.v.x < 0 then
        self.v = Vector:new(constants.FRICTION*self.v.x, 0.01*self.v.y)
      else
        self.v = Vector:new(self.v.x, 0.01*self.v.y)
      end
    end
  end
  if self.v.x > constants.MAX_SPEED then self.v.x = constants.MAX_SPEED end
  if self.v.x < -constants.MAX_SPEED then self.v.x = -constants.MAX_SPEED end
  return canJump
end

function PObject:setXA(newXA)
  self.a.x = newXA*constants.ACCELERATION
end

function PObject:setYA(newYA)
  self.a.y = newYA*constants.ACCELERATION
end

function PObject:draw() end
  
return PObject