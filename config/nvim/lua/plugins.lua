-- vim:foldlevel=5
require("helpers")
require("keymaps")

local provider = function()
  if vim.g.use_telescope then
    return "telescope"
  else
    return "fzf_lua"
  end
end

return {
  { -- gruvbox
    "neevparikh/gruvbox.nvim",
    version = "*",
    lazy = false, -- make sure we load this during startup if it is your main colorscheme
    priority = 1000, -- make sure to load this before all the other start plugins
    opts = {
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
      inverse = false, -- invert background for search, diffs, statuslines and errors
      dim_inactive = false,
      transparent_mode = false,
      palette_overrides = {
        subtle_dark_yellow = "#783F02",
        dark_minus_1 = "#1B1E1F",
      },
    },
    config = function(_, opts)
      local gruvbox = require("gruvbox")
      local color_variant = CheckTheme()
      local contrast = GetContrast(color_variant)
      vim.opt.background = color_variant
      opts["contrast"] = contrast
      -- run setup to force palette overrides
      gruvbox.setup(opts)
      local colors = gruvbox.get_colors(contrast, color_variant)
      opts["overrides"] = {

        Visual = { bg = colors.bg2 },
        Search = { fg = colors.subtle_yellow, reverse = true },

        NormalFloat = { link = "Normal" },
        SignColumn = { link = "Normal" },

        String = { italic = false },
        Todo = { fg = colors.yellow, bg = "NONE", link = "Todo" },
        ErrorMsg = { fg = colors.red, bg = "NONE", link = "ErrorMsg" },
        ["@text.danger.comment"] = { fg = colors.red, bold = true, italic = true },
        -- lua_ls defines comment semantic group, overrides other comment-specific things
        ["@lsp.type.comment.lua"] = {},

        DiffDelete = { bg = colors.subtle_red, replace = true },
        DiffAdd = { bg = colors.subtle_green, replace = true },
        DiffChange = { bg = colors.bg_minus_1, replace = true },
        DiffText = { bg = colors.subtle_green, replace = true },

        ["@diff.minus.diff"] = { fg = colors.red },
        ["@diff.plus.diff"] = { fg = colors.green },

        FloatBorder = { link = "GruvboxBg2" },

        TelescopeBorder = { link = "GruvboxBg2" },
        TelescopePromptBorder = { link = "GruvboxBg2" },
        TelescopeResultsBorder = { link = "GruvboxBg2" },
        TelescopePreviewBorder = { link = "GruvboxBg2" },

        FzfLuaBorder = { link = "GruvboxBg2" },
        FzfLuaFzfBorder = { link = "GruvboxBg2" },
        FzfLuaPreviewBorder = { link = "GruvboxBg2" },

        MasonNormal = { link = "GruvboxFg1" },
        MasonMutedBlock = { link = "GruvboxRed" },
        MasonMutedBlockBold = { link = "GruvboxRed", bold = true },
        MasonHighlight = { link = "GruvboxOrange" },
        MasonHighlightBlock = { link = "GruvboxOrangeBold" },
        MasonHighlightBlockBold = { link = "GruvboxOrangeBold", bold = true },
        MasonHighlightSecondary = { link = "GruvboxYellow" },
        MasonHighlightBlockSecondary = { link = "GruvboxYellow" },
        MasonHighlightBlockBoldSecondary = { link = "GruvboxYellow", bold = true },
      }
      gruvbox.setup(opts)
      vim.cmd.colorscheme("gruvbox")
    end,
  },
  { -- startify
    "mhinz/vim-startify",
    init = function()
      vim.g.startify_enable_special = false
      vim.g.startify_update_oldfiles = true
      vim.g.startify_bookmarks = {
        { z = "~/.zshrc" },
        { l = "~/.config/nvim/init.lua" },
        { d = "~/.todo" },
        { c = "~/.config/kitty/kitty.conf" },
        { a = "~/.config/aerospace/aerospace.toml" },
        { p = "~/.config/sketchybar/sketchybarrc" },
      }
      vim.g.startify_commands = {
        { w = "Scratch" },
        { t = "terminal" },
        { b = "Buffers" },
        { f = "Files" },
      }
      vim.g.startify_custom_header = ""
      vim.g.startify_lists = {
        { type = "commands", header = { "   Commands" } },
        { type = "bookmarks", header = { "   Bookmarks" } },
        { type = "files", header = { "   MRU" } },
        { type = "sessions", header = { "   Sessions" } },
      }
    end,
  },
  { -- lualine
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        icons_enabled = true,
        theme = vim.g.colors_name,
        component_separators = "", -- { left = "", right = "" },
        section_separators = { left = "", right = "" },
        disabled_filetypes = {
          statusline = {},
          winbar = {},
        },
        ignore_focus = {},
        always_divide_middle = true,
        always_show_tabline = true,
        globalstatus = false,
        refresh = {
          statusline = 1000,
          tabline = 1000,
          winbar = 1000,
        },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diagnostics" },
        lualine_c = { "filename" },
        lualine_x = {
          function()
            if vim.g.codecompanion_processing then
              return ""
            else
              return ""
            end
          end,
          function()
            local status = require("codeium.virtual_text").status_string() or ""
            if status == "*" then
              return ""
            elseif status == " 0 " then
              return "0"
            else
              return status
            end
          end,
          "filetype",
        },
        lualine_y = {
          function()
            local diff_source = vim.b.minidiff_summary["source_name"]
            local icon
            if not diff_source then
              icon = ""
            end
            if diff_source == "git" then
              icon = "󰊤"
            elseif diff_source == "codecompanion" then
              icon = ""
            end
            return icon
          end,
          "progress",
        },
        lualine_z = {
          "location",
          function()
            return vim.g.remote_neovim_host and ("remote: %s"):format(vim.uv.os_gethostname()) or ""
          end,
        },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { "filename" },
        lualine_x = { "filetype" },
        lualine_y = {},
        lualine_z = {},
      },
      tabline = {},
      winbar = {},
      inactive_winbar = {},
      extensions = {},
    },
  },
  { "chrisbra/Colorizer" },

  { "romainl/vim-cool" },
  { "tpope/vim-repeat" },
  { "tpope/vim-commentary" },
  { -- vim lion
    "tommcdo/vim-lion",
    init = function()
      vim.g.lion_squeeze_spaces = true
    end,
  },
  { "unblevable/quick-scope" },
  { "machakann/vim-highlightedyank" },
  { "wellle/targets.vim" },
  { -- vim matchup
    "andymass/vim-matchup",
    init = function()
      vim.g.matchup_matchparen_offscreen = { method = "popup" }
    end,
  },

  { -- treesitter
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
      "nvim-treesitter/nvim-treesitter-refactor",
    },
    config = function()
      require("nvim-treesitter.configs").setup({
        sync_install = true,
        auto_install = true,
        ignore_install = {},

        highlight = {
          enable = true,
          disable = {},
          additional_vim_regex_highlighting = false,
        },
        matchup = {
          enable = true,
        },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "gnn",
            node_incremental = ".",
            scope_incremental = "grc",
            node_decremental = ",",
          },
        },
        refactor = {
          highlight_definitions = {
            enable = true,
            -- Set to false if you have an `updatetime` of ~100.
            clear_on_cursor_move = true,
          },
        },
        textobjects = {
          select = {
            enable = true,
            -- Automatically jump forward to textobj, similar to targets.vim
            lookahead = true,
            keymaps = {
              -- You can use the capture groups defined in textobjects.scm
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",
              ["ac"] = "@conditional.outer",
              ["ic"] = "@conditional.inner",
              ["ai"] = "@call.outer",
              ["ii"] = "@call.inner",
              ["ab"] = "@block.outer",
              ["ib"] = "@block.inner",
              ["is"] = "@statement.inner",
              ["as"] = "@statement.outer",
              ["aC"] = "@class.outer",
              ["iC"] = "@class.inner",
              ["al"] = "@loop.outer",
              ["il"] = "@loop.inner",
            },
          },
          swap = {
            enable = true,
            swap_next = {
              ["gns"] = "@parameter.inner",
            },
            swap_previous = {
              ["gnS"] = "@parameter.inner",
            },
          },
          move = {
            enable = true,
            set_jumps = true, -- whether to set jumps in the jumplist
            goto_next_start = {
              ["]m"] = "@function.outer",
              ["]]"] = { query = "@class.outer", desc = "Next class start" },
              ["]o"] = "@loop.*",
              ["]s"] = { query = "@scope", query_group = "locals", desc = "Next scope" },
              ["]z"] = { query = "@fold", query_group = "folds", desc = "Next fold" },
            },
            goto_next_end = {
              ["]M"] = "@function.outer",
              ["]["] = "@class.outer",
            },
            goto_previous_start = {
              ["[m"] = "@function.outer",
              ["[["] = "@class.outer",
            },
            goto_previous_end = {
              ["[M"] = "@function.outer",
              ["[]"] = "@class.outer",
            },
            goto_next = {
              ["]d"] = "@conditional.outer",
            },
            goto_previous = {
              ["[d"] = "@conditional.outer",
            },
          },
          lsp_interop = {
            enable = true,
            floating_preview_opts = {
              border = "rounded",
            },
            peek_definition_code = {
              ["<leader>sd"] = "@function.outer",
              ["<leader>sD"] = "@class.outer",
            },
          },
        },
      })
    end,
  },
  { -- fzf-lua
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons", "junegunn/fzf" },
    opts = {
      "telescope",
      winopts = {
        backdrop = 100,
        preview = {
          flip_columns = 160,
          layout = "flex",
        },
      },
      fzf_opts = {
        ["--ansi"] = true,
        ["--info"] = "inline-right",
        ["--height"] = "100%",
        ["--layout"] = "reverse",
        ["--border"] = "none",
        ["--highlight-line"] = false,
      },
      fzf_colors = {
        ["bg+"] = { "bg", "FzfLuaCursorLine" },
      },
    },
  },

  { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  { -- telescope
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope-fzf-native.nvim",
    },
    config = function()
      local actions = require("telescope.actions")
      local action_state = require("telescope.actions.state")
      local utils = require("telescope.utils")
      local telescope = require("telescope")

      telescope.setup({
        defaults = {
          layout_strategy = "flex",
          layout_config = {
            prompt_position = "top",
            horizontal = { preview_cutoff = 80, preview_width = 0.5 },
            flex = {
              flip_columns = 160,
            },
          },
          sorting_strategy = "ascending",
          mappings = {
            i = {
              ["<esc>"] = actions.close,
              ["<Tab>"] = actions.move_selection_next,
              ["<S-Tab>"] = actions.move_selection_previous,
              ["<C-n>"] = actions.toggle_selection + actions.move_selection_next,
              ["<C-p>"] = actions.toggle_selection + actions.move_selection_previous,
              ["<CR>"] = function(prompt_bufnr)
                local picker = action_state.get_current_picker(prompt_bufnr)
                local multi = picker:get_multi_selection()
                if not vim.tbl_isempty(multi) then
                  actions.send_selected_to_qflist(prompt_bufnr)
                  actions.open_qflist(prompt_bufnr)
                else
                  actions.select_default(prompt_bufnr)
                end
              end,
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
      telescope.load_extension("fzf")
    end,
  },

  { -- conform
    "stevearc/conform.nvim",
    opts = {
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
        python = { "ruff_format" },
        sql = { "sqlfmt" },
        tex = { "latexindent" },
      },
      format_after_save = { lsp_fallback = true },
      default_format_opts = {
        lsp_format = "fallback",
      },
    },
    config = function(_, opts)
      vim.keymap.set("x", "<leader>f", require("conform").format, { noremap = true, silent = true })
      vim.keymap.set("n", "<leader>f", function()
        require("conform").format({ async = true })
      end, { noremap = true, silent = true })
      require("conform").setup(opts)
    end,
  },
  { -- dressing
    "stevearc/dressing.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim",
    },
    opts = {
      input = {
        border = "rounded",
        win_options = {
          wrap = true,
          winhighlight = "CursorLine:Visual,Search:None",
        },
      },
      select = {
        builtin = {
          prefer_width = 0.4,
          border = "rounded",
          win_options = {
            wrap = true,
            winhighlight = "CursorLine:Visual,Search:None",
          },
        },
      },
    },
    config = function(_, opts)
      opts["telescope"] = require("telescope.themes").get_dropdown({
        wrap_results = true,
        layout_config = {
          prompt_position = "top",
          width = 0.5,
          height = 0.4,
        },
      })
      require("dressing").setup(opts)
    end,
  },
  { "mfussenegger/nvim-lint" },
  {
    "williamboman/mason.nvim",
    opts = {
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
    },
  },

  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "williamboman/mason.nvim",
    },
  },
  { -- nvim lspconfig
    "neovim/nvim-lspconfig",
    lazy = false,
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "bashls",
          "clangd",
          "jsonls",
          "lua_ls",
          "pyright",
          "ts_ls",
        },
        handlers = {
          lua_ls = function()
            local runtime_path = vim.split(package.path, ";")
            table.insert(runtime_path, "lua/?.lua")
            table.insert(runtime_path, "lua/?/init.lua")

            require("lspconfig").lua_ls.setup({
              settings = {
                Lua = {
                  -- Disable telemetry
                  telemetry = { enable = false },
                  runtime = {
                    -- Tell the language server which version of Lua you're using
                    -- (most likely LuaJIT in the case of Neovim)
                    version = "LuaJIT",
                    path = runtime_path,
                  },
                  diagnostics = {
                    -- Get the language server to recognize the `vim` global
                    globals = { "vim" },
                  },
                  workspace = {
                    checkThirdParty = false,
                    library = {
                      -- Make the server aware of Neovim runtime files
                      vim.env.VIMRUNTIME,
                      "${3rd}/luv/library",
                    },
                  },
                },
              },
            })
          end,
          pyright = function()
            require("lspconfig").pyright.setup({
              settings = {
                pyright = { venvPath = "~/.venvs/" },
              },
            })
          end,
          clangd = function()
            require("lspconfig").clangd.setup({
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
      require("lspconfig").rust_analyzer.setup({})
    end,
    init = function()
      vim.keymap.set("n", "<leader>d", vim.lsp.buf.definition, { noremap = true, silent = true })
      vim.keymap.set("n", "<leader>D", vim.lsp.buf.declaration, { noremap = true, silent = true })
      vim.keymap.set(
        "n",
        "<leader>i",
        vim.lsp.buf.implementation,
        { noremap = true, silent = true }
      )
      vim.keymap.set(
        "n",
        "<leader>t",
        vim.lsp.buf.type_definition,
        { noremap = true, silent = true }
      )
      vim.keymap.set("n", "<leader>u", vim.lsp.buf.references, { noremap = true, silent = true })
      vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { noremap = true, silent = true })
      vim.keymap.set(
        { "n", "x" },
        "<leader>C",
        vim.lsp.buf.code_action,
        { noremap = true, silent = true }
      )
      vim.keymap.set(
        "n",
        "<leader>K",
        vim.lsp.buf.signature_help,
        { noremap = true, silent = true }
      )
      vim.keymap.set("n", "<leader>N", vim.diagnostic.open_float, { noremap = true, silent = true })
      vim.keymap.set("n", "<leader>p", vim.diagnostic.goto_prev, { noremap = true, silent = true })
      vim.keymap.set("n", "<leader>n", vim.diagnostic.goto_next, { noremap = true, silent = true })
    end,
  },
  {
    "L3MON4D3/LuaSnip",
    dependencies = { "rafamadriz/friendly-snippets", "honza/vim-snippets" },
    config = function()
      vim.api.nvim_create_user_command("LuaSnipEdit", function()
        require("luasnip.loaders").edit_snippet_files()
      end, { nargs = 0 })
      require("luasnip").config.setup({
        store_selection_keys = "<Tab>",
        enable_autosnippets = true,
      })
      require("luasnip.loaders.from_lua").load({ paths = "~/.config/nvim/snippets" })
      require("luasnip.loaders.from_vscode").lazy_load({
        exclude = { "gitcommit" },
      })
    end,
    build = "make install_jsregexp",
  },
  { -- nvim cmp
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "saadparwaiz1/cmp_luasnip",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-nvim-lua",
      "L3MON4D3/LuaSnip",
    },
    config = function()
      local winopts = {
        border = "rounded",
        winhighlight = "CursorLine:Visual,Search:None",
      }
      local cmp = require("cmp")
      local ls = require("luasnip")
      local select_opts = { behavior = cmp.SelectBehavior.Select }
      cmp.setup({
        window = {
          completion = cmp.config.window.bordered(winopts),
          documentation = cmp.config.window.bordered(winopts),
        },
        mapping = {
          -- confirm selection
          ["<CR>"] = cmp.mapping.confirm({ select = false }),

          -- scroll up and down in the completion documentation
          ["<C-j>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.mapping.scroll_docs(5)
            else
              fallback()
            end
          end, { "i", "s" }),

          ["<C-k>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.mapping.scroll_docs(-5)
            else
              fallback()
            end
          end, { "i", "s" }),

          -- toggle completion
          ["<C-space>"] = cmp.mapping(function(_)
            if cmp.visible() then
              cmp.close()
            else
              cmp.complete()
            end
          end, { "i", "s" }),

          -- when menu is visible, navigate to next item
          -- when line is empty, insert a tab character
          -- else, activate completion
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item(select_opts)
            elseif ls.expand_or_jumpable() then
              ls.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),

          -- when menu is visible, navigate to previous item on list
          -- else, revert to default behavior
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item(select_opts)
            elseif ls.jumpable(-1) then
              ls.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        },
        sources = {
          { keyword_length = 3, name = "nvim_lsp" },
          { keyword_length = 2, name = "luasnip", option = { show_autosnippets = true } },
          { name = "path" },
          { keyword_length = 3, name = "buffer" },
        },
      })
    end,
  },

  { -- remote.nvim
    "neevparikh/remote-nvim.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim", -- For standard functions
      "MunifTanjim/nui.nvim", -- To build the plugin UI
      "nvim-telescope/telescope.nvim", -- For picking b/w different remote methods
    },
    opts = {
      progress_view = {
        type = "split",
        position = "right",
      },
      log = {
        level = "debug",
      },
      client_callback = function(port, _)
        local cmd = ("kitty -e nvim --server localhost:%s --remote-ui"):format(port)
        vim.fn.jobstart(cmd, {
          detach = true,
          on_exit = function(job_id, exit_code, event_type)
            -- This function will be called when the job exits
            print("Client", job_id, "exited with code", exit_code, "Event type:", event_type)
          end,
        })
      end,
      devpod = {
        binary = "devpod", -- Binary to use for devpod
        docker_binary = "docker", -- Binary to use for docker-related commands
        container_list = "all", -- How should docker list containers ("running_only" or "all")
      },
    },
    lazy = false,
  },
  { -- avante (AI code assistant)
    "yetone/avante.nvim",
    event = "VeryLazy",
    lazy = false,
    version = false, -- set this if you want to always pull the latest change
    opts = {
      provider = "claude",
      auto_suggestions_provider = "claude",
      claude = {
        endpoint = "https://api.anthropic.com",
        model = "claude-3-5-sonnet-20241022",
        temperature = 0,
        max_tokens = 4096,
      },
      behaviour = {
        auto_suggestions = false,
        auto_set_highlight_group = true,
        auto_set_keymaps = true,
        auto_apply_diff_after_generation = false,
        support_paste_from_clipboard = true,
      },
      mappings = {
        diff = {
          ours = "co",
          theirs = "ct",
          all_theirs = "ca",
          both = "cb",
          cursor = "cc",
          next = "]x",
          prev = "[x",
        },
        suggestion = {
          accept = "",
          next = "",
          prev = "",
          dismiss = "",
        },
        jump = {
          next = "]]",
          prev = "[[",
        },
        submit = {
          normal = "<CR>",
          insert = "<C-CR>",
        },
        sidebar = {
          apply_all = "A",
          apply_cursor = "a",
          switch_windows = "<Tab>",
          reverse_switch_windows = "<S-Tab>",
        },
      },
      hints = { enabled = false },
      windows = {
        position = "smart", -- the position of the sidebar
        wrap = true, -- similar to vim.o.wrap
        width = 30, -- default % based on available width
        sidebar_header = {
          enabled = true, -- true, false to enable/disable the header
          align = "center", -- left, center, right for title
          rounded = true,
        },
        input = {
          prefix = "» ",
        },
        edit = {
          border = "rounded",
          start_insert = true, -- Start insert mode when opening the edit window
        },
        ask = {
          floating = false, -- Open the 'AvanteAsk' prompt in a floating window
          start_insert = true, -- Start insert mode when opening the ask window, only effective if floating = true.
          border = "rounded",
        },
      },
      highlights = {
        diff = {
          current = "DiffDelete",
          incoming = "DiffAdd",
        },
      },
      diff = {
        autojump = true,
        list_opener = "copen",
      },
    },
    -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    build = "make",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      --- The below dependencies are optional,
      "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
      {
        -- support for image pasting
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {
          -- recommended settings
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
          },
        },
      },
      {
        -- Make sure to set this up properly if you have lazy=true
        "MeanderingProgrammer/render-markdown.nvim",
        opts = {
          file_types = { "markdown", "Avante" },
        },
        ft = { "markdown", "Avante" },
      },
    },
  },
  {
    "Exafunction/codeium.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "hrsh7th/nvim-cmp",
      "nvim-lualine/lualine.nvim",
    },
    opts = {
      enable_cmp_source = false,
      virtual_text = {
        enabled = true,
        manual = false,
        filetypes = {},
        default_filetype_enabled = true,
        idle_delay = 75,
        virtual_text_priority = 65535,
        map_keys = true,
        accept_fallback = "<Tab>",
        key_bindings = {
          -- Accept the current completion.
          accept = "<Tab>",
          -- Accept the next word.
          accept_word = "<c-k>",
          -- Accept the next line.
          accept_line = "<c-l>",
          -- Clear the virtual text.
          clear = "<c-x>",
          -- Cycle to the next completion.
          next = "<c-Tab>",
          -- Cycle to the previous completion.
          prev = "<c-S-Tab>",
        },
      },
    },
    config = function(_, opts)
      require("codeium").setup(opts)
      require("codeium.virtual_text").set_statusbar_refresh(function()
        require("lualine").refresh()
      end)
    end,
  },
  {
    "echasnovski/mini.diff",
    version = false,
    opts = {
      -- Options for how hunks are visualized
      view = {
        -- Visualization style. Possible values are 'sign' and 'number'.
        -- Default: 'number' if line numbers are enabled, 'sign' otherwise.
        style = vim.go.number and "number" or "sign",
        -- Signs used for hunks with 'sign' view
        signs = { add = "▒", change = "▒", delete = "▒" },
        -- Priority of used visualization extmarks
        priority = 199,
      },
      -- Source for how reference text is computed/updated/etc
      -- Uses content from Git index by default
      source = nil,
      -- Delays (in ms) defining asynchronous processes
      delay = {
        -- How much to wait before update following every text change
        text_change = 200,
      },
      -- Module mappings. Use `''` (empty string) to disable one.
      mappings = {
        -- Apply hunks inside a visual/operator region
        apply = "gh",
        -- Reset hunks inside a visual/operator region
        reset = "gH",
        -- Hunk range textobject to be used inside operator
        -- Works also in Visual mode if mapping differs from apply and reset
        textobject = "gh",
        -- Go to hunk range in corresponding direction
        goto_first = "[H",
        goto_prev = "[h",
        goto_next = "]h",
        goto_last = "]H",
      },
      -- Various options
      options = {
        -- Diff algorithm. See `:h vim.diff()`.
        algorithm = "histogram",
        -- Whether to use "indent heuristic". See `:h vim.diff()`.
        indent_heuristic = true,
        -- The amount of second-stage diff to align lines (in Neovim>=0.9)
        linematch = 60,
        -- Whether to wrap around edges during hunk navigation
        wrap_goto = false,
      },
    },
  },
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "echasnovski/mini.diff",
      "nvim-treesitter/nvim-treesitter",
      -- The following are optional:
      { "MeanderingProgrammer/render-markdown.nvim", ft = { "markdown", "codecompanion" } },
    },
    opts = {
      log_level = "TRACE",
      display = {
        action_palette = {
          width = 95,
          height = 13,
          prompt = "Prompt ", -- Prompt used for interactive LLM calls
          provider = "default", -- default|telescope|mini_pick
          opts = {
            show_default_actions = true, -- Show the default actions in the action palette?
            show_default_prompt_library = true, -- Show the default prompt library in the action palette?
          },
        },
        chat = {
          render_headers = false,
          window = {
            layout = "vertical", -- float|vertical|horizontal|buffer
            border = "single",
            height = 0.8,
            width = 0.4,
            relative = "editor",
            opts = {
              breakindent = true,
              cursorcolumn = false,
              cursorline = false,
              foldcolumn = "0",
              linebreak = true,
              list = false,
              signcolumn = "no",
              spell = false,
              wrap = true,
            },
          },
          intro_message = "Welcome to CodeCompanion ✨! Press ? for options",
          show_header_separator = false, -- Show header separators in the chat buffer? Set this to false if you're using an exteral markdown formatting plugin
          separator = "─", -- The separator between the different messages in the chat buffer
          show_references = true, -- Show references (from slash commands and variables) in the chat buffer?
          show_settings = false, -- Show LLM settings at the top of the chat buffer?
          show_token_count = true, -- Show the token count for each response?
          start_in_insert_mode = false, -- Open the chat buffer in insert mode?
          token_count = function(tokens, _) -- The function to display the token count
            return " (" .. tokens .. " tokens)"
          end,
        },
        diff = {
          enabled = true,
          close_chat_at = 240, -- Close an open chat buffer if the total columns of your display are less than...
          layout = "vertical", -- vertical|horizontal split for default provider
          opts = {
            "internal",
            "filler",
            "closeoff",
            "algorithm:patience",
            "followwrap",
            "linematch:120",
          },
          provider = "mini_diff", -- default|mini_diff
        },
        inline = {
          -- If the inline prompt creates a new buffer, how should we display this?
          layout = "vertical", -- vertical|horizontal|buffer
        },
      },
      strategies = {
        -- CHAT STRATEGY ----------------------------------------------------------
        chat = {
          adapter = "anthropic",
          roles = {
            llm = "CodeCompanion", -- The markdown header content for the LLM's responses
            user = "Me", -- The markdown header for your questions
          },
          variables = {
            ["buffer"] = {
              callback = "strategies.chat.variables.buffer",
              description = "Share the current buffer with the LLM",
              opts = {
                contains_code = true,
                has_params = true,
              },
            },
            ["lsp"] = {
              callback = "strategies.chat.variables.lsp",
              description = "Share LSP information and code for the current buffer",
              opts = {
                contains_code = true,
                hide_reference = true,
              },
            },
            ["viewport"] = {
              callback = "strategies.chat.variables.viewport",
              description = "Share the code that you see in Neovim with the LLM",
              opts = {
                contains_code = true,
                hide_reference = true,
              },
            },
          },
          slash_commands = {
            ["buffer"] = {
              callback = "strategies.chat.slash_commands.buffer",
              description = "Insert open buffers",
              opts = {
                contains_code = true,
                provider = provider(), -- default|telescope|mini_pick|fzf_lua
              },
            },
            ["fetch"] = {
              callback = "strategies.chat.slash_commands.fetch",
              description = "Insert URL contents",
              opts = {
                adapter = "jina",
              },
            },
            ["file"] = {
              callback = "strategies.chat.slash_commands.file",
              description = "Insert a file",
              opts = {
                contains_code = true,
                max_lines = 1000,
                provider = provider(), -- default|telescope|mini_pick|fzf_lua
              },
            },
            ["help"] = {
              callback = "strategies.chat.slash_commands.help",
              description = "Insert content from help tags",
              opts = {
                contains_code = false,
                provider = provider(), -- telescope|mini_pick|fzf_lua
              },
            },
            ["now"] = {
              callback = "strategies.chat.slash_commands.now",
              description = "Insert the current date and time",
              opts = {
                contains_code = false,
              },
            },
            ["symbols"] = {
              callback = "strategies.chat.slash_commands.symbols",
              description = "Insert symbols for a selected file",
              opts = {
                contains_code = true,
                provider = provider(), -- default|telescope|mini_pick|fzf_lua
              },
            },
            ["terminal"] = {
              callback = "strategies.chat.slash_commands.terminal",
              description = "Insert terminal output",
              opts = {
                contains_code = false,
              },
            },
          },
          keymaps = {
            options = {
              modes = {
                n = "?",
              },
              callback = "keymaps.options",
              description = "Options",
              hide = true,
            },
            completion = {
              modes = {
                i = "<C-_>",
              },
              index = 1,
              callback = "keymaps.completion",
              condition = function()
                local has_cmp, _ = pcall(require, "cmp")
                return not has_cmp
              end,
              description = "Completion Menu",
            },
            send = {
              modes = {
                n = { "<CR>", "<C-s>" },
                i = "<C-s>",
              },
              index = 1,
              callback = "keymaps.send",
              description = "Send",
            },
            regenerate = {
              modes = {
                n = "gr",
              },
              index = 2,
              callback = "keymaps.regenerate",
              description = "Regenerate the last response",
            },
            close = {
              modes = {
                n = "<C-c>",
                i = "<C-c>",
              },
              index = 3,
              callback = "keymaps.close",
              description = "Close Chat",
            },
            stop = {
              modes = {
                n = "q",
              },
              index = 4,
              callback = "keymaps.stop",
              description = "Stop Request",
            },
            clear = {
              modes = {
                n = "gx",
              },
              index = 5,
              callback = "keymaps.clear",
              description = "Clear Chat",
            },
            codeblock = {
              modes = {
                n = "gc",
              },
              index = 6,
              callback = "keymaps.codeblock",
              description = "Insert Codeblock",
            },
            yank_code = {
              modes = {
                n = "gy",
              },
              index = 7,
              callback = "keymaps.yank_code",
              description = "Yank Code",
            },
            next_chat = {
              modes = {
                n = "}",
              },
              index = 8,
              callback = "keymaps.next_chat",
              description = "Next Chat",
            },
            previous_chat = {
              modes = {
                n = "{",
              },
              index = 9,
              callback = "keymaps.previous_chat",
              description = "Previous Chat",
            },
            next_header = {
              modes = {
                n = "]]",
              },
              index = 10,
              callback = "keymaps.next_header",
              description = "Next Header",
            },
            previous_header = {
              modes = {
                n = "[[",
              },
              index = 11,
              callback = "keymaps.previous_header",
              description = "Previous Header",
            },
            change_adapter = {
              modes = {
                n = "ga",
              },
              index = 12,
              callback = "keymaps.change_adapter",
              description = "Change adapter",
            },
            fold_code = {
              modes = {
                n = "gf",
              },
              index = 13,
              callback = "keymaps.fold_code",
              description = "Fold code",
            },
            debug = {
              modes = {
                n = "gd",
              },
              index = 14,
              callback = "keymaps.debug",
              description = "View debug info",
            },
            system_prompt = {
              modes = {
                n = "gs",
              },
              index = 15,
              callback = "keymaps.toggle_system_prompt",
              description = "Toggle the system prompt",
            },
          },
          opts = {
            register = "+", -- The register to use for yanking code
            yank_jump_delay_ms = 400, -- Delay in milliseconds before jumping back from the yanked code
          },
        },
        -- INLINE STRATEGY --------------------------------------------------------
        inline = {
          adapter = "anthropic",
          keymaps = {
            accept_change = {
              modes = {
                n = "ga",
              },
              index = 1,
              callback = "keymaps.accept_change",
              description = "Accept change",
            },
            reject_change = {
              modes = {
                n = "gr",
              },
              index = 2,
              callback = "keymaps.reject_change",
              description = "Reject change",
            },
          },
          prompts = {
            -- The prompt to send to the LLM when a user initiates the inline strategy and it needs to convert to a chat
            inline_to_chat = function(context)
              return string.format(
                [[I want you to act as an expert and senior developer in the %s language. I will ask you questions, perhaps giving you code examples, and I want you to advise me with explanations and code where neccessary.]],
                context.filetype
              )
            end,
          },
        },
        -- AGENT STRATEGY ---------------------------------------------------------
        agent = {
          ["full_stack_dev"] = {
            description = "Full Stack Developer - Can run code, edit code and modify files",
            system_prompt = "**DO NOT** make any assumptions about the dependencies that a user has installed. If you need to install any dependencies to fulfil the user's request, do so via the Command Runner tool. If the user doesn't specify a path, use their current working directory.",
            tools = {
              "cmd_runner",
              "editor",
              "files",
            },
          },
          tools = {
            ["cmd_runner"] = {
              callback = "strategies.chat.tools.cmd_runner",
              description = "Run shell commands initiated by the LLM",
              opts = {
                user_approval = true,
              },
            },
            ["editor"] = {
              callback = "strategies.chat.tools.editor",
              description = "Update a buffer with the LLM's response",
            },
            ["files"] = {
              callback = "strategies.chat.tools.files",
              description = "Update the file system with the LLM's response",
              opts = {
                user_approval = true,
              },
            },
            ["rag"] = {
              callback = "strategies.chat.tools.rag",
              description = "Supplement the LLM with real-time info from the internet",
              opts = {
                hide_output = true,
              },
            },
            opts = {
              auto_submit_errors = false, -- Send any errors to the LLM automatically?
              auto_submit_success = false, -- Send any successful output to the LLM automatically?
              system_prompt = [[## Tools
  You now have access to tools:
  - These enable you to assist the user with specific tasks
  - The user will outline which specific tools you have access to
  - You trigger a tool by following a specific XML schema which is defined for each tool
  You must:
  - Only use the tool when prompted by the user, despite having access to it
  - Follow the specific tool's schema
  - Respond with the schema in XML format
  - Ensure the schema is in a markdown code block that is designated as XML
  - Ensure any output you're intending to execute will be able to parsed as valid XML
  Points to note:
  - The user detects that you've triggered a tool by using Tree-sitter to parse your markdown response
  - If you call multiple tools within the same response:
  - Each unique tool MUST be called in its own, individual, XML codeblock
  - Tools of the same type SHOULD be called in the same XML codeblock
  - If your response doesn't follow the tool's schema, the tool will not execute
  - Tools should not alter your core tasks and how you respond to a user]],
            },
          },
        },
        -- CMD STRATEGY -----------------------------------------------------------
        cmd = {
          adapter = "anthropic",
          opts = {
            system_prompt = [[You are currently plugged in to the Neovim text editor on a user's machine. Your core task is to generate an command-line inputs that the user can run within Neovim. Below are some rules to adhere to:
  - Return plain text only
  - Do not wrap your response in a markdown block or backticks
  - Do not use any line breaks or newlines in you response
  - Do not provide any explanations
  - Generate an command that is valid and can be run in Neovim
  - Ensure the command is relevant to the user's request]],
          },
        },
      },
      adapters = {
        anthropic = function()
          return require("codecompanion.adapters").extend("anthropic", {
            env = {
              api_key = "ANTHROPIC_API_KEY",
            },
            schema = {
              model = { default = "claude-3-5-sonnet-20241022" },
              max_tokens = { default = 8192 },
            },
          })
        end,
        openai = function()
          return require("codecompanion.adapters").extend("anthropic", {
            env = {
              api_key = "OPENAI_API_KEY",
            },
            schema = {
              model = { default = "o1-preview-2024-09-12" },
              max_tokens = { default = 8192 },
            },
          })
        end,
      },
    },
  },
}
