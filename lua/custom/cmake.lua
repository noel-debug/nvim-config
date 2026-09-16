-- Debug-preset commands for CMake projects; resolve paths from the current buffer.
local function project_root()
  local root = vim.fs.root(0, 'CMakePresets.json') or vim.fs.root(vim.fn.getcwd(), 'CMakePresets.json')
  if not root then vim.notify('No CMakePresets.json found for this buffer or working directory', vim.log.levels.WARN) end
  return root
end

local function run_cmake(arguments)
  local root = project_root()
  if not root then return end

  vim.cmd.wall()
  -- Run in the project directory without changing Neovim's working directory.
  vim.bo.makeprg = 'cmake -E chdir ' .. vim.fn.shellescape(root) .. ' cmake ' .. arguments
  vim.cmd 'make!'
  if vim.v.shell_error ~= 0 then
    vim.cmd.copen()
  else
    vim.cmd.cwindow()
  end
end

vim.keymap.set('n', '<leader>cc', function() run_cmake '--preset debug' end, { desc = '[C]Make: [C]onfigure Debug' })
vim.keymap.set('n', '<leader>cb', function() run_cmake '--build --preset debug' end, { desc = '[C]Make: [B]uild Debug' })
vim.keymap.set('n', '<leader>ct', function()
  local root = project_root()
  if not root then return end

  vim.cmd.wall()
  vim.cmd 'botright 12new'
  vim.fn.jobstart({ 'ctest', '--test-dir', root .. '/build/debug', '--output-on-failure' }, { cwd = root, term = true })
  vim.cmd.startinsert()
end, { desc = '[C]Make: [T]est Debug' })
