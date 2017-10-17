
local anim8 = require('anim8')
local stateswitcher = require('stateswitcher')
local vars = require('vars')

local bgImage
local blockAnimationImage
local canvas
local font

local animations = {}

local textBlinkDuration = 0.3
local textBlinkCount = textBlinkDuration
local textBlinkIsOn = true

local logoBlockPositions = {
  -- T
  {24, 32},
  {32, 32},
  {40, 32},
  {32, 40},
  {32, 48},
  {32, 56},

  -- R
  {56, 32},
  {64, 32},
  {56, 40},
  {72, 40},
  {56, 48},
  {64, 48},
  {56, 56},
  {72, 56},

  -- I
  {88, 32},
  {96, 32},
  {104, 32},
  {96, 40},
  {96, 48},
  {88, 56},
  {96, 56},
  {104, 56},

  -- T
  {120, 32},
  {128, 32},
  {136, 32},
  {128, 40},
  {128, 48},
  {128, 56},

  -- R
  {152, 32},
  {160, 32},
  {152, 40},
  {168, 40},
  {152, 48},
  {160, 48},
  {152, 56},
  {168, 56},

  -- I
  {184, 32},
  {192, 32},
  {200, 32},
  {192, 40},
  {192, 48},
  {184, 56},
  {192, 56},
  {200, 56},
}

function love.load()

  -- load images
  bgImage = love.graphics.newImage('art/splash_bg.png')
  blockAnimationImage = love.graphics.newImage('art/blockanim.png')

  -- load font
  font = love.graphics.newImageFont('art/font.png', vars.GLYPHS)
  love.graphics.setFont(font)

  canvas = love.graphics.newCanvas()

  love.graphics.setBackgroundColor(155, 173, 183)

  local animationDurations = {}

  for i, v in ipairs(logoBlockPositions) do
    table.insert(animationDurations, 0.15 + 0.001 * i)
  end

  -- create logo animations
  for i, v in ipairs(logoBlockPositions) do
    local g = anim8.newGrid(8, 8, blockAnimationImage:getWidth(), blockAnimationImage:getHeight())
    local animation = anim8.newAnimation(g('1-7', 1), animationDurations[i])
    table.insert(animations, animation)
  end

end

function love.keyreleased(key)
  stateswitcher.switch('optionsScene')
end

function love.update(dt)

  -- update blink text
  textBlinkCount = textBlinkCount - dt

  if textBlinkCount < 0 then
    textBlinkCount = textBlinkDuration
    textBlinkIsOn = not textBlinkIsOn
  end

  -- update animations
  for i, animation in ipairs(animations) do
    animation:update(dt)
  end

end

function love.draw()

  love.graphics.setColor(255, 255, 255, 255)

  love.graphics.setCanvas(canvas)

  love.graphics.clear()

  love.graphics.draw(bgImage, 0, 0)

  for i, blockPosition in ipairs(logoBlockPositions) do
    animations[i]:draw(blockAnimationImage, blockPosition[1], blockPosition[2])
  end

  if textBlinkIsOn then
    love.graphics.setColor(vars.TEXT_COLOR_DARK)
    love.graphics.print('PRESS ANY KEY', 51, 103, 0, 2, 2)
  end

  -- draw canvas
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.setCanvas()

  love.graphics.draw(canvas, _G.CANVAS_X, 0, 0, _G.GRAPHICSSCALE, _G.GRAPHICSSCALE)
end
