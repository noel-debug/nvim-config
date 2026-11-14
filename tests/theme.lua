-- Run from the config directory: nvim --headless -u NONE -i NONE -l tests/theme.lua
vim.opt.runtimepath:prepend(vim.fn.getcwd())
vim.cmd.packadd 'kanagawa.nvim'

local theme = require 'custom.theme'
local queries, attached = {}, true
vim.api.nvim_list_uis = function() return attached and { { chan = 1 } } or {} end
vim.api.nvim_ui_send = function(sequence) table.insert(queries, sequence) end

local function equal(actual, expected, message) assert(vim.deep_equal(actual, expected), message .. ': ' .. vim.inspect(actual)) end

local function settle()
  vim.wait(20, function() return false end, 5)
end
local function focus()
  vim.api.nvim_exec_autocmds('FocusGained', {})
  settle()
end

local function reset(mode, rex, ui)
  attached = ui ~= false
  vim.env.TERM_PROGRAM = rex and 'rex' or 'another-terminal'
  vim.env.TERM = 'xterm-256color'
  vim.env.REX_SESSION, vim.env.REX_BLOCK = nil, nil
  vim.env.NVIM_THEME, vim.g.theme_mode = mode, nil
  queries = {}
  theme.setup()
  focus()
end

local function reply(index, value)
  local prefix = type(index) == 'number' and '4;' .. index or index == 'fg' and '10' or '11'
  vim.api.nvim_exec_autocmds('TermResponse', { data = { sequence = '\027]' .. prefix .. ';' .. value } })
end

local function palette(light, standard)
  local bg, fg = light and { 245, 240, 250 } or { 20, 16, 31 }, light and { 35, 25, 45 } or { 220, 210, 238 }
  local colors = { bg = bg, fg = fg }
  for index, amount in pairs { [232] = 0.03, [240] = 0.35, [248] = 0.7, [255] = 0.96 } do
    colors[index] = {}
    for channel = 1, 3 do
      colors[index][channel] = standard and 8 + 10 * (index - 232) or math.floor(bg[channel] + amount * (fg[channel] - bg[channel]) + 0.5)
    end
  end
  -- Deliberately out of order, with the background arriving before the last shade.
  for _, index in ipairs { 248, 'fg', 255, 'bg', 232, 240 } do
    local color = colors[index]
    reply(index, ('rgb:%04x/%04x/%04x'):format(color[1] * 257, color[2] * 257, color[3] * 257))
  end
end

local function fallback()
  equal(vim.g.colors_name, 'kanagawa', 'fallback scheme')
  equal(vim.o.background, 'dark', 'fallback stays dark')
  equal(vim.o.termguicolors, true, 'fallback restores true color')
end

reset('auto', false)
fallback()
equal(#queries, 0, 'other terminals need no probe')
reset('auto', true, false)
fallback()
equal(#queries, 0, 'headless sessions need no probe')

reset('auto', true)
equal(#queries, 1, 'one asynchronous probe')
reply(232, 'rgb:12345/0000/0000')
reply(240, 'rgb:aa/bb/cc-invalid')
reply(0, 'rgb:aa/bb/cc')
fallback()
palette(false)
equal(vim.g.colors_name, 'rex', 'valid Rex palette detected')
equal(vim.o.termguicolors, false, 'Rex uses indexed colors')
equal(vim.api.nvim_get_hl(0, { name = 'Normal' }), {}, 'default terminal colors inherited')
equal(vim.api.nvim_get_hl(0, { name = 'CursorLine' }), { ctermbg = 232 }, 'cursor line preserves syntax')
equal(vim.api.nvim_get_hl(0, { name = 'Comment' }).italic, nil, 'comments have no italics')

focus()
palette(true)
equal(vim.g.colors_name, 'rex', 'light palette retains Rex')
equal(vim.o.background, 'light', 'completed probe updates background')
reply('bg', 'rgb:1414/1010/1f1f\027\\')
equal(vim.o.background, 'dark', 'appearance response updates background')
equal(vim.g.colors_name, 'rex', 'background reload retains Rex')
equal(vim.o.termguicolors, false, 'background reload retains indexed colors')

focus()
palette(false, true)
fallback()

reset('auto', true)
theme.select 'dark'
palette(false)
fallback()
focus()
equal(#queries, 1, 'dark override cancels further probes')

reset('auto', true)
vim.cmd.colorscheme 'default'
palette(false)
equal(vim.g.colors_name, 'default', 'manual colorscheme wins over late responses')
focus()
equal(#queries, 1, 'manual colorscheme stops automatic selection')

reset('rex', false, false)
equal(vim.g.colors_name, 'rex', 'explicit Rex works without markers or a UI')
equal(#queries, 0, 'explicit Rex does not probe')
theme.select 'dark'
fallback()
equal(vim.api.nvim_get_hl(0, { name = 'TodoBgTODO' }).ctermbg, nil, 'fallback clears Rex-specific colors')

reset('invalid-mode', false)
equal(vim.g.theme_mode, 'auto', 'invalid environment override uses auto')
fallback()

reset('auto', true)
palette(false)
focus()
assert(vim.wait(1500, function() return vim.g.colors_name == 'kanagawa' end, 10), 'unanswered probe must fall back')
fallback()

print 'Theme detection, fallback, overrides, and highlight checks passed.'
