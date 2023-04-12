-- vim: set foldmethod=marker:
require('helpers')

-- {{{ lsp
local lsp = require('lsp-zero')
local ls = require("luasnip")
lsp.set_preferences({
  suggest_lsp_servers = true,
  setup_servers_on_start = true,
  set_lsp_keymaps = false,
  configure_diagnostics = true,
  cmp_capabilities = true,
  manage_nvim_cmp = true,
  call_servers = 'local',
  sign_icons = {
    error = '✘',
    warn = '▲',
    hint = '⚑',
    info = ''
  }
})

lsp.nvim_workspace()

-- {{{ mapping
local cmp = require('cmp')
local select_opts = { behavior = cmp.SelectBehavior.Select }
local mappings = {
  -- confirm selection
  ['<CR>'] = cmp.mapping.confirm({ select = false }),

  -- navigate items on the list
  ['<Up>'] = cmp.mapping.select_prev_item(select_opts),
  ['<Down>'] = cmp.mapping.select_next_item(select_opts),

  -- scroll up and down in the completion documentation
  ['<C-f>'] = cmp.mapping.scroll_docs(5),
  ['<C-u>'] = cmp.mapping.scroll_docs(-5),

  -- toggle completion
  ['<C-e>'] = cmp.mapping(function(_)
    if cmp.visible() then
      cmp.close()
    else
      cmp.complete()
    end
  end),

  -- go to next placeholder in the snippet
  ['<C-d>'] = cmp.mapping(function(fallback)
    if ls.jumpable(1) then
      ls.jump(1)
    else
      fallback()
    end
  end, { 'i', 's' }),

  -- go to previous placeholder in the snippet
  ['<C-b>'] = cmp.mapping(function(fallback)
    if ls.jumpable(-1) then
      ls.jump(-1)
    else
      fallback()
    end
  end, { 'i', 's' }),

  -- when menu is visible, navigate to next item
  -- when line is empty, insert a tab character
  -- else, activate completion
  ['<Tab>'] = cmp.mapping(function(fallback)
    if cmp.visible() then
      cmp.select_next_item(select_opts)
    elseif CheckBackSpace() then
      fallback()
    else
      cmp.complete()
    end
  end, { 'i', 's' }),

  -- when menu is visible, navigate to previous item on list
  -- else, revert to default behavior
  ['<S-Tab>'] = cmp.mapping(function(fallback)
    if cmp.visible() then
      cmp.select_prev_item(select_opts)
    else
      fallback()
    end
  end, { 'i', 's' }),
}
-- }}}

local cmp_config = {
  mapping = mappings,
  sources = {
    { name = "path" },
    { keyword_length = 3, name = "nvim_lsp" },
    { keyword_length = 3, name = "buffer" },
    { keyword_length = 2, name = "luasnip", option = { show_autosnippets = true } }
  }
}

lsp.setup_nvim_cmp(cmp_config)
lsp.setup()


-- }}}

-- {{{ lualine
local lualine_options = { theme = 'gruvbox' }
require('lualine').setup(lualine_options)
-- }}}

-- {{{ mason
require("mason").setup()
-- }}}

-- {{{ startify
vim.g.startify_bookmarks = {
  { z = '~/.zshrc' },
  { v = '~/.config/nvim/init.lua' },
  { d = '~/.todo' },
  { k = '~/.config/kitty/kitty.conf' },
  { w = '~/.config/regolith/i3/config' },
  { x = '~/.config/regolith/Xresources' },
  { s = '~/.config/regolith/i3xrocks/conf.d' },
}
vim.g.startify_commands = {
  { t = 'terminal' },
  { b = 'Buffers' },
  { f = 'Files' }
}
vim.g.startify_custom_header = ""
vim.g.startify_lists = {
  { type = 'commands', header = { '   Commands' } },
  { type = 'bookmarks', header = { '   Bookmarks' } },
  { type = 'files', header = { '   MRU' } },
  { type = 'sessions', header = { '   Sessions' } }
}
-- }}}

-- {{{ rooter
vim.g.rooter_manual_only = 1
vim.g.rooter_silent_chdir = 1
-- }}}

-- {{{ fzf
local function fzf_config()
  local bat_theme
  if vim.opt.background == 'dark' then
    bat_theme = 'gruvbox-dark'
  else
    bat_theme = 'gruvbox-light'
  end
  return {
    winopts = {
      hl = {
        border = 'FloatBorder'
      },
    },
    previewers = {
      bat = {
        cmd    = "bat",
        args   = "--style=numbers,changes --color always",
        theme  = bat_theme, -- bat preview theme (bat --list-themes)
        config = nil, -- nil uses $BAT_CONFIG_PATH
      },
    },
  }
end

local fzf = require('fzf-lua')
fzf.setup(fzf_config())
vim.api.nvim_create_user_command('Files', function(opts)
  local path = opts.args
  if path == '' then
    fzf.files(fzf_config())
  else
    local cfg = vim.tbl_extend('error', fzf_config(), { cwd = path })
    fzf.files(cfg)
  end
end, { nargs = '?' })
vim.api.nvim_create_user_command('Buffers', function()
  fzf.buffers()
end, { nargs = 0 })
vim.api.nvim_create_user_command('RgPreview', function()
  fzf.grep()
end, { nargs = 0 })
vim.api.nvim_create_user_command('RgPreviewHidden', function()
  fzf.live_grep_native()
end, { nargs = 0 })
-- }}}

-- {{{ luasnip
vim.api.nvim_create_user_command('LuaSnipEdit', function()
  require("luasnip.loaders").edit_snippet_files()
end, { nargs = 0 })
ls.config.setup({ store_selection_keys = "<Tab>", enable_autosnippets = true })
require("luasnip.loaders.from_lua").load({ paths = "~/.config/nvim/snippets" })
-- }}}

-- {{{ treesitter
require('nvim-treesitter.configs').setup {
  -- A list of parser names, or "all"
  ensure_installed = { "cpp", "lua", "rust", "java" },

  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,

  -- Automatically install missing parsers when entering buffer
  auto_install = false,

  -- List of parsers to ignore installing (for "all")
  ignore_install = {},

  highlight = {
    -- `false` will disable the whole extension
    enable = true,

    -- list of language that will be disabled
    disable = {},

    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
  },
  matchup = {
    enable = true,
  }
}
-- }}}
