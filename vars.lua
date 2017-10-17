
local vars = {}

-- fonts
vars.GLYPHS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890.,:;!?()[]+-÷\\/•*\'" Ø'

-- colors
vars.TEXT_COLOR_DARK = {34, 32, 52, 255}

-- options
vars.OPTIONS_FILE_NAME = 'options.conf'
vars.DEFAULT_OPTIONS = {
  _fileName = vars.OPTIONS_FILE_NAME,
  showBackgroundEffect = false,
}

-- highscore file
vars.HIGHSCORE_FILE_NAME = 'highscores.file'

return vars
