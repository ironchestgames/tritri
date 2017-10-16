
love.graphics.setDefaultFilter('nearest', 'nearest')

local stateswitcher = require('stateswitcher')
local vars = require('vars')

local SCREENWIDTH
local SCREENHEIGHT
local GRAPHICSSCALE
local CANVAS_X

local bgImage
local canvas
local font

local textBlinkDuration = 0.3
local textBlinkCount = textBlinkDuration
local textBlinkIsOn = true

function love.load()

  -- hide mouse pointer
  love.mouse.setVisible(false)

  -- load images
  bgImage = love.graphics.newImage('art/splash_bg.png')

  -- load font
  font = love.graphics.newImageFont('art/font.png', vars.GLYPHS)
  love.graphics.setFont(font)

  -- get desktop dimensions and graphics scale
  do
    local _, _, flags = love.window.getMode()
    SCREENWIDTH, SCREENHEIGHT = love.window.getDesktopDimensions(flags.display)

    -- NOTE: assume screen width is larger than screen height
    GRAPHICSSCALE = SCREENHEIGHT / bgImage:getHeight()
    CANVAS_X = (SCREENWIDTH - bgImage:getWidth() * GRAPHICSSCALE) / 2

    love.window.setFullscreen(true)
  end

  canvas = love.graphics.newCanvas()

  love.graphics.setBackgroundColor(155, 173, 183)

end

function love.keyreleased(key)
  stateswitcher.switch('gameScene', {})
end

function love.update(dt)
  textBlinkCount = textBlinkCount - dt

  if textBlinkCount < 0 then
    textBlinkCount = textBlinkDuration
    textBlinkIsOn = not textBlinkIsOn
  end
end

function love.draw()

  love.graphics.setColor(255, 255, 255, 255)

  love.graphics.setCanvas(canvas)

  love.graphics.clear()

  love.graphics.draw(bgImage, 0, 0)

  if textBlinkIsOn then
    love.graphics.setColor(vars.TEXT_COLOR_DARK)
    love.graphics.print('PRESS ANY KEY', 51, 103, 0, 2, 2)
  end

  -- draw canvas
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.setCanvas()

  love.graphics.draw(canvas, CANVAS_X, 0, 0, GRAPHICSSCALE, GRAPHICSSCALE)
end
