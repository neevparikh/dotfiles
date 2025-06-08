-- vim:foldmethod=marker:foldlevel=0
require("helpers")
require("keymaps")

local patterns = { ".git" }

local tb = require("telescope.builtin")
local fl = require("fzf-lua")

vim.api.nvim_create_user_command("Filetypes", function()
  if vim.g.use_telescope then
    tb.filetypes()
  else
    fl.filetypes()
  end
end, { nargs = 0 })

vim.api.nvim_create_user_command("Files", function(opts)
  local path = opts.args
  local root = vim.fs.dirname(vim.fs.find(patterns, { upward = true })[1])
  local input = nil
  if path == "" then
    if root ~= nil then
      input = { cwd = root }
    end
  else
    input = { cwd = path }
  end
  if vim.g.use_telescope then
    tb.find_files(input)
  else
    fl.files(input)
  end
end, { nargs = "?" })

vim.api.nvim_create_user_command("Buffers", function()
  if vim.g.use_telescope then
    tb.buffers({ ignore_current_buffer = true, sort_mru = true })
  else
    fl.buffers()
  end
end, { nargs = 0 })

vim.api.nvim_create_user_command("Rg", function(opts)
  local str = opts.args
  local root = vim.fs.dirname(vim.fs.find(patterns, { upward = true })[1])
  if vim.g.use_telescope then
    if str == "" then
      if root ~= nil then
        tb.live_grep({ cwd = root })
      else
        tb.live_grep()
      end
    else
      if root ~= nil then
        tb.grep_string({ search = str, cwd = root })
      else
        tb.grep_string({ search = str })
      end
    end
  else
    if str == "" then
      if root ~= nil then
        fl.live_grep_glob({ cwd = root })
      else
        fl.live_grep_glob()
      end
    else
      if root ~= nil then
        fl.grep_project({ search = str, cwd = root })
      else
        fl.grep_project({ search = str })
      end
    end
  end
end, { nargs = "?" })

vim.api.nvim_create_user_command("H", function()
  if vim.g.use_telescope then
    tb.help_tags()
  else
    fl.helptags()
  end
end, { nargs = 0 })

vim.api.nvim_create_user_command("Scratch", function()
  local random_string = ""
  for _ = 1, 5 do
    random_string = random_string .. string.char(math.random(97, 97 + 25))
  end
  vim.cmd(
    "enew | setlocal bufhidden=hide nobuflisted buftype=nowrite noswapfile | file [scratch-"
      .. random_string
      .. "]"
  )
end, { nargs = 0 })

vim.api.nvim_create_user_command("PrintPath", PrintPath, { nargs = 0 })
vim.api.nvim_create_user_command("SwitchThemeWithoutToggling", function(opts)
  SwitchThemeWithoutToggling(opts.args)
end, { nargs = 1 })
