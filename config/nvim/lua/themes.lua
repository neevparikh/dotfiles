-- vim: set foldmethod=marker:foldlevel=0
require("helpers")

function SwitchTheme()
  local cur = vim.opt.background:get()
  if cur == "dark" then
    vim.opt.background = "light"
    vim.fn.system("toggle-theme --light")
  else
    vim.opt.background = "dark"
    vim.fn.system("toggle-theme --dark")
  end
end

function CheckTheme()
  local theme = ReadFile(os.getenv("HOME") .. "/.config/theme.yml")
  if theme == nil then
    return "dark"
  else
    return theme:gsub("\n", "")
  end
end

vim.cmd("colorscheme gruvbox")
vim.g.gruvbox_contrast_light = "medium"
vim.g.gruvbox_contrast_dark = "hard"
vim.opt.background = CheckTheme()

vim.cmd([[
" default
let g:fzf_colors = {
      \ 'fg':      ['fg', 'GruvboxFg1'],
      \ 'bg':      ['fg', 'GruvboxBg0'],
      \ 'hl':      ['fg', 'GruvboxYellow'],
      \ 'fg+':     ['fg', 'GruvboxFg1'],
      \ 'bg+':     ['fg', 'GruvboxBg1'],
      \ 'hl+':     ['fg', 'GruvboxYellow'],
      \ 'info':    ['fg', 'GruvboxBlue'],
      \ 'prompt':  ['fg', 'GruvboxFg4'],
      \ 'pointer': ['fg', 'GruvboxBlue'],
      \ 'marker':  ['fg', 'GruvboxOrange'],
      \ 'spinner': ['fg', 'GruvboxYellow'],
      \ 'header':  ['fg', 'GruvboxBg3']
      \ }

let g:fzf_colors["gutter"] = ['bg', 'GruvboxBg1', 'Normal']
let g:fzf_colors["bg+"] = ['bg', 'GruvboxBg1', 'Normal']
let g:fzf_colors["info"] = ['bg', 'GruvboxBg2', 'Normal']
]])
