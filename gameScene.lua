love.math.setRandomSeed(math.floor(love.timer.getTime()))

local anim8 = require('anim8')
local jupiter = require('jupiter')
local stateswitcher = require('stateswitcher')
local vars = require('vars')

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

local accPoints
local constellationPoints
local averagePoints
local startingPointsForConstellation = 100
local lastConstellationConstant = nil
local blockScore
local rowScore
local totalPoints -- NOTE: accPoints * (rowScore + blockScore)
local fallingConstellation
local nextConstellation
local secondToNextConstellation

local isGameOver = false

local blockImages = {}
local backgroundImage -- NOTE: only a colored pixel
local playAreaImage
local speedBonusFillImage
local arrowImages = {}
local nextArrowImage
local gameOverBlockImage
local gameOverBlockAnimation
local gameOverTextImage
local gameOverTextAnimation
local fallingConstellationParticleSystem
local bgCanvas
local bgParticleSystem

local bgColor = {255, 0, -255, 255}
local bgColorFactors = {-1, 1, 1}
local bgColorCount = 0
local lastPressedArrow
local arrowFadeDuration = 0.55
local arrowFadeCount = 0
local gameCanvas
local font
local BG_COLOR = {155, 173, 183}
local gameOverBgFadeCount = 0
local gameOverBgFadeDuration = 0.3
local showBackgroundEffect = true

function fadeColor(
  time, prologue, attack, sustain, decay, epilogue,
  fade_in_r, fade_in_g, fade_in_b,
  fade_out_r, fade_out_g, fade_out_b
)
  -- [0, prologue)
  if time < prologue then
    return
      fade_in_r,
      fade_in_g,
      fade_in_b,
      255
  end
 
  -- (prologue, prologue + attack]
  time = time - prologue
  if time < attack then
    return
      fade_in_r,
      fade_in_g,
      fade_in_b,
      ( math.cos( time / attack * math.pi ) + 1 ) / 2 * 255
  end
 
  -- (prologue + attack, prologue + attack + sustain]
  time = time - attack
  if time < sustain then
    return
      fade_in_r,
      fade_in_g,
      fade_in_b,
      0
  end
 
  -- (prologue + attack + sustain, prologue + attack + sustain + decay]
  time = time - sustain
  if time < decay then
    return
      fade_out_r,
      fade_out_g,
      fade_out_b,
      255 - ( ( math.cos( time / decay * math.pi ) + 1 ) / 2 * 255 )
  end
 
  -- (prologue + attack + sustain + decay, prologue + attack + sustain + decay + epilogue]
  time = time - decay
  if time < epilogue then
    return
      fade_out_r,
      fade_out_g,
      fade_out_b,
      255
  end
 
  -- End of fading, return all nils.
end

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

  secondToNextConstellation = newBlockConstellation()
  nextConstellation = newBlockConstellation()
  fallingConstellation = newBlockConstellation() -- TODO: make this not the same as next

  accPoints = 0
  averagePoints = 0
  constellationPoints = startingPointsForConstellation
  blockScore = 0
  rowScore = 0
  totalPoints = 0

  isGameOver = false
  gameOverBgFadeCount = gameOverBgFadeDuration

  love.graphics.setBackgroundColor(BG_COLOR)

end

function love.load()

  -- set flags from options
  showBackgroundEffect = _G.options.showBackgroundEffect

  -- hide mouse pointer
  love.mouse.setVisible(false)

  font = love.graphics.newImageFont('art/font.png', vars.GLYPHS)

  backgroundImage = love.graphics.newImage('art/bg.png')
  playAreaImage = love.graphics.newImage('art/playarea_clean.png')

  speedBonusFillImage = love.graphics.newImage('art/lightbluepixel.png')

  blockImages[COLOR_1] = love.graphics.newImage('art/block1.png')
  blockImages[COLOR_2] = love.graphics.newImage('art/block2.png')
  blockImages[COLOR_3] = love.graphics.newImage('art/block3.png')
  blockImages[COLOR_4] = love.graphics.newImage('art/block4.png')

  arrowImages['left'] = love.graphics.newImage('art/arrow_left.png')
  arrowImages['down'] = love.graphics.newImage('art/arrow_middle.png')
  arrowImages['right'] = love.graphics.newImage('art/arrow_right.png')

  nextArrowImage = love.graphics.newImage('art/nextarrow.png')

  gameOverBlockImage = love.graphics.newImage('art/gameoverblockanim.png')
  local g = anim8.newGrid(8, 8, gameOverBlockImage:getWidth(), gameOverBlockImage:getHeight())
  gameOverBlockAnimation = anim8.newAnimation(g('1-3', 1), 0.05)

  gameOverTextImage = love.graphics.newImage('art/gameovertext.png')
  local g = anim8.newGrid(102, 60, gameOverTextImage:getWidth(), gameOverTextImage:getHeight())
  gameOverTextAnimation = anim8.newAnimation(g('1-3', 1), 0.05)

  local particleImage = love.graphics.newImage('art/whitepixel.png')
  fallingConstellationParticleSystem = love.graphics.newParticleSystem(particleImage, 32)
  fallingConstellationParticleSystem:setParticleLifetime(0.2, 0.4)
  fallingConstellationParticleSystem:setEmissionRate(100)
  fallingConstellationParticleSystem:setSizeVariation(1)
  fallingConstellationParticleSystem:setSpeed(-350, 350)
  fallingConstellationParticleSystem:setColors(255, 255, 255, 255, 255, 255, 255, 150, 69, 40, 60, 0)
  fallingConstellationParticleSystem:setLinearDamping(10)
  fallingConstellationParticleSystem:setAreaSpread('normal', 7, 0)

  local bgParticleImage = love.graphics.newImage('art/bg_whitepixel.png')
  bgParticleSystem = love.graphics.newParticleSystem(bgParticleImage, 200)
  bgParticleSystem:setParticleLifetime(10, 20)
  bgParticleSystem:setEmissionRate(10)
  bgParticleSystem:setSizes(5, 25, 100, 150)
  bgParticleSystem:setSizeVariation(0)
  bgParticleSystem:setSpin(-math.pi / 2, math.pi / 2)
  bgParticleSystem:setAreaSpread('uniform', _G.SCREENWIDTH / _G.GRAPHICSSCALE, _G.SCREENHEIGHT / _G.GRAPHICSSCALE)
  bgParticleSystem:start()

  love.graphics.setBackgroundColor(BG_COLOR)

  love.graphics.setFont(font)

  gameCanvas = love.graphics.newCanvas()

  bgCanvas = love.graphics.newCanvas()

  for i=1, 30 do
    bgParticleSystem:update(1)
  end

  resetGame()
end

function love.keypressed(_key)

  local key = _key

  if key == 'escape' or key == 'q' then
    stateswitcher.switch('optionsScene')
    return
  end

  if isGameOver then
    resetGame()
    return
  end

  -- left-hand support
  if key == 'z' then
    key = 'left'
  elseif key == 'x' then
    key = 'down'
  elseif key == 'c' then
    key = 'right'
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

  -- start arrow fade
  lastPressedArrow = key
  arrowFadeCount = arrowFadeDuration

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

      rowScore = rowScore + 1

      table.sort(blockRowIndeces)
      for i = table.getn(blockRowIndeces), 1, -1 do
        table.remove(blocks, blockRowIndeces[i])
      end

      -- particle fx!
      fallingConstellationParticleSystem:reset()
      fallingConstellationParticleSystem:start()
      fallingConstellationParticleSystem:setPosition(120 + 16, 45 + y * 8 + 8)
      fallingConstellationParticleSystem:emit(120)
      fallingConstellationParticleSystem:stop()

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
      block.outOfBoundary = true
    end
  end

  if isGameOver then

    -- save scores
    local savedScores = jupiter.load(vars.HIGHSCORE_FILE_NAME)

    table.insert(savedScores, totalPoints)

    table.sort(savedScores, function (a, b) return a > b end)

    for i = 1, 10 do
      if savedScores[i] ~= nil then
        if savedScores[i] == totalPoints then
          -- TODO: flash you got highscore
        end
      end
    end

    jupiter.save({
      _fileName = vars.HIGHSCORE_FILE_NAME,
      unpack({
        savedScores[1],
        savedScores[2],
        savedScores[3],
        savedScores[4],
        savedScores[5],
        savedScores[6],
        savedScores[7],
        savedScores[8],
        savedScores[9],
        savedScores[10],
        })
    })
  end

  -- add the points for the falling constellation
  if not isGameOver then
    accPoints = accPoints + constellationPoints
    constellationPoints = startingPointsForConstellation
    blockScore = blockScore + 1

    averagePoints = math.ceil(accPoints / blockScore)

    totalPoints = (blockScore + rowScore) * accPoints
  end

  -- move next train forward
  fallingConstellation = nextConstellation
  nextConstellation = secondToNextConstellation

  -- get next constellation
  local nextConstellationConstant
  secondToNextConstellation, nextConstellationConstant = newBlockConstellation()
  while nextConstellationConstant == lastConstellationConstant do
    secondToNextConstellation, nextConstellationConstant = newBlockConstellation()
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

  -- update arrow fade
  arrowFadeCount = arrowFadeCount - dt

  -- update game over bg fade
  if isGameOver == true and gameOverBgFadeCount > 0 then
    gameOverBgFadeCount = gameOverBgFadeCount - dt
  end

  -- update particle systems
  fallingConstellationParticleSystem:update(dt)

  if isGameOver == false then
    bgParticleSystem:update(dt)

    bgColor[1] = bgColor[1] + dt * 0.1 * bgColorFactors[1]

    if bgColor[1] > 255 then
      bgColorFactors[1] = -1
    elseif bgColor[1] < -255 then
      bgColorFactors[1] = 1
    end

    bgColor[2] = bgColor[2] + dt * 0.096 * bgColorFactors[2]

    if bgColor[2] > 255 then
      bgColorFactors[2] = -1
    elseif bgColor[2] < -255 then
      bgColorFactors[2] = 1
    end

    bgColor[3] = bgColor[3] + dt * 0.111 * bgColorFactors[3]

    if bgColor[3] > 255 then
      bgColorFactors[3] = -1
    elseif bgColor[3] < -255 then
      bgColorFactors[3] = 1
    end

    bgParticleSystem:setColors(
        255, 255, 255, 0,
        bgColor[1], bgColor[2], bgColor[3], 255,
        255, 255, 255, 0)
  end

  -- update animations
  gameOverBlockAnimation:update(dt)
  gameOverTextAnimation:update(dt)

end

function love.draw()

  if isGameOver == true then

    local color = 255 * (gameOverBgFadeCount / gameOverBgFadeDuration)

    love.graphics.setColor(color, color, color, 255)

    love.graphics.setBackgroundColor(
        155 * (gameOverBgFadeCount / gameOverBgFadeDuration),
        173 * (gameOverBgFadeCount / gameOverBgFadeDuration),
        183 * (gameOverBgFadeCount / gameOverBgFadeDuration),
        255)

    love.graphics.setCanvas(gameCanvas)

    love.graphics.clear()

    love.graphics.draw(playAreaImage, 0, 0)

    love.graphics.setColor(255, 255, 255, 255)

    -- draw blocks in play area
    for i,block in ipairs(blocks) do
      love.graphics.draw(blockImages[block.color], 120 + block.x * 8, 45 + block.y * 8)
    end

    -- draw gameover blocks in play area
    for i,block in ipairs(blocks) do
      if block.outOfBoundary == true then
        gameOverBlockAnimation:draw(gameOverBlockImage, 120 + block.x * 8, 45 + block.y * 8)
      end
    end

    gameOverTextAnimation:draw(gameOverTextImage, 71, 107)

  else

    love.graphics.setCanvas(gameCanvas)

    love.graphics.clear()

    love.graphics.setColor(255, 255, 255, 255)

    love.graphics.draw(playAreaImage, 0, 0)

    -- draw arrows
    love.graphics.setColor(255, 255, 255, 255 * (arrowFadeCount / arrowFadeDuration))
    if lastPressedArrow ~= nil and arrowFadeCount > 0 then
      love.graphics.draw(arrowImages[lastPressedArrow], 120, 34)

      love.graphics.draw(nextArrowImage, 60, 10) -- NOTE: second to next
      love.graphics.draw(nextArrowImage, 105, 10) -- NOTE: next
    end

    love.graphics.setColor(255, 255, 255, 255)

    -- draw second to next block
    for i,nextBlock in ipairs(secondToNextConstellation) do
      love.graphics.draw(blockImages[nextBlock.color], 38 + nextBlock.x * 8, 11 + nextBlock.y * 8)
    end

    -- draw next block
    for i,nextBlock in ipairs(nextConstellation) do
      love.graphics.draw(blockImages[nextBlock.color], 83 + nextBlock.x * 8, 11 + nextBlock.y * 8)
    end

    -- draw falling block
    for i,fallingBlock in ipairs(fallingConstellation) do
      love.graphics.draw(blockImages[fallingBlock.color], 128 + fallingBlock.x * 8, 11 + fallingBlock.y * 8)
    end  

    -- draw blocks in play area
    for i,block in ipairs(blocks) do
      love.graphics.draw(blockImages[block.color], 120 + block.x * 8, 45 + block.y * 8)
    end

    -- draw labels
    love.graphics.setColor(vars.TEXT_COLOR_LIGHT)
    love.graphics.print('SCORE', 32, 37)
    love.graphics.print('SPEED BONUS', 32, 59)

    -- draw total score
    love.graphics.setColor(vars.TEXT_COLOR_DARK)
    love.graphics.printf(totalPoints, 31, 46, 74, 'right')

    -- draw speed bonus
    do
      local w = 77 * (constellationPoints / startingPointsForConstellation)
      local x = 30 + (77 - w)

      love.graphics.setColor(255, 255, 255, 255)
      love.graphics.draw(speedBonusFillImage, x, 67, 0, w, 11)
    end

    -- draw particle systems
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.draw(fallingConstellationParticleSystem, 0, 0)

    -- draw background effect
    love.graphics.setCanvas(bgCanvas)
    love.graphics.draw(bgParticleSystem, playAreaImage:getWidth() / 2, playAreaImage:getHeight() / 2)

  end

  -- draw canvases
  love.graphics.setCanvas()

  -- draw background effect
  if showBackgroundEffect == true then
    love.graphics.setColor(255, 255, 255, 200)
    love.graphics.draw(bgCanvas, 0, 0, 0, _G.GRAPHICSSCALE, _G.GRAPHICSSCALE)
  end

  -- draw game canvas
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.draw(gameCanvas, _G.CANVAS_X, 0, 0, _G.GRAPHICSSCALE, _G.GRAPHICSSCALE)

end

