
love.graphics.setDefaultFilter('nearest', 'nearest')

local stateswitcher = require('stateswitcher')

local SCREENWIDTH
local SCREENHEIGHT
local GRAPHICSSCALE
local CANVAS_X

local bgImage
local textImg
local canvas

local textBlinkDuration = 0.3
local textBlinkCount = textBlinkDuration
local textBlinkIsOn = true

function love.load()

  -- hide mouse pointer
  love.mouse.setVisible(false)

  -- load images
  bgImage = love.graphics.newImage('art/splash_bg.png')
  textImg = love.graphics.newImage('art/splash_text.png')

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
  stateswitcher.switch('gameScene')
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
    love.graphics.draw(textImg, 0, 0)
  end

  -- draw canvas
  love.graphics.setCanvas()

  love.graphics.draw(canvas, CANVAS_X, 0, 0, GRAPHICSSCALE, GRAPHICSSCALE)
end
