-- Rex's generated palette: ANSI accents at 0–15, background-to-foreground
-- shades at 232–255 (in both light and dark themes). No RGB colors are cached.
vim.cmd 'highlight clear'
vim.o.termguicolors = false
vim.g.colors_name = 'rex'

local function hi(names, value)
  for name in names:gmatch '%S+' do
    vim.api.nvim_set_hl(0, name, value)
  end
end
local function link(names, target) hi(names, { link = target }) end

-- Inherit the actual default colors, which are distinct from ANSI black/white.
hi('Normal NormalNC SignColumn MsgArea', {})
hi('Cursor TermCursor', { reverse = true })
hi('CursorLine CursorColumn ColorColumn', { ctermbg = 232 })
hi('CursorLineNr', { bold = true })
hi('LineNr LineNrAbove LineNrBelow', { ctermfg = 246 })
hi('NonText Whitespace EndOfBuffer', { ctermfg = 240 })
hi('WinSeparator VertSplit', { ctermfg = 237 })
hi('Visual VisualNOS', { ctermbg = 236 })
hi('Search', { ctermfg = 232, ctermbg = 3 })
hi('IncSearch CurSearch', { ctermfg = 232, ctermbg = 6, bold = true })
hi('Substitute', { ctermfg = 232, ctermbg = 1 })
hi('MatchParen', { ctermbg = 235, bold = true })
hi('StatusLine', { ctermfg = 255, ctermbg = 234 })
hi('StatusLineNC', { ctermfg = 249, ctermbg = 232 })
hi('WinBar', { bold = true })
hi('WinBarNC', { ctermfg = 248 })
link('TabLine TabLineFill', 'StatusLineNC')
link('TabLineSel', 'StatusLine')
hi('NormalFloat Pmenu', { ctermbg = 233 })
hi('FloatBorder', { ctermfg = 240, ctermbg = 233 })
hi('FloatTitle', { ctermfg = 4, ctermbg = 233, bold = true })
hi('FloatFooter', { ctermfg = 248, ctermbg = 233 })
hi('PmenuSel', { ctermbg = 237, bold = true })
hi('PmenuSbar', { ctermbg = 235 })
hi('PmenuThumb', { ctermbg = 244 })
hi('PmenuMatch', { ctermfg = 6, bold = true })
link('PmenuMatchSel', 'PmenuMatch')
hi('PmenuExtra PmenuKind', { ctermfg = 248, ctermbg = 233 })
hi('PmenuExtraSel PmenuKindSel', { ctermfg = 255, ctermbg = 237 })
link('WildMenu', 'PmenuSel')
hi('Folded', { ctermfg = 248, ctermbg = 232 })
link('FoldColumn', 'LineNr')
hi('Title Directory', { ctermfg = 4, bold = true })
hi('Conceal', { ctermfg = 248 })
hi('QuickFixLine', { ctermbg = 235 })
hi('ModeMsg MoreMsg Question', { ctermfg = 6, bold = true })
hi('Error ErrorMsg', { ctermfg = 1 })
hi('WarningMsg', { ctermfg = 3 })

-- Syntax and Treesitter. CursorLine sets only a background, preserving these.
hi('Comment', { ctermfg = 248 })
hi('String Character', { ctermfg = 2 })
hi('Number Float', { ctermfg = 6 })
hi('Constant Boolean', { ctermfg = 5 })
hi('Identifier Operator Delimiter', {})
hi('Function', { ctermfg = 4 })
hi('Statement Keyword', { ctermfg = 5 })
hi('PreProc', { ctermfg = 4 })
hi('Type', { ctermfg = 3 })
hi('Special', { ctermfg = 6 })
hi('Underlined', { ctermfg = 6, underline = true })
hi('Todo', { ctermfg = 3, bold = true })
hi('Bold', { bold = true })
hi('Italic', {})
link('Conditional Repeat Label Exception', 'Statement')
link('Include Define Macro PreCondit', 'PreProc')
link('StorageClass Structure Typedef', 'Type')
link('SpecialChar Tag SpecialComment Debug', 'Special')
link('Ignore SpecialKey', 'NonText')
link('@comment @comment.documentation', 'Comment')
link('@variable @variable.parameter @variable.member', 'Identifier')
link('@variable.builtin @constant.builtin @constant.macro', 'Constant')
link('@function @function.call @function.method @function.method.call @function.builtin @constructor', 'Function')
link('@function.macro @keyword.import @keyword.directive', 'PreProc')
link('@keyword @keyword.function @keyword.return @keyword.operator', 'Keyword')
link('@type @type.builtin @type.definition @module', 'Type')
link('@string @string.documentation', 'String')
link('@string.escape @string.regexp @string.special', 'Special')
link('@number @number.float', 'Number')
link('@boolean', 'Boolean')
link('@operator @punctuation @punctuation.bracket @punctuation.delimiter', 'Delimiter')
link('@attribute @label @tag @tag.attribute', 'Special')
link('@markup.heading', 'Title')
link('@markup.raw', 'String')
link('@markup.quote', 'Comment')
link('@markup.link @markup.link.url', 'Underlined')
link('@markup.link.label', 'Function')
link('@markup.strong', 'Bold')
link('@markup.italic', 'Italic')
hi('@markup.strikethrough', { strikethrough = true })
for capture, target in pairs {
  class = 'Type',
  enum = 'Type',
  interface = 'Type',
  struct = 'Type',
  type = 'Type',
  typeParameter = 'Type',
  function_ = 'Function',
  method = 'Function',
  namespace = 'Type',
  macro = 'PreProc',
  comment = 'Comment',
  variable = 'Identifier',
  parameter = 'Identifier',
  property = 'Identifier',
  enumMember = 'Constant',
} do
  link('@lsp.type.' .. capture:gsub('_$', ''), target)
end

-- Diagnostics and git use accent text on quiet backgrounds.
for severity, color in pairs { Error = 1, Warn = 3, Info = 4, Hint = 6, Ok = 2 } do
  hi('Diagnostic' .. severity, { ctermfg = color })
  for _, kind in ipairs { 'Sign', 'VirtualText', 'VirtualLines', 'Floating' } do
    link('Diagnostic' .. kind .. severity, 'Diagnostic' .. severity)
  end
  hi('DiagnosticUnderline' .. severity, { underline = true })
end
link('DiagnosticDeprecated', '@markup.strikethrough')
link('DiagnosticUnnecessary LspCodeLens', 'Comment')
hi('LspInlayHint', { ctermfg = 248, ctermbg = 232 })
hi('LspReferenceText LspReferenceRead LspReferenceWrite', { ctermbg = 234 })
hi('LspSignatureActiveParameter', { ctermfg = 3, bold = true })
for name, color in pairs { Add = 2, Change = 3, Delete = 1, Text = 6 } do
  hi('Diff' .. name, { ctermfg = color, ctermbg = 232 })
  hi('GitSigns' .. name, { ctermfg = color })
end
link('Added diffAdded', 'GitSignsAdd')
link('Changed diffChanged', 'GitSignsChange')
link('Removed diffRemoved', 'GitSignsDelete')
link('GitSignsChangedelete', 'GitSignsChange')
link('GitSignsTopdelete', 'GitSignsDelete')
link('GitSignsUntracked', 'GitSignsAdd')
for _, name in ipairs { 'SpellBad', 'SpellCap', 'SpellLocal', 'SpellRare' } do
  hi(name, { underline = true })
end

-- MiniStatusline and icons (also supplies nvim-web-devicons in this config).
link('MiniStatuslineDevinfo MiniStatuslineFileinfo', 'StatusLine')
hi('MiniStatuslineFilename', { ctermfg = 255, ctermbg = 232 })
link('MiniStatuslineInactive', 'StatusLineNC')
for name, color in pairs { Normal = 4, Insert = 2, Visual = 5, Replace = 1, Command = 3, Other = 6 } do
  hi('MiniStatuslineMode' .. name, { ctermfg = 232, ctermbg = color, bold = true })
end
for name, color in pairs { Azure = 6, Blue = 4, Cyan = 6, Green = 2, Grey = 248, Orange = 3, Purple = 5, Red = 1, Yellow = 3 } do
  hi('MiniIcons' .. name, { ctermfg = color })
end

-- File tree: distinguish selection, git state and secondary labels.
link('NeoTreeNormal NeoTreeNormalNC NeoTreeSignColumn NeoTreeEndOfBuffer NeoTreeFileName', 'Normal')
link('NeoTreeCursorLine', 'CursorLine')
link('NeoTreeDirectoryName NeoTreeDirectoryIcon NeoTreeRootName', 'Directory')
link('NeoTreeFileIcon', 'Special')
hi('NeoTreeFileNameOpened', { bold = true })
link('NeoTreeIndentMarker NeoTreeExpander', 'WinSeparator')
link('NeoTreeWinSeparator NeoTreeVertSplit', 'WinSeparator')
link('NeoTreeStatusLine', 'StatusLine')
link('NeoTreeStatusLineNC', 'StatusLineNC')
link('NeoTreeFloatNormal', 'NormalFloat')
link('NeoTreeFloatBorder', 'FloatBorder')
link('NeoTreeFloatTitle NeoTreeTitleBar', 'FloatTitle')
link('NeoTreeDotfile NeoTreeHiddenByName NeoTreeWindowsHidden NeoTreeDimText NeoTreeMessage NeoTreeFadeText1 NeoTreeFadeText2', 'Comment')
link('NeoTreeFileStats NeoTreeFileStatsHeader NeoTreeGitIgnored NeoTreeIgnored', 'Comment')
link('NeoTreeGitAdded NeoTreeGitUntracked NeoTreeGitStaged', 'GitSignsAdd')
link('NeoTreeGitModified NeoTreeGitRenamed NeoTreeModified', 'GitSignsChange')
link('NeoTreeGitDeleted NeoTreeGitConflict NeoTreeGitUnstaged', 'GitSignsDelete')
link('NeoTreeSelected NeoTreeSelectedFile NeoTreeSelectedDirectory', 'Visual')
link('NeoTreeTabActive', 'TabLineSel')
link('NeoTreeTabInactive NeoTreeTabSeparatorActive NeoTreeTabSeparatorInactive', 'TabLine')

-- Pickers, completion, key hints and Markdown inherit the same indexed colors.
link('TelescopeNormal', 'NormalFloat')
link('TelescopeBorder', 'FloatBorder')
link('TelescopeTitle', 'FloatTitle')
link('TelescopeSelection', 'PmenuSel')
link('TelescopeMatching', 'PmenuMatch')
link('TelescopePromptPrefix TelescopeSelectionCaret', 'Special')
link('TelescopeMultiSelection', 'Visual')
link('BlinkCmpLabel', 'Normal')
link('BlinkCmpLabelMatch', 'PmenuMatch')
link('BlinkCmpLabelDeprecated', 'DiagnosticDeprecated')
link('WhichKey WhichKeyGroup WhichKeyIcon', 'Special')
link('WhichKeyDesc', 'Normal')
link('WhichKeySeparator WhichKeyValue', 'Comment')
link('WhichKeyNormal', 'NormalFloat')
link('FidgetTitle', 'Title')
link('FidgetTask', 'Comment')
link('FidgetNormal', 'NormalFloat')
for keyword, color in pairs { FIX = 1, TODO = 4, HACK = 3, WARN = 3, PERF = 5, NOTE = 6, TEST = 2 } do
  hi('TodoFg' .. keyword .. ' TodoSign' .. keyword, { ctermfg = color })
  hi('TodoBg' .. keyword, { ctermfg = 232, ctermbg = color, bold = true })
end
link('RenderMarkdownCode RenderMarkdownCodeInline', 'ColorColumn')
for level, color in ipairs { 4, 2, 3, 5, 6, 1 } do
  hi('@markup.heading.' .. level, { ctermfg = color, bold = true })
  hi('RenderMarkdownH' .. level .. 'Bg', { ctermfg = color, ctermbg = 232, bold = true })
end

-- Remove the fallback theme's RGB overrides for future :terminal buffers.
for index = 0, 15 do
  vim.g['terminal_color_' .. index] = nil
end
