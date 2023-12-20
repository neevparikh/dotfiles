-- vim: set foldmethod=marker:foldlevel=0
vim.opt.clipboard = "unnamedplus"
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
vim.opt.colorcolumn = "100"
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.undofile = true
vim.opt.conceallevel = 1
vim.opt.hlsearch = true

vim.opt_global.shortmess:remove("F")

vim.g.lion_squeeze_spaces = true
vim.g.startify_enable_special = false
vim.g.startify_update_oldfiles = true
vim.g.rooter_manual_only = 0
vim.g.rooter_silent_chdir = 1

vim.cmd([[
let g:fzf_vim = {}
let g:fzf_vim.preview_window = ['right,50%,<70(down,40%)', '?']
let g:fzf_vim.command_prefix = 'Fzf'
]])
