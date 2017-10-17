local jupiter = require('jupiter')
local stateswitcher = require('stateswitcher')
local vars = require('vars')

love.graphics.setDefaultFilter('nearest', 'nearest')

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

-- load options file
do
  _G.options = jupiter.load(vars.OPTIONS_FILE_NAME)

  if _G.options == nil then
    _G.options = {}
  end

  -- copy default values where no value was found
  for k, v in pairs(vars.DEFAULT_OPTIONS) do
    if _G.options[k] == nil then
      _G.options[k] = v
    end
  end

  -- fix all booleans
  for k, v in pairs(_G.options) do
    if v == 'true' then
      _G.options[k] = true
    elseif v == 'false' then
      _G.options[k] = false
    end
  end

end

stateswitcher.switch('splashScene')
