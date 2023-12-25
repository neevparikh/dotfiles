-- vim:foldmethod=marker:foldlevel=0
require("helpers")
require("keymaps")

-- {{{ fzf
RegisterFzfCommand(
  "command! -bang -nargs=* ",
  "RgWithArgs",
  ' call fzf#vim#grep("rg --column --line-number --no-heading --color=always --smart-case ".<q-args>, fzf#vim#with_preview(), <bang>0)'
)
-- }}}

-- {{{ telescope
require("telescope").load_extension("fzf")
local tb = require("telescope.builtin")

vim.api.nvim_create_user_command("Filetypes", function()
  tb.filetypes()
end, { nargs = 0 })

vim.api.nvim_create_user_command("Files", function(opts)
  local path = opts.args
  if path == "" then
    tb.find_files({ cwd = vim.fn.expand("%:p:h") })
  else
    tb.find_files({ cwd = path })
  end
end, { nargs = "?" })

vim.api.nvim_create_user_command("Buffers", function()
  tb.buffers({ ignore_current_buffer = true, sort_mru = true })
end, { nargs = 0 })

vim.api.nvim_create_user_command("Rg", function(opts)
  local str = opts.args
  if str == "" then
    tb.live_grep()
  else
    tb.grep_string({ search = str })
  end
end, { nargs = "?" })

vim.api.nvim_create_user_command("GFiles", function()
  tb.git_files({
    git_command = { "git", "ls-files", "--exclude-standard", "--cached" },
  })
end, { nargs = 0 })

vim.api.nvim_create_user_command("H", function()
  tb.help_tags()
end, { nargs = 0 })
-- }}}

vim.api.nvim_create_user_command("Scratch", function()
  local random_string = ""
  for i = 1, 5 do
    random_string = random_string .. string.char(math.random(97, 97 + 25))
  end
  vim.cmd(
    "enew | setlocal bufhidden=hide nobuflisted buftype=nowrite noswapfile | file [scratch-"
      .. random_string
      .. "]"
  )
end, { nargs = 0 })
