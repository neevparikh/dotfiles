-- vim: set foldmethod=marker:foldlevel=0
require("helpers")

local color_variant = CheckTheme()
require("gruvbox").setup({
  terminal_colors = true, -- add neovim terminal colors
  undercurl = true,
  underline = true,
  bold = true,
  italic = {
    strings = true,
    emphasis = true,
    comments = true,
    operators = false,
    folds = true,
  },
  strikethrough = true,
  invert_selection = false,
  invert_signs = false,
  invert_tabline = false,
  invert_intend_guides = false,
  inverse = true, -- invert background for search, diffs, statuslines and errors
  contrast = GetContrast(color_variant), -- can be "hard", "soft" or empty string
  dim_inactive = false,
  transparent_mode = false,
  palette_overrides = {},
  overrides = {
    NormalFloat = { link = "Normal" },
    SignColumn = { link = "Normal" },

    String = { italic = false },
    -- TODO: update this to use get_colors when exposed
    ["@text.todo.comment"] = { link = "htmlBoldItalic" },
    ["@text.danger.comment"] = { link = "htmlBoldItalic" },
    -- lua_ls defines comment semantic group, overrides other comment-specific things
    ["@lsp.type.comment.lua"] = {},

    -- FIXME: find a better solution for this, maybe a plugin or something
    diffAdded = { fg = "#98971a" },
    diffRemoved = { fg = "#cc241d" },

    FloatBorder = { link = "GruvboxBg2" },

    TelescopeBorder = { link = "GruvboxBg2" },
    TelescopePromptBorder = { link = "GruvboxBg2" },
    TelescopeResultsBorder = { link = "GruvboxBg2" },
    TelescopePreviewBorder = { link = "GruvboxBg2" },

    MasonNormal = { link = "GruvboxFg1" },
    MasonMutedBlock = { link = "GruvboxRed" },
    MasonMutedBlockBold = { link = "GruvboxRed", bold = true },
    MasonHighlight = { link = "GruvboxOrange" },
    MasonHighlightBlock = { link = "GruvboxOrangeBold" },
    MasonHighlightBlockBold = { link = "GruvboxOrangeBold", bold = true },
    MasonHighlightSecondary = { link = "GruvboxYellow" },
    MasonHighlightBlockSecondary = { link = "GruvboxYellow" },
    MasonHighlightBlockBoldSecondary = { link = "GruvboxYellow", bold = true },
  },
})

-- setup must be called before loading
vim.cmd.colorscheme("gruvbox")
vim.opt.background = color_variant

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
let g:fzf_colors["border"] = ['fg', 'FloatBorder']
let g:fzf_colors["gutter"] = ['bg', 'Normal']
let g:fzf_colors["bg+"] = ['bg', 'Normal']
let g:fzf_colors["info"] = ['bg', 'Normal']
]])
