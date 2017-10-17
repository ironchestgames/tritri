
local jupiter = require('jupiter')
local stateswitcher = require('stateswitcher')
local vars = require('vars')

local bgImage
local canvas
local font

local savedScores

function love.load()

  -- load images
  bgImage = love.graphics.newImage('art/highscore_layout.png')

  -- load font
  font = love.graphics.newImageFont('art/font.png', vars.GLYPHS)
  love.graphics.setFont(font)

  canvas = love.graphics.newCanvas()

  love.graphics.setBackgroundColor(155, 173, 183)

  -- load scores
  savedScores = jupiter.load(vars.HIGHSCORE_FILE_NAME)

  if savedScores == nil then
  	savedScores = {}
  end

end

function love.keypressed()
end

function love.keyreleased(key)
  stateswitcher.switch('optionsScene')
end

function love.update(dt)
end

function love.draw()

  love.graphics.setColor(255, 255, 255, 255)

  love.graphics.setCanvas(canvas)

  love.graphics.clear()

  love.graphics.draw(bgImage, 0, 0)

  love.graphics.setColor(vars.TEXT_COLOR_DARK)

  for i = 1, 10 do
  	local v = 0
  	if savedScores[i] then
  		v = savedScores[i]
  	end
  	love.graphics.printf(
        v,
        55,
        60 + 13 * (i - 1),
        100,
        'right')
  end

  -- draw canvas
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.setCanvas()

  love.graphics.draw(canvas, _G.CANVAS_X, 0, 0, _G.GRAPHICSSCALE, _G.GRAPHICSSCALE)
end
