-- vim: set foldmethod=marker:foldlevel=0
require("helpers")

local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

local cpp = augroup("cpp", { clear = true })

-- {{{ general
-- autocmd({ "BufLeave" }, { pattern = "*", command = "call CleanNoNameEmptyBuffers()" })
autocmd({ "BufWrite" }, { pattern = "*.todo", callback = SortAndReset })
autocmd({ "BufEnter", "FocusGained", "InsertLeave" }, {
  pattern = "*",
  callback = function(args)
    if
      vim.api.nvim_buf_get_name(args.buf) ~= ""
      and vim.api.nvim_get_option_value("buftype", { buf = args.buf }) ~= "terminal"
    then
      vim.opt_local.relativenumber = true
      vim.opt_local.number = true
    else
      vim.opt_local.relativenumber = false
      vim.opt_local.number = false
    end
  end,
})
autocmd({ "BufLeave", "FocusLost", "InsertEnter" }, {
  pattern = "*",
  callback = function(args)
    if
      vim.api.nvim_buf_get_name(args.buf) ~= ""
      and vim.api.nvim_get_option_value("buftype", { buf = args.buf }) ~= "terminal"
    then
      vim.opt_local.relativenumber = false
      vim.opt_local.number = true
    end
  end,
})
autocmd(
  { "TermOpen" },
  { pattern = "*", command = "setlocal listchars= nonumber norelativenumber" }
)
-- }}}

-- {{{ filetype
autocmd({ "FileType" }, {
  pattern = { "markdown", "text", "rst" },
  command = "setlocal spell",
})
autocmd({ "FileType" }, {
  pattern = { "todo" },
  command = "setlocal wrap linebreak textwidth=100 foldlevel=0",
})
autocmd(
  { "FileType" },
  { group = cpp, pattern = "cpp", command = "setlocal commentstring=//\\ %s" }
)
-- }}}
