love.math.setRandomSeed(math.floor(love.timer.getTime()))
love.graphics.setDefaultFilter('nearest', 'nearest')

local SCREENWIDTH
local SCREENHEIGHT

local blocks = {}

local CONSTELLATION_3_6 = 'CONSTELLATION_3_6'
local CONSTELLATION_6_9 = 'CONSTELLATION_6_9'
local CONSTELLATION_9_12 = 'CONSTELLATION_9_12'
local CONSTELLATION_12_3 = 'CONSTELLATION_12_3'

local COLOR_1 = 'COLOR_1'
local COLOR_2 = 'COLOR_2'
local COLOR_3 = 'COLOR_3'
local COLOR_4 = 'COLOR_4'

local constellationConstants = {
  CONSTELLATION_3_6,
  CONSTELLATION_6_9,
  CONSTELLATION_9_12,
  CONSTELLATION_12_3,
}

local PLAYAREA_HEIGHT_IN_BLOCKS = 24
local PLAYAREA_WIDTH_IN_BLOCKS = 4

local totalPoints
local constellationPoints
local startingPointsForConstellation = 100
local lastConstellationConstant = nil
local score
local fallingConstellation
local nextConstellation

local isGameOver = false

local blockImages = {}
local backgroundImage

local canvas
local font
local FONT_COLOR = {34, 32, 52}

function newBlockConstellation()
  local constellationConstant = constellationConstants[love.math.random(table.getn(constellationConstants))]
  local constellation

  if constellationConstant == CONSTELLATION_3_6 then
    constellation = {
      {
        color = COLOR_1,
        x = 0,
        y = 0,
      },
      {
        color = COLOR_1,
        x = 1,
        y = 0,
      },
      {
        color = COLOR_1,
        x = 0,
        y = 1,
      },
    }
  elseif constellationConstant == CONSTELLATION_6_9 then
    constellation = {
      {
        color = COLOR_2,
        x = 0,
        y = 0,
      },
      {
        color = COLOR_2,
        x = 1,
        y = 0,
      },
      {
        color = COLOR_2,
        x = 1,
        y = 1,
      },
    }
  elseif constellationConstant == CONSTELLATION_9_12 then
    constellation = {
      {
        color = COLOR_3,
        x = 1,
        y = 0,
      },
      {
        color = COLOR_3,
        x = 1,
        y = 1,
      },
      {
        color = COLOR_3,
        x = 0,
        y = 1,
      },
    }
  elseif constellationConstant == CONSTELLATION_12_3 then
    constellation = {
      {
        color = COLOR_4,
        x = 0,
        y = 0,
      },
      {
        color = COLOR_4,
        x = 0,
        y = 1,
      },
      {
        color = COLOR_4,
        x = 1,
        y = 1,
      },
    }
  end

  return constellation, constellationConstant

end

local function resetGame()
  blocks = {}

  nextConstellation = newBlockConstellation()
  fallingConstellation = newBlockConstellation() -- TODO: make this not the same as next

  totalPoints = 0
  constellationPoints = startingPointsForConstellation
  score = 0

  isGameOver = false
end

function love.load()

  -- hide mouse pointer
  love.mouse.setVisible(false)

  font = love.graphics.newImageFont('art/font.png',
    'ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890.,:;!?()[]+-÷\\/•*\'" ')

  backgroundImage = love.graphics.newImage('art/bg.png')

  blockImages[COLOR_1] = love.graphics.newImage('art/block1.png')
  blockImages[COLOR_2] = love.graphics.newImage('art/block2.png')
  blockImages[COLOR_3] = love.graphics.newImage('art/block3.png')
  blockImages[COLOR_4] = love.graphics.newImage('art/block4.png')

  -- get desktop dimensions and graphics scale
  do
    local _, _, flags = love.window.getMode()
    SCREENWIDTH, SCREENHEIGHT = love.window.getDesktopDimensions(flags.display)

    -- NOTE: assume screen width is larger than screen height
    GRAPHICSSCALE = SCREENHEIGHT / backgroundImage:getHeight()
    CANVAS_X = (SCREENWIDTH - backgroundImage:getWidth() * GRAPHICSSCALE) / 2

    love.window.setFullscreen(true)
  end

  love.graphics.setBackgroundColor(40, 40, 40, 255)

  love.graphics.setFont(font)

  canvas = love.graphics.newCanvas()

  resetGame()
end

function love.keypressed(key)

  if isGameOver then
    resetGame()
    return
  end

  -- consider input
  if key == 'left' then
    -- pass
  elseif key == 'down' then
    for i,fallingBlock in ipairs(fallingConstellation) do
      fallingBlock.x = fallingBlock.x + 1
    end
  elseif key == 'right' then
    for i,fallingBlock in ipairs(fallingConstellation) do
      fallingBlock.x = fallingBlock.x + 2
    end
  else
    return
  end

  -- find max y to put controllable constellation
  local isFallingConstellationColliding = function (y)
    for i,fallingBlock in ipairs(fallingConstellation) do
      if fallingBlock.y + y == PLAYAREA_HEIGHT_IN_BLOCKS then
        return true
      end
      for j,block in ipairs(blocks) do
        if fallingBlock.x == block.x and fallingBlock.y + y == block.y then
          return true
        end
      end
    end
    return false
  end

  local collisionY = -1

  while not isFallingConstellationColliding(collisionY) do
    collisionY = collisionY + 1
  end

  -- put controllable constellation down
  for i,fallingBlock in ipairs(fallingConstellation) do
    fallingBlock.y = fallingBlock.y + collisionY - 1
    fallingBlock.x = fallingBlock.x
    table.insert(blocks, fallingBlock)
  end

  -- remove full block lines
  for y = 0, PLAYAREA_HEIGHT_IN_BLOCKS - 1 do
    local blockRowIndeces = {}
    for i, block in ipairs(blocks) do
      if block.y == y then
        table.insert(blockRowIndeces, i)
      end
    end
    if table.getn(blockRowIndeces) == PLAYAREA_WIDTH_IN_BLOCKS then
      table.sort(blockRowIndeces)
      for i = table.getn(blockRowIndeces), 1, -1 do
        table.remove(blocks, blockRowIndeces[i])
      end

      -- move them down one row
      for i,block in ipairs(blocks) do
        if block.y < y then
          block.y = block.y + 1
        end
      end
    end
  end

  -- check for game over
  for i,block in ipairs(blocks) do
    if block.y < 0 then
      isGameOver = true
      print('GAME OVER - score ' .. score)
      break
    end
  end

  -- add the points for the falling constellation
  if not isGameOver then
    totalPoints = totalPoints + constellationPoints
    constellationPoints = startingPointsForConstellation
    score = score + 1
  end

  -- next constellation to become falling
  fallingConstellation = nextConstellation

  -- get next constellation
  local nextConstellationConstant
  nextConstellation, nextConstellationConstant = newBlockConstellation()
  while nextConstellationConstant == lastConstellationConstant do
    nextConstellation, nextConstellationConstant = newBlockConstellation()
  end
  lastConstellationConstant = nextConstellationConstant
end

function love.keyreleased(key)
end

function love.update(dt)
  -- TODO: subtract from constellationPoints
  if not isGameOver then
    constellationPoints = constellationPoints - 1
    if constellationPoints < 0 then
      constellationPoints = 0
    end
  end
end

function love.draw()

  love.graphics.setCanvas(canvas)

  love.graphics.setColor(255, 255, 255, 255)

  love.graphics.draw(backgroundImage, 0, 0)

  for i,nextBlock in ipairs(nextConstellation) do
    love.graphics.draw(blockImages[nextBlock.color], 83 + nextBlock.x * 8, 11 + nextBlock.y * 8)
  end

  for i,fallingBlock in ipairs(fallingConstellation) do
    love.graphics.draw(blockImages[fallingBlock.color], 128 + fallingBlock.x * 8, 11 + fallingBlock.y * 8)
  end  

  for i,block in ipairs(blocks) do
    love.graphics.draw(blockImages[block.color], 120 + block.x * 8, 45 + block.y * 8)
  end

  -- love.graphics.print(totalPoints, 100, 100)

  -- love.graphics.setColor(255, 255, 0, 255)

  love.graphics.setColor(FONT_COLOR)

  love.graphics.print(score, 76, 45)

  love.graphics.setCanvas()

  love.graphics.setColor(255, 255, 255, 255)

  love.graphics.draw(canvas, CANVAS_X, 0, 0, GRAPHICSSCALE, GRAPHICSSCALE)

end

