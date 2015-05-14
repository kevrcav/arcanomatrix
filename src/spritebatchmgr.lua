--[[ 
@module

]]

local listener = require 'listener'
local eventmanager = require 'eventmanager'
local event = require 'event'

local spritebatchmgr = {spriteBatches = {}}

function spritebatchmgr:load()
  eventmanager:registerListener("DrawLayer3", listener:new(self, self.draw))
end

function spritebatchmgr:draw()
  for spriteBatch,_ in pairs(self.spriteBatches) do
    love.graphics.draw(spriteBatch)
  end
end

function spritebatchmgr:addSpriteBatch(spriteBatch)
  self.spriteBatches[spriteBatch] = true
end

function removeSpriteBatch(spriteBatch)
  self.spriteBatches[spriteBatch] = nil
end

return spritebatchmgr