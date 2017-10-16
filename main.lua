
local stateswitcher = require('stateswitcher')

-- hide mouse pointer
love.mouse.setVisible(false)

-- get desktop dimensions and graphics scale
do
  local _, _, flags = love.window.getMode()
  _G.SCREENWIDTH, _G.SCREENHEIGHT = love.window.getDesktopDimensions(flags.display)

  local bgImage = love.graphics.newImage('art/splash_bg.png')

  -- NOTE: assume screen width is larger than screen height
  _G.GRAPHICSSCALE = SCREENHEIGHT / bgImage:getHeight()
  _G.CANVAS_X = (SCREENWIDTH - bgImage:getWidth() * GRAPHICSSCALE) / 2

  love.window.setFullscreen(true)
end

stateswitcher.switch('splashScene', {})
