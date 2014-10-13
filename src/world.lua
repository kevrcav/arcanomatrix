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

-- the world contains no data
local World = {}
local bigFont
local smallFont

-- load the board and puzzle generator, load the fonts, and get the first level made
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

-- send an update event
function World:update()
  eventmanager:sendEvent(event:new("UpdateEvent"))
end

-- send four draw layer events
function World:draw() 
  eventmanager:sendEvent(event:new("DrawLayer0"))
  eventmanager:sendEvent(event:new("DrawLayer1"))
  eventmanager:sendEvent(event:new("DrawLayer2"))
  eventmanager:sendEvent(event:new("DrawLayer3"))
end

-- we do nothing on quit
function World:quit() end
 
return World
