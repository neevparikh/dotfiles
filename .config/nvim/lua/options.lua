-- vim: set foldmethod=marker:foldlevel=0
require("io")

vim.opt.clipboard = vim.g.remote_neovim_host and "" or "unnamedplus"
vim.opt.pumblend = 15
vim.opt.termguicolors = true
vim.opt.showmode = false
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.textwidth = 0
vim.opt.softtabstop = 2
vim.opt.expandtab = true
vim.opt.foldlevel = 99
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.inccommand = "nosplit"
vim.opt.cursorline = true
vim.opt.wildmenu = true
vim.opt.autochdir = true
vim.opt.hidden = true
vim.opt.wildmode = { "longest", "list", "full" }
vim.opt.cmdheight = 1
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.lazyredraw = true
vim.opt.wrap = true
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.foldmethod = "expr"
vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldtext = ""
vim.opt.fillchars = "fold: "
vim.opt.undofile = true
vim.opt.conceallevel = 1
vim.opt.hlsearch = true
vim.opt_global.shortmess:remove("F")
vim.opt.laststatus = 3
vim.g.mapleader = " "

-- plugins
vim.g.molten_output_virt_lines = true
vim.g.molten_output_show_more = true

local function exists(path)
  local file = io.open(path, "r")
  if file then
    file:close()
    return true
  end
  return false
end
--
-- custom
vim.g.use_telescope = false
vim.g.codecompanion_processing = false --@deprecated
vim.g.is_metr_mac = vim.uv.os_uname().sysname == "Darwin"
  and vim.uv.fs_stat(vim.fs.abspath("~/repos/metr"))
vim.g.is_unix = vim.uv.os_uname().sysname == "Linux"
vim.g.is_remote_server = vim.uv.os_uname().sysname == "Linux"
  and (vim.env.SSH_TTY ~= nil or exists("/.dockerenv"))

if vim.g.is_remote_server then
  vim.g.clipboard = "osc52"
end

vim.diagnostic.config({
  underline = true,
  virtual_text = {
    source = "if_many",
  },
  float = {
    border = "rounded",
    source = "if_many",
  },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "✘",
      [vim.diagnostic.severity.WARN] = "▲",
      [vim.diagnostic.severity.HINT] = "⚑",
      [vim.diagnostic.severity.INFO] = "",
    },
  },
})

-- This is a disgusting hack but it comes recommended:
-- https://github.com/neovim/nvim-lspconfig/wiki/UI-Customization
local orig = vim.lsp.util.open_floating_preview
function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
  opts = opts or {}
  opts.border = opts.border or "rounded"
  return orig(contents, syntax, opts, ...)
end
