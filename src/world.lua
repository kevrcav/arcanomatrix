local puzzgen = require 'puzzgen'
local board = require 'board'
local orb = require 'orb'
local edge = require 'edge'
local Socket = require'socket'
local Vector = require'vector'
local constants = require'constants'
local listener = require'listener'
local eventmanager = require'eventmanager'
local event = require'event'
local node = require'node'


local World = {
  circle = {x = 0, y = 0, on = false}
}
local t = socket.gettime()
local gameTime = 0
local curTime = 0
local bigFont
local smallFont

function World:load() 
  love.graphics.setBackgroundColor(6, 19, 15)
  board:load()
  puzzgen:load()
  NEvent = event:new("NextLevelEvent")
  NEvent.board = board
  eventmanager:sendEvent(NEvent)
  love.window.setMode(constants.WIDTH,constants.HEIGHT)
  bigFont = love.graphics.newFont(50)
  smallFont = love.graphics.newFont(12)
  constants.SMALLFONT = love.graphics.newFont("AvalonQuest.ttf", 25)
  constants.LARGEFONT = love.graphics.newFont("AvalonQuest.ttf", 40)
  love.graphics.setFont(constants.SMALLFONT)
  return
end

function World:update()
  eventmanager:sendEvent(event:new("UpdateEvent"))
end

function World:draw() 
  eventmanager:sendEvent(event:new("DrawLayer0"))
  eventmanager:sendEvent(event:new("DrawLayer1"))
  eventmanager:sendEvent(event:new("DrawLayer2"))
  eventmanager:sendEvent(event:new("DrawLayer3"))
end

function World:quit()
  
end

return World
