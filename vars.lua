
local vars = {}

-- fonts
vars.GLYPHS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890.,:;!?()[]+-÷\\/•*\'" Ø'

-- colors
vars.TEXT_COLOR_DARK = {34, 32, 52, 255}
vars.TEXT_COLOR_LIGHT = {255, 255, 255, 255}
vars.TEXT_COLOR_SCORE_1 = {251, 242, 54, 255}
vars.TEXT_COLOR_SCORE_2 = {255, 255, 255, 255}
vars.TEXT_COLOR_SCORE_3 = {223, 113, 38, 255}

-- options
vars.OPTIONS_FILE_NAME = 'options.conf'
vars.DEFAULT_OPTIONS = {
  _fileName = vars.OPTIONS_FILE_NAME,
  showBackgroundEffect = false,
  playMusic = true,
  playSoundEffects = true,
}

-- highscore file
vars.HIGHSCORE_FILE_NAME = 'highscores.file'

return vars
