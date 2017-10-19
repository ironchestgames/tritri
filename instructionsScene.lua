
local anim8 = require('anim8')
local stateswitcher = require('stateswitcher')
local vars = require('vars')

local bgImage
local bgAnimationImage
local canvas

local animations = {}
local backgroundAnimations = {}

function love.load()

  -- load images
  bgImage = love.graphics.newImage('art/instructions_bg.png')
  bgAnimationImage = love.graphics.newImage('art/splash_bg_blockanim.png')

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
  if key == 'q' or
      key == 'space' or
      key == 'return' or
      key == 'escape' or
      key == 'backspace' then
    stateswitcher.switch('optionsScene')
  end
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

  -- draw on canvas
  love.graphics.setCanvas(canvas)

  love.graphics.clear()

  love.graphics.draw(bgImage, 0, 0)

  -- draw canvas
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.setCanvas()

  love.graphics.draw(canvas, _G.CANVAS_X, _G.CANVAS_Y, 0, _G.GRAPHICSSCALE, _G.GRAPHICSSCALE)
end

