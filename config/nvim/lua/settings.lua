-- vim:foldmethod=marker:foldlevel=0
require("helpers")
require("keymaps")
local lsp_zero = require("lsp-zero")
local ls = require("luasnip")
local lspconfig = require("lspconfig")

-- {{{ mason and lspconfig
require("mason").setup({
  ui = {
    icons = {
      package_installed = "✓",
      package_pending = "➜",
      package_uninstalled = "✗",
    },
    border = "rounded",
    width = 0.6,
    height = 0.6,
    keymaps = {
      apply_language_filter = "<M-f>",
    },
  },
})

require("mason-lspconfig").setup({
  ensure_installed = { "lua_ls", "clangd", "pyright" },
  handlers = {
    lsp_zero.default_setup(),
    lua_ls = function()
      local lua_opts = lsp_zero.nvim_lua_ls()
      lspconfig.lua_ls.setup(lua_opts)
    end,
    clangd = function()
      lspconfig.clangd.setup({
        settings = {
          clangd = {
            arguments = {
              "--header-insertion=never",
              "--query-driver=**",
            },
          },
        },
      })
    end,
  },
})

lspconfig.rust_analyzer.setup({})
-- }}}

-- {{{ lspzero and completion
lsp_zero.set_preferences({
  suggest_lsp_servers = true,
  setup_servers_on_start = true,
  set_lsp_keymaps = false,
  configure_diagnostics = true,
  cmp_capabilities = true,
  manage_nvim_cmp = true,
  call_servers = "local",
  sign_icons = {
    error = "✘",
    warn = "▲",
    hint = "⚑",
    info = "",
  },
})
local cmp = require("cmp")
local winopts = {
  border = "rounded",
  winhighlight = "CursorLine:Visual,Search:None",
}
cmp.setup({
  window = {
    completion = cmp.config.window.bordered(winopts),
    documentation = cmp.config.window.bordered(winopts),
  },
  mapping = GetCmpMappings(),
  formatting = lsp_zero.cmp_format(),
  sources = {
    { name = "path" },
    { keyword_length = 3, name = "nvim_lsp" },
    { keyword_length = 3, name = "buffer" },
    { keyword_length = 2, name = "luasnip", option = { show_autosnippets = true } },
  },
})

vim.diagnostic.config({
  virtual_text = true,
})

-- }}}

-- {{{ conform
require("conform").setup({
  formatters_by_ft = {
    javascript = { "prettierd" },
    typescript = { "prettierd" },
    javascriptreact = { "prettierd" },
    typescriptreact = { "prettierd" },
    html = { "prettierd" },
    json = { "prettierd" },
    jsonc = { "prettierd" },
    graphql = { "prettierd" },
    go = { "goimports", "gofmt" },
    lua = { "stylua" },
    python = { "isort", "black" },
  },
  formatters = {},
  format_after_save = { lsp_fallback = true },
})
-- }}}

-- {{{ dressing
require("dressing").setup({
  input = {
    border = "rounded",
    win_options = {
      winhighlight = "CursorLine:Visual,Search:None",
    },
  },
})
-- }}}

-- {{{ nvim-lint
require("lint").linters_by_ft = {
  ruby = { "rubocop" },
  typescript = { "eslint_d" },
  typescriptreact = { "eslint_d" },
}

-- Run lint (with debounce) when file is saved or changed
local timer = assert(vim.loop.new_timer())
local DEBOUNCE_MS = 500
local aug = vim.api.nvim_create_augroup("Lint", { clear = true })
vim.api.nvim_create_autocmd({ "BufWritePost", "TextChanged", "InsertLeave" }, {
  group = aug,
  callback = function()
    local bufnr = vim.api.nvim_get_current_buf()
    timer:stop()
    timer:start(
      DEBOUNCE_MS,
      0,
      vim.schedule_wrap(function()
        if vim.api.nvim_buf_is_valid(bufnr) then
          vim.api.nvim_buf_call(bufnr, function()
            require("lint").try_lint(nil, { ignore_errors = false })
          end)
        end
      end)
    )
  end,
})
-- }}}

-- {{{ lualine
local lualine = require("lualine")
local custom_options = {
  theme = vim.g.colors_name,
  sections = {
    lualine_c = { "filename" },
    lualine_d = { "pay_status" },
  },
}
local default_options = lualine.get_config()
local lualine_options = vim.tbl_deep_extend("force", default_options, custom_options)
lualine.setup(lualine_options)
-- }}}

-- {{{ startify
vim.g.startify_bookmarks = {
  { z = "~/.zshrc" },
  { l = "~/.config/nvim/init.lua" },
  { d = "~/.todo" },
  { c = "~/.config/kitty/kitty.conf" },
  { s = "~/.config/sway/config" },
  { p = "~/.config/waybar/config" },
}
vim.g.startify_commands = {
  { w = "Scratch" },
  { t = "terminal" },
  { b = "Buffers" },
  { f = "FzfFiles" },
}
vim.g.startify_custom_header = ""
vim.g.startify_lists = {
  { type = "commands", header = { "   Commands" } },
  { type = "bookmarks", header = { "   Bookmarks" } },
  { type = "files", header = { "   MRU" } },
  { type = "sessions", header = { "   Sessions" } },
}
-- }}}

-- {{{ luasnip
vim.api.nvim_create_user_command("LuaSnipEdit", function()
  require("luasnip.loaders").edit_snippet_files()
end, { nargs = 0 })
ls.config.setup({ store_selection_keys = "<Tab>", enable_autosnippets = true })
require("luasnip.loaders.from_lua").load({ paths = "~/.config/nvim/snippets" })
require("luasnip.loaders.from_vscode").lazy_load({
  exclude = { "gitcommit" },
})
-- }}}

-- {{{ treesitter
require("nvim-treesitter.configs").setup({
  -- A list of parser names, or "all"
  ensure_installed = {
    "cpp",
    "lua",
    "rust",
    "java",
    "python",
    "comment",
    "gitcommit",
    "diff",
    "git_rebase",
  },

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
  },
})
-- }}}

-- {{{ telescope
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local utils = require("telescope.utils")

require("telescope").setup({
  defaults = {
    layout_strategy = "flex",
    layout_config = {
      flip_columns = 220,
      prompt_position = "top",
      horizontal = { preview_cutoff = 80 },
    },
    sorting_strategy = "ascending",
    mappings = {
      i = {
        ["<esc>"] = actions.close,
        ["<Tab>"] = actions.move_selection_next,
        ["<S-Tab>"] = actions.move_selection_previous,
        ["<C-n>"] = actions.toggle_selection + actions.move_selection_next,
        ["<C-p>"] = actions.toggle_selection + actions.move_selection_previous,
      },
    },
    vimgrep_arguments = {
      "rg",
      "--color=never",
      "--no-heading",
      "--with-filename",
      "--line-number",
      "--column",
      "--smart-case",
    },
  },
  extensions = {
    fzf = {
      fuzzy = true, -- false will only do exact matching
      override_generic_sorter = true, -- override the generic sorter
      override_file_sorter = true, -- override the file sorter
      case_mode = "smart_case", -- or "ignore_case" or "respect_case"
    },
  },
  pickers = {
    live_grep = {
      on_input_filter_cb = function(prompt)
        -- AND operator for live_grep like how fzf handles spaces with wildcards in rg
        return { prompt = prompt:gsub("%s", ".*") }
      end,
    },
    help_tags = {
      mappings = {
        i = {
          ["<CR>"] = function(prompt_bufnr)
            local selection = action_state.get_selected_entry()
            if selection == nil then
              utils.__warn_no_selection("builtin.help_tags")
              return
            end
            actions.close(prompt_bufnr)
            if ShouldSplitHorizontal() then
              vim.cmd("help " .. selection.value)
            else
              vim.cmd("vert help " .. selection.value)
            end
          end,
        },
      },
    },
  },
})
-- }}}
