local HitTri = require'hittri'
local Vector = require'vector'

function vect0() return Vector:new(0, 0) end

--[[A hit box is defined by a point vector and a size vector.
    When calculating hit detection, 
    it splits the box into two triangles.
  ]]

local HitBox = {loc = vect0(), size = vect0(), points = {}}

function HitBox:new(newLoc, newSize)
  local o = {loc = newLoc, size = newSize, points = makeCorners(newLoc, newSize)}
  setmetatable(o, self)
  self.__index = self
  return o
end

function makeCorners(loc, size)
  local left, right = loc.x - size.x/2, loc.x + size.x/2
  local top, bottom = loc.y - size.y/2, loc.y + size.y/2
  return {Vector:new(left, top),
          Vector:new(left, bottom),
          Vector:new(right, top),
          Vector:new(right, bottom)}
end

function HitBox:move(v)
  for i,p in ipairs(self.points) do
    p:addm(v)
  end
  self.loc:addm(v)
end

function HitBox:moveBack(v)
  for i,p in ipairs(self.points) do
    p:subm(v)
  end
  self.loc:subm(v)
end

function HitBox:moveOverTo(point)
  self:move(Vector:sub(point, self.loc))
end

-- detects if the point is within the hit box quickly
function HitBox:detectPoint(point)
  return HitTri:detectPoint(self.points[1], self.points[2], self.points[3], point)
      or HitTri:detectPoint(self.points[2], self.points[3], self.points[4], point)
end

-- move the given hitbox along the given velocity up to the side of this
-- then return the side that the point was moved to.
-- left = 1, top = 2, right = 3, bottom = 4
-- moveTo : HitBox + Vector -> int
function HitBox:moveTo(point, vel)
  xSide = Vector:determineDir(Vector:sub(point.loc, self.loc), 
                              Vector:new(1, 0))
  ySide = Vector:determineDir(Vector:sub(point.loc, self.loc),
                              Vector:new(0, 1))
  xWall = self.loc.x + self.size.x / 2 * xSide
  yWall = self.loc.y + self.size.y / 2 * ySide
  xT = (xWall - (point.loc.x - point.size.x/2*xSide)) / vel.x
  yT = (yWall - (point.loc.y - point.size.y/2*ySide)) / vel.y
  if xT < yT and yT >= 0 and xT >=0 or yT < 0 then
    point:moveOverTo(Vector:new(xWall + point.size.x / 2 * xSide, 
                                point.loc.y + vel.y))
    return xSide + 2
  elseif yT <= xT and yT >=0 and xT >= 0 or xT < 0 then
    point:moveOverTo(Vector:new(point.loc.x + vel.x, 
                                yWall + point.size.y / 2 * ySide))
    return ySide + 3
  else
    point:moveOverTo(Vector:new(xWall + point.size.x / 2 * xSide,
                                yWall + point.size.y / 2 * ySide))
  end
  return 0
end

-- tests if any of these points are within the given hit box
function HitBox:anyPointWithin(hb)
  for i, p in ipairs(self.points) do
    if hb:detectPoint(p) then 
      return true
    end
  end
  return false
end

-- tests if this box collides with the given box
function HitBox:boxCollide(hb)
  return self:anyPointWithin(hb)
      or hb:anyPointWithin(self)
      or self:cornLessIntersect(hb)
end

-- tests if the two boxes intersect without corners intersecting
function HitBox:cornLessIntersect(hb)
  return self:horzIntersect(hb)
      or hb:horzIntersect(self)
end

-- returns if this intersects horizontally with the given box
function HitBox:horzIntersect(hb)
  topLeft = self.points[1]
  bottomLeft = self.points[2]
  topRight = self.points[3]
  otherBot = hb.loc.y+hb.size.y/2
  otherTop = hb.loc.y-hb.size.y/2
  otherLeft = hb.loc.x-hb.size.x/2
  otherRight = hb.loc.x+hb.size.x/2
  return bottomLeft.y < otherBot
     and topLeft.y > otherTop
     and topLeft.x < otherRight
     and topRight.x > otherLeft
end

function createNoBottom()
  local NoBottom = {}
  
  function NoBottom:new(newLoc, newSize)
    local o = {loc = newLoc, size = newSize, points = makeCorners(newLoc, newSize)}
    setmetatable(o, self)
    self.__index = self
    return o
  end
  
  if HitBox then
    setmetatable(NoBottom, { __index = HitBox })
  end
  
  return NoBottom
end

local NoBottom = createNoBottom()

function NoBottom:moveTo(point, vel)
  if point.loc.y + point.size.y/2 <= self.loc.y - self.size.y/2 then
    point:moveOverTo(Vector:new(point.loc.x + vel.x,
                                self.loc.y - point.size.y/2 - self.size.y/2))
    return 2
  else
    point:move(vel)
    return 0
  end
end

return {HitBox, NoBottom}