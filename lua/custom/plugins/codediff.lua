-- codediff: VSCode-style diff view (side-by-side/inline, char-level highlights)
-- https://github.com/esmuellert/codediff.nvim
--
-- The native diff library is downloaded on first `:CodeDiff` use
-- (vim.pack has no build hook). Run `:CodeDiff install!` to force a re-download.

vim.pack.add { 'https://github.com/esmuellert/codediff.nvim' }
require('codediff').setup {}

-- More visible diff colors. Each group carries GUI colors (kanagawa fallback,
-- termguicolors on) and cterm colors (Rex: ANSI accents + 232–255 greys).
-- codediff re-derives its groups from plugin/codediff.lua (sourced after
-- init.lua) and on every ColorScheme, so hook our overrides onto its setup.
local function diff_groups()
  local hl = vim.api.nvim_set_hl
  hl(0, 'CodeDiffLineInsert', { bg = '#2e4a33', ctermbg = 235 })
  hl(0, 'CodeDiffLineDelete', { bg = '#4d2a33', ctermbg = 235 })
  hl(0, 'CodeDiffCharInsert', { bg = '#47744d', ctermfg = 2, ctermbg = 237, bold = true, cterm = { bold = true, underline = true } })
  hl(0, 'CodeDiffCharDelete', { bg = '#80404d', ctermfg = 1, ctermbg = 237, bold = true, cterm = { bold = true, strikethrough = true } })
  hl(0, 'CodeDiffGutterInsertNumber', { fg = '#76c47e', ctermfg = 2, bold = true })
  hl(0, 'CodeDiffGutterDeleteNumber', { fg = '#e46876', ctermfg = 1, bold = true })
end
local codediff_hl = require 'codediff.ui.highlights'
local codediff_hl_setup = codediff_hl.setup
codediff_hl.setup = function(...)
  codediff_hl_setup(...)
  diff_groups()
end
diff_groups()

vim.keymap.set('n', '<leader>hv', '<cmd>CodeDiff<CR>', { desc = 'git diff [v]iew (all changes)' })
vim.keymap.set('n', '<leader>hV', '<cmd>CodeDiff --staged<CR>', { desc = 'git diff [V]iew (staged)' })
vim.keymap.set('n', '<leader>hH', '<cmd>CodeDiff history %<CR>', { desc = 'git file [H]istory' })
