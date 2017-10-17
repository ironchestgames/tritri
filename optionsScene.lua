
love.graphics.setDefaultFilter('nearest', 'nearest')

local jupiter = require('jupiter')
local stateswitcher = require('stateswitcher')
local vars = require('vars')

local bgImage
local selectionImage
local canvas
local font

local selectionIndex = 0

function love.load()

  -- load images
  bgImage = love.graphics.newImage('art/bg.png')
  selectionImage = love.graphics.newImage('art/options_selection.png')

  -- load font
  font = love.graphics.newImageFont('art/font.png', vars.GLYPHS)
  love.graphics.setFont(font)

  canvas = love.graphics.newCanvas()

  love.graphics.setBackgroundColor(155, 173, 183)

end

function love.keyreleased(key)

  if key == 'space' or key == 'return' or key == 'z' or key == 'left' or key == 'right' then

    if selectionIndex == 1 then
      local optionFileSaveSuccess = jupiter.save(_G.options)
      stateswitcher.switch('gameScene')
    elseif selectionIndex == 0 then
      _G.options.showBackgroundEffect = not _G.options.showBackgroundEffect
    end

  elseif key == 'up' then
    selectionIndex = selectionIndex - 1
  elseif key == 'down' then
    selectionIndex = selectionIndex + 1
  end

  if selectionIndex < 0 then
    selectionIndex = 1
  elseif selectionIndex > 1 then
    selectionIndex = 0
  end
end

function love.update(dt)
  
end

function love.draw()

  love.graphics.setColor(255, 255, 255, 255)

  love.graphics.setCanvas(canvas)

  love.graphics.clear()

  -- options
  do
    local optionTextX = 26
    local optionTextY = 55
    local optionTextHeight = 42
    local optionValueX = 175

    love.graphics.draw(
        selectionImage,
        optionTextX - 5,
        (optionTextY - 5) + selectionIndex * optionTextHeight)

    love.graphics.setColor(vars.TEXT_COLOR_DARK)

    -- background effects option
    love.graphics.print(
        'TRIPPY BACKGROUND',
        optionTextX,
        optionTextY + optionTextHeight * 0,
        0, 1, 1)

    local value = 'OFF'
    if _G.options.showBackgroundEffect == true then
      value = 'ON'
    end
    love.graphics.print(
        value,
        optionValueX,
        optionTextY + optionTextHeight * 0,
        0, 1, 1)

    -- start game
    love.graphics.print(
        'START GAME',
        optionTextX,
        optionTextY + optionTextHeight * 1,
        0, 1, 1)
  end

  -- draw canvas
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.setCanvas()

  love.graphics.draw(canvas, _G.CANVAS_X, 0, 0, _G.GRAPHICSSCALE, _G.GRAPHICSSCALE)
end
