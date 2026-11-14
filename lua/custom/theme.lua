local M = {}
local mode, active, pending, group
local applying, managed = false, true
local shades = { 232, 240, 248, 255 }

local function cancel_probe()
  if pending then
    pending.timer:stop()
    pending.timer:close()
    pending = nil
  end
end

-- Rex markers are hints, not proof that its extended palette is enabled.
local function in_rex()
  return (vim.env.TERM_PROGRAM or ''):lower() == 'rex'
    or vim.env.TERM == 'xterm-rex'
    or vim.env.TERM == 'rex'
    or (vim.env.REX_SESSION or ''):match '^session:' ~= nil and (vim.env.REX_BLOCK or ''):match '^block:' ~= nil
end

-- OSC colors can contain one to four hexadecimal digits per channel.
local function rgb(value)
  value = value:gsub('\027\\$', ''):gsub('\007$', '')
  local r, g, b = value:match '^rgb:(%x+)/(%x+)/(%x+)$'
  if not r or #r > 4 or #g > 4 or #b > 4 then return end
  return {
    tonumber(r, 16) / (16 ^ #r - 1),
    tonumber(g, 16) / (16 ^ #g - 1),
    tonumber(b, 16) / (16 ^ #b - 1),
  }
end

local function background(color) return 0.299 * color[1] + 0.587 * color[2] + 0.114 * color[3] < 0.5 and 'dark' or 'light' end

local function has_rex_ramp(colors)
  local bg, fg = colors.bg, colors.fg
  local span = 0
  for i = 1, 3 do
    span = span + (fg[i] - bg[i]) ^ 2
  end
  if span < 0.1 then return false end

  local standard, previous = true, -1
  for _, index in ipairs(shades) do
    local color, position, deviation = colors[index], 0, 0
    for i = 1, 3 do
      position = position + (color[i] - bg[i]) * (fg[i] - bg[i]) / span
      if math.abs(color[i] - (8 + 10 * (index - 232)) / 255) > 1 / 255 then standard = false end
    end
    for i = 1, 3 do
      deviation = deviation + (color[i] - bg[i] - position * (fg[i] - bg[i])) ^ 2
    end
    -- Shades must run from this terminal's background towards its foreground.
    if position <= previous or position < -0.05 or position > 1.15 or deviation > span * 0.08 then return false end
    if index == 232 and position > 0.2 then return false end
    if index == 255 and position < 0.75 then return false end
    previous = position
  end
  -- The ordinary xterm grayscale is not Rex's theme-dependent shade ramp.
  return not standard
end

local function apply(selection, bg)
  applying = true
  vim.g.colors_name = nil -- Avoid reloading the previous scheme when changing background.
  if selection == 'dark' then
    vim.o.background = 'dark'
    vim.cmd 'highlight clear'
    vim.cmd.colorscheme 'kanagawa-wave'
  else
    if bg then vim.o.background = background(bg) end
    vim.cmd.colorscheme 'rex'
  end
  active = selection
  applying = false
end

local function probe()
  if mode ~= 'auto' or not managed or pending or not in_rex() or #vim.api.nvim_list_uis() == 0 then return end

  local request = { colors = {}, timer = vim.uv.new_timer() }
  pending = request
  request.timer:start(
    1000,
    0,
    vim.schedule_wrap(function()
      if pending ~= request then return end
      cancel_probe()
      if managed and active ~= 'dark' then apply 'dark' end
    end)
  )

  local query = '\027]10;?\027\\\027]11;?\027\\'
  for _, index in ipairs(shades) do
    query = query .. ('\027]4;%d;?\027\\'):format(index)
  end
  if not pcall(vim.api.nvim_ui_send, query) then
    cancel_probe()
    if active ~= 'dark' then apply 'dark' end
  end
end

local function response(ev)
  local sequence = ev.data.sequence
  local index, value = sequence:match '^\027%]4;(%d+);(.*)'
  local key = tonumber(index)
  if not key then
    index, value = sequence:match '^\027%](1[01]);(.*)'
    key = index == '10' and 'fg' or index == '11' and 'bg' or nil
  end
  if not key then return end
  local color = rgb(value)
  if not color then return end

  if pending then
    local colors = pending.colors
    colors[key] = color
    if not colors.fg or not colors.bg then return end
    for _, shade in ipairs(shades) do
      if not colors[shade] then return end
    end
    cancel_probe()
    local selection = has_rex_ramp(colors) and 'rex' or 'dark'
    if active ~= selection or selection == 'rex' and vim.o.background ~= background(colors.bg) then apply(selection, colors.bg) end
  end

  -- Indexed colors update without events. Keep the option accurate for plugins
  -- when the terminal does notify Nvim of a dark/light appearance change.
  if managed and active == 'rex' and key == 'bg' and vim.o.background ~= background(color) then
    applying = true
    vim.o.background = background(color)
    applying = false
  end
end

function M.select(selection)
  if not vim.tbl_contains({ 'auto', 'rex', 'dark' }, selection) then error 'Theme must be auto, rex, or dark' end
  cancel_probe()
  mode, managed = selection, true
  vim.g.theme_mode = selection
  apply(selection == 'rex' and 'rex' or 'dark')
  if vim.v.vim_did_enter == 1 then vim.schedule(probe) end
end

function M.setup()
  cancel_probe()
  group = vim.api.nvim_create_augroup('TerminalTheme', { clear = true })
  require('kanagawa').setup {
    commentStyle = { italic = false },
    keywordStyle = { italic = false },
    background = { dark = 'wave', light = 'wave' },
  }

  vim.api.nvim_create_autocmd('TermResponse', { group = group, callback = response })
  vim.api.nvim_create_autocmd({ 'VimEnter', 'UIEnter', 'FocusGained' }, { group = group, callback = function() vim.schedule(probe) end })
  vim.api.nvim_create_autocmd('VimLeavePre', { group = group, callback = cancel_probe })
  vim.api.nvim_create_autocmd('ColorScheme', {
    group = group,
    callback = function()
      if applying then return end
      -- A manual :colorscheme / Telescope selection wins over a pending probe.
      managed = false
      cancel_probe()
    end,
  })
  vim.api.nvim_create_user_command('Theme', function(args)
    if args.args == '' then
      vim.notify(('Theme: %s (%s)'):format(mode, vim.g.colors_name or 'none'))
    else
      M.select(args.args)
    end
  end, { nargs = '?', complete = function() return { 'auto', 'rex', 'dark' } end, desc = 'Choose automatic Rex colors or the dark fallback' })

  local requested = vim.g.theme_mode or vim.env.NVIM_THEME or 'auto'
  if not vim.tbl_contains({ 'auto', 'rex', 'dark' }, requested) then requested = 'auto' end
  M.select(requested)
end

return M
