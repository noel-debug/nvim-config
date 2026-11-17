-- codediff: VSCode-style diff view (side-by-side/inline, char-level highlights)
-- https://github.com/esmuellert/codediff.nvim
--
-- The native diff library is downloaded on first `:CodeDiff` use
-- (vim.pack has no build hook). Run `:CodeDiff install!` to force a re-download.

vim.pack.add { 'https://github.com/esmuellert/codediff.nvim' }
require('codediff').setup {}

vim.keymap.set('n', '<leader>hv', '<cmd>CodeDiff<CR>', { desc = 'git diff [v]iew (all changes)' })
vim.keymap.set('n', '<leader>hV', '<cmd>CodeDiff --staged<CR>', { desc = 'git diff [V]iew (staged)' })
vim.keymap.set('n', '<leader>hH', '<cmd>CodeDiff history %<CR>', { desc = 'git file [H]istory' })
