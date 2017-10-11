love.math.setRandomSeed(math.floor(love.timer.getTime()))
love.graphics.setDefaultFilter('nearest', 'nearest')

local deepcopy = require('lib/deepcopy')

local function getData(packageName)
  return table.deepcopy(require(packageName))
end

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

local BLOCK_HEIGHT = 24
local BLOCK_WIDTH = 4

local totalPoints
local constellationPoints
local startingPointsForConstellation = 100
local lastConstellationConstant = nil
local score

local isGameOver = false

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

local function getColorToRgb(colorConstant)
  if colorConstant == COLOR_1 then
    return 0, 0, 255, 255
  elseif colorConstant == COLOR_2 then
    return 255, 0, 0, 255
  elseif colorConstant == COLOR_3 then
    return 0, 255, 0, 255
  elseif colorConstant == COLOR_4 then
    return 255, 0, 255, 255
  end
end

local fallingConstellation = newBlockConstellation()

local function resetGame()
  blocks = {}
  fallingConstellation = newBlockConstellation()

  totalPoints = 0
  constellationPoints = startingPointsForConstellation
  score = 0

  isGameOver = false
end

function love.load()
  love.graphics.setBackgroundColor(40, 40, 40, 255)

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
      if fallingBlock.y + y == BLOCK_HEIGHT then
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
  for y = 0, BLOCK_HEIGHT - 1 do
    local blockRowIndeces = {}
    for i, block in ipairs(blocks) do
      if block.y == y then
        table.insert(blockRowIndeces, i)
      end
    end
    if table.getn(blockRowIndeces) == BLOCK_WIDTH then
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
      print('GAME OVER')
      break
    end
  end

  -- add the points for the falling constellation
  if not isGameOver then
    totalPoints = totalPoints + constellationPoints
    constellationPoints = startingPointsForConstellation
    score = score + 1
  end

  -- get new controllable constellation
  local fallingConstellationConstant
  fallingConstellation, fallingConstellationConstant = newBlockConstellation()
  while fallingConstellationConstant == lastConstellationConstant do
    fallingConstellation, fallingConstellationConstant = newBlockConstellation()
  end
  lastConstellationConstant = fallingConstellationConstant
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

  love.graphics.scale(3)

  love.graphics.setColor(0, 0, 0, 255)

  love.graphics.rectangle('fill', 0, 0, 8 * 4, 8 * BLOCK_HEIGHT)

  love.graphics.rectangle('fill', 64, 8, 16, 16)

  for i,fallingBlock in ipairs(fallingConstellation) do
    love.graphics.setColor(getColorToRgb(fallingBlock.color))
    love.graphics.rectangle('fill', 64 + fallingBlock.x * 8, 8 + fallingBlock.y * 8, 8, 8)
  end  

  for i,block in ipairs(blocks) do
    love.graphics.setColor(getColorToRgb(block.color))
    love.graphics.rectangle('fill', block.x * 8, block.y * 8, 8, 8)
  end

  love.graphics.setColor(255, 255, 255, 255)

  love.graphics.print(totalPoints, 100, 100)

  love.graphics.setColor(255, 255, 0, 255)

  love.graphics.print(score, 100, 120)
end

