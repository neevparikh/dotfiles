-- vim: set foldmethod=marker:foldlevel=0
require("helpers")

require("catppuccin").setup({
  flavour = "mocha", -- latte, frappe, macchiato, mocha
  background = { -- :h background
    light = "latte",
    dark = "mocha",
  },
  transparent_background = false, -- disables setting the background color.
  show_end_of_buffer = false, -- shows the '~' characters after the end of buffers
  term_colors = false, -- sets terminal colors (e.g. `g:terminal_color_0`)
  dim_inactive = {
    enabled = false, -- dims the background color of inactive window
    shade = "dark",
    percentage = 0.15, -- percentage of the shade to apply to the inactive window
  },
  no_italic = false, -- Force no italic
  no_bold = false, -- Force no bold
  no_underline = false, -- Force no underline
  styles = { -- Handles the styles of general hi groups (see `:h highlight-args`):
    comments = { "italic" }, -- Change the style of comments
    conditionals = { "italic" },
    loops = {},
    functions = {},
    keywords = {},
    strings = {},
    variables = {},
    numbers = {},
    booleans = {},
    properties = {},
    types = {},
    operators = {},
  },
  color_overrides = {},
  highlight_overrides = {},
  custom_highlights = function(colors)
    return {
      FloatBorder = { fg = colors.surface0 },
      WinSeparator = { fg = colors.surface0, bg = colors.base },

      TelescopeBorder = { fg = colors.surface0 },
      TelescopePromptBorder = { fg = colors.surface0 },
      TelescopeResultsBorder = { fg = colors.surface0 },
      TelescopePreviewBorder = { fg = colors.surface0 },
      TelescopeSelection = { bg = colors.base },

      MasonHeader = { fg = colors.lavender, bg = colors.mantle, style = { "bold" } },
      MasonHeaderSecondary = { fg = colors.blue, bg = colors.mantle, style = { "bold" } },

      MasonHighlight = { fg = colors.green, bg = colors.mantle },
      MasonHighlightBlock = { fg = colors.green, bg = colors.mantle },
      MasonHighlightBlockBold = { fg = colors.blue, bg = colors.mantle, bold = true },

      MasonHighlightSecondary = { fg = colors.mauve, bg = colors.mantle },
      MasonHighlightBlockSecondary = { fg = colors.blue, bg = colors.mantle },
      MasonHighlightBlockBoldSecondary = { fg = colors.lavender, bg = colors.mantle, bold = true },

      MasonMuted = { fg = colors.overlay0, bg = colors.mantle },
      MasonMutedBlock = { fg = colors.overlay0, bg = colors.mantle },
      MasonMutedBlockBold = { fg = colors.yellow, bg = colors.mantle, bold = true },

      MasonError = { fg = colors.red, bg = colors.mantle },

      MasonHeading = { fg = colors.lavender, bg = colors.mantle, bold = true },
    }
  end,
  native_lsp = {
    enabled = true,
    virtual_text = {
      errors = { "italic" },
      hints = { "italic" },
      warnings = { "italic" },
      information = { "italic" },
    },
    underlines = {
      errors = { "underline" },
      hints = { "underline" },
      warnings = { "underline" },
      information = { "underline" },
    },
    inlay_hints = {
      background = false,
    },
  },
  integrations = {
    cmp = true,
    gitsigns = true,
    nvimtree = true,
    treesitter = true,
    notify = false,
    mason = true,
    telescope = { enabled = true },
    mini = {
      enabled = true,
      indentscope_color = "",
    },
  },
})

-- setup must be called before loading
vim.cmd.colorscheme("catppuccin")
vim.opt.background = CheckTheme()

vim.cmd([[
" default
let g:fzf_colors = {}
let g:fzf_colors["border"] = ['fg', 'FloatBorder']
let g:fzf_colors["gutter"] = ['bg', 'Normal']
let g:fzf_colors["bg+"] = ['bg', 'Normal']
let g:fzf_colors["info"] = ['bg', 'Normal']
]])
