
local anim8 = require('anim8')
local jupiter = require('jupiter')
local stateswitcher = require('stateswitcher')
local vars = require('vars')

local bgImage
local bgAnimationImage
local selectionImage
local canvas
local font

local backgroundAnimations = {}

local selectionIndex = 2 -- NOTE: start at 'start game'
local selectionMaxIndex = 3

function love.load()

  -- load images
  bgImage = love.graphics.newImage('art/options_bg.png')
  selectionImage = love.graphics.newImage('art/options_selection.png')
  bgAnimationImage = love.graphics.newImage('art/splash_bg_blockanim.png')

  -- load font
  font = love.graphics.newImageFont('art/font.png', vars.GLYPHS)
  love.graphics.setFont(font)

  canvas = love.graphics.newCanvas()

  love.graphics.setBackgroundColor(155, 173, 183)

  -- create background effect
  do
    local widthInBlocks = (_G.SCREENWIDTH / _G.GRAPHICSSCALE) / 8 + 8
    local heightInBlocks = (_G.SCREENHEIGHT / _G.GRAPHICSSCALE) / 8 + 8

    for y = 0, heightInBlocks do
      for x = 0, widthInBlocks do
        local g = anim8.newGrid(8, 8, bgAnimationImage:getWidth(), bgAnimationImage:getHeight())
        local animation = anim8.newAnimation(g('1-3', 1), 1)
        animation:gotoFrame(love.math.random(1, 3))
        table.insert(backgroundAnimations, {
          animation = animation,
          x = x * 8 - 3,
          y = y * 8 - 3,
        })
      end
    end
  end

end

function love.keyreleased(key)

  if key == 'space' or key == 'return' or key == 'z' or key == 'left' or key == 'right' then

    if selectionIndex == 0 then
      _G.options.showBackgroundEffect = not _G.options.showBackgroundEffect
    elseif selectionIndex == 1 then
      local optionFileSaveSuccess = jupiter.save(_G.options)
      stateswitcher.switch('highscoreScene')
    elseif selectionIndex == 2 then
      local optionFileSaveSuccess = jupiter.save(_G.options)
      stateswitcher.switch('gameScene')
    elseif selectionIndex == 3 then
      love.event.quit()
    end

  elseif key == 'up' then
    selectionIndex = selectionIndex - 1
  elseif key == 'down' then
    selectionIndex = selectionIndex + 1
  end

  if selectionIndex < 0 then
    selectionIndex = selectionMaxIndex
  elseif selectionIndex > selectionMaxIndex then
    selectionIndex = 0
  end
end

function love.keypressed()
end

function love.update(dt)
  
end

function love.draw()

  -- draw background
  love.graphics.setColor(255, 255, 255, 255)

  love.graphics.push()

  love.graphics.scale(_G.GRAPHICSSCALE, _G.GRAPHICSSCALE)

  for i, object in ipairs(backgroundAnimations) do
    object.animation:draw(bgAnimationImage, object.x, object.y)
  end

  love.graphics.pop()

  love.graphics.setCanvas(canvas)

  love.graphics.clear()

  love.graphics.draw(bgImage, 0, 0)

  -- options
  do
    local optionTextX = 26
    local optionTextY = 55
    local optionTextHeight = 35
    local optionValueX = 195

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

    -- highscore
    love.graphics.print(
        'HIGHSCORE',
        optionTextX + 67,
        optionTextY + optionTextHeight * 1,
        0, 1, 1)

    -- start game
    love.graphics.print(
        'START GAME',
        optionTextX + 64,
        optionTextY + optionTextHeight * 2,
        0, 1, 1)

    -- exit game
    love.graphics.print(
        'EXIT GAME',
        optionTextX + 67,
        optionTextY + optionTextHeight * 3,
        0, 1, 1)
  end

  -- draw canvas
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.setCanvas()

  love.graphics.draw(canvas, _G.CANVAS_X, 0, 0, _G.GRAPHICSSCALE, _G.GRAPHICSSCALE)
end
