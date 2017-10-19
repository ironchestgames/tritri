
local anim8 = require('anim8')
local jupiter = require('jupiter')
local stateswitcher = require('stateswitcher')
local vars = require('vars')

local music

local bgImage
local blockAnimationImage
local canvas
local font

local savedScores

local backgroundPositions = {}
local backgroundAnimations = {}

function love.load()

  _G.menuMusic:stop()

  -- load music
  music = love.audio.newSource('assetsources/music_highscore.wav')
  music:rewind()
  music:setLooping(true)

  if _G.options.playMusic == true then
    music:play()
  end

  -- load images
  bgImage = love.graphics.newImage('art/highscore_layout.png')
  blockAnimationImage = love.graphics.newImage('art/highscore_blockanim.png')

  -- load font
  font = love.graphics.newImageFont('art/font.png', vars.GLYPHS)
  love.graphics.setFont(font)

  canvas = love.graphics.newCanvas()

  -- set background effect
  love.graphics.setBackgroundColor(155, 173, 183)

  do
    local widthInBlocks = (_G.SCREENWIDTH / _G.GRAPHICSSCALE) / 8 + 8
    local heightInBlocks = (_G.SCREENHEIGHT / _G.GRAPHICSSCALE) / 8 + 8

    for y = 0, heightInBlocks do
      for x = 0, widthInBlocks do
        local g = anim8.newGrid(8, 8, blockAnimationImage:getWidth(), blockAnimationImage:getHeight())
        local animation = anim8.newAnimation(g('1-8', 1), 0.30 + love.math.random(1, 2) * 0.0016)
        animation:update(0.08 * (y + 1) + 0.03 * x)
        table.insert(backgroundAnimations, {
          animation = animation,
          x = x * 8 - 3,
          y = y * 8 - 3,
        })
      end
    end
  end

  -- load scores
  savedScores = jupiter.load(vars.HIGHSCORE_FILE_NAME)

  if savedScores == nil then
    savedScores = {}
  end

end

function love.keypressed()
end

function love.keyreleased(key)

  -- stop highscore music
  music:stop()

  -- start menu music
  _G.menuMusic:rewind()
  _G.menuMusic:play()

  stateswitcher.switch('optionsScene')
end

function love.update(dt)
  for i, object in ipairs(backgroundAnimations) do
    object.animation:update(dt)
  end
end

function love.draw()

  love.graphics.setColor(255, 255, 255, 255)

  love.graphics.push()

  love.graphics.scale(_G.GRAPHICSSCALE, _G.GRAPHICSSCALE)

  for i, object in ipairs(backgroundAnimations) do
    object.animation:draw(blockAnimationImage, object.x, object.y)
  end

  love.graphics.pop()

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
        38,
        60 + 13 * (i - 1),
        100,
        'right')
  end

  -- draw canvas
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.setCanvas()

  love.graphics.draw(canvas, _G.CANVAS_X, 0, 0, _G.GRAPHICSSCALE, _G.GRAPHICSSCALE)
end
