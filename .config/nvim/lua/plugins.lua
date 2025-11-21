-- vim:foldlevel=5
require("helpers")
require("keymaps")

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
        { l = "~/.config/nvim/lua/plugins.lua" },
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
  {
    "norcalli/nvim-colorizer.lua",
    config = function()
      require("colorizer").setup({ "*" }, {
        RGB = true, -- #RGB hex codes
        RRGGBB = true, -- #RRGGBB hex codes
        names = true, -- "Name" codes like Blue
        RRGGBBAA = false, -- #RRGGBBAA hex codes
        rgb_fn = false, -- CSS rgb() and rgba() functions
        hsl_fn = false, -- CSS hsl() and hsla() functions
        css = false, -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
        css_fn = false, -- Enable all CSS *functions*: rgb_fn, hsl_fn
        mode = "background", -- Set the display mode. Available modes: foreground, background
      })
    end,
  },
  {
    "stevearc/resession.nvim",
    config = function()
      local resession = require("resession")
      resession.setup()
      vim.keymap.set("n", "<leader>ss", resession.save)
      vim.keymap.set("n", "<leader>sl", resession.load)
      vim.keymap.set("n", "<leader>sd", resession.delete)
    end,
  },
  {
    "kndndrj/nvim-dbee",
    dependencies = {
      "MunifTanjim/nui.nvim",
    },
    build = function()
      -- Install tries to automatically detect the install method.
      -- if it fails, try calling it with one of these parameters:
      --    "curl", "wget", "bitsadmin", "go"
      require("dbee").install()
    end,
    config = function()
      require("dbee").setup({
        drawer = {
          disable_help = true,
          mappings = {
            -- manually refresh drawer
            { key = "r", mode = "n", action = "refresh" },
            -- actions perform different stuff depending on the node:
            -- action_1 opens a note or executes a helper
            { key = "<CR>", mode = "n", action = "action_1" },
            -- action_2 renames a note or sets the connection as active manually
            { key = "rn", mode = "n", action = "action_2" },
            -- action_3 deletes a note or connection (removes connection from the file if you configured it like so)
            { key = "dd", mode = "n", action = "action_3" },
            -- these are self-explanatory:
            { key = "c", mode = "n", action = "collapse" },
            { key = "e", mode = "n", action = "expand" },
            { key = "o", mode = "n", action = "toggle" },
            -- mappings for menu popups:
            { key = "<CR>", mode = "n", action = "menu_confirm" },
            { key = "y", mode = "n", action = "menu_yank" },
            { key = "<Esc>", mode = "n", action = "menu_close" },
            { key = "q", mode = "n", action = "menu_close" },
          },
        },
        result = {
          page_size = 100,
          mappings = {
            -- next/previous page
            { key = "L", mode = "", action = "page_next" },
            { key = "H", mode = "", action = "page_prev" },
            { key = "E", mode = "", action = "page_last" },
            { key = "F", mode = "", action = "page_first" },
            -- yank rows as csv/json
            { key = "yaj", mode = "n", action = "yank_current_json" },
            { key = "yaj", mode = "v", action = "yank_selection_json" },
            { key = "yaJ", mode = "", action = "yank_all_json" },
            { key = "yac", mode = "n", action = "yank_current_csv" },
            { key = "yac", mode = "v", action = "yank_selection_csv" },
            { key = "yaC", mode = "", action = "yank_all_csv" },

            -- cancel current call execution
            { key = "<C-c>", mode = "", action = "cancel_call" },
          },
        },
        editor = {
          -- directory = vim.fn.expand("~/",
          mappings = {
            -- run what's currently selected on the active connection
            { key = "<S-CR>", mode = "v", action = "run_selection" },
            -- run the whole file on the active connection
            { key = "<S-CR>", mode = "n", action = "run_file" },
          },
        },
        sources = {
          require("dbee.sources").FileSource:new(vim.fn.expand("~/.db.json")),
        },
      })
    end,
  },
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
          disable = { "jinja" },
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
          wrap = true,
        },
      },
      fzf_opts = {
        ["--ansi"] = true,
        ["--info"] = "inline-right",
        ["--height"] = "100%",
        ["--layout"] = "reverse",
        ["--border"] = "none",
        ["--highlight-line"] = true,
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
              ["<Tab>"] = actions.toggle_selection + actions.move_selection_next,
              ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_previous,
              ["<C-n>"] = actions.move_selection_next,
              ["<C-p>"] = actions.move_selection_previous,
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
        -- toml = { "pyproject-fmt" },
        go = { "goimports", "gofmt" },
        lua = { "stylua" },
        python = { "ruff_organize_imports", "ruff_fix", "ruff_format" },
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
    "mason-org/mason.nvim",
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
  { "neovim/nvim-lspconfig", lazy = false },
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
  {
    "folke/snacks.nvim",
    opts = {
      input = {},
    },
  },
  { -- avante (AI code assistant)
    "yetone/avante.nvim",
    event = "VeryLazy",
    lazy = false,
    version = false, -- set this if you want to always pull the latest change
    opts = {
      mode = "legacy",
      provider = "claude",
      auto_suggestions_provider = "claude",
      providers = {
        claude = {
          endpoint = GetAnthropicBaseUrl(),
          model = "claude-sonnet-4-20250514",
          extra_request_body = {
            temperature = 0,
            max_tokens = 8192,
          },
        },
      },
      behaviour = {
        enable_cursor_planning_mode = true, -- enable cursor planning mode!
        auto_suggestions = false,
        auto_set_highlight_group = true,
        auto_set_keymaps = true,
        auto_apply_diff_after_generation = false,
        support_paste_from_clipboard = true,
        minimize_diff = true,
        enable_token_counting = true,
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
          insert = "<S-CR>",
        },
        sidebar = {
          apply_all = "A",
          apply_cursor = "a",
          retry_user_request = "r",
          edit_user_request = "e",
          switch_windows = "<Tab>",
          reverse_switch_windows = "<S-Tab>",
          remove_file = "d",
          add_file = "@",
          close = { "<Esc>", "q" },
          close_from_input = nil,
        },
      },
      selector = { provider = "fzf_lua" },
      selection = {
        enabled = true,
        hint_display = "none",
      },
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
    config = function(_, opts)
      require("avante").setup(opts)
    end,
    -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    build = "make",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "stevearc/dressing.nvim",
      "folke/snacks.nvim",
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
          win_options = {
            conceallevel = {
              default = vim.o.conceallevel,
              rendered = 3,
            },
            concealcursor = {
              default = vim.o.concealcursor,
              rendered = "",
            },
          },
          render_modes = { "n", "c", "t", "i" },
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
        filetypes = {
          markdown = false,
          jsonl = false,
          json = false,
          text = false,
        },
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
    "GCBallesteros/NotebookNavigator.nvim",
    keys = {
      {
        "]h",
        function()
          require("notebook-navigator").move_cell("d")
        end,
      },
      {
        "[h",
        function()
          require("notebook-navigator").move_cell("u")
        end,
      },
      { "<leader>X", "<cmd>lua require('notebook-navigator').run_cell()<cr>" },
      { "<leader>x", "<cmd>lua require('notebook-navigator').run_and_move()<cr>" },
    },
    dependencies = {
      "echasnovski/mini.comment",
      -- "hkupty/iron.nvim", -- repl provider
      -- "akinsho/toggleterm.nvim", -- alternative repl provider
      "benlubas/molten-nvim", -- alternative repl provider
      "nvimtools/hydra.nvim",
    },
    event = "VeryLazy",
    opts = {},
  },
  {
    "benlubas/molten-nvim",
    version = "^1.0.0", -- use version <2.0.0 to avoid breaking changes
    build = ":UpdateRemotePlugins",
    dependencies = { "3rd/image.nvim" },
    init = function()
      -- these are examples, not defaults. Please see the readme
      vim.g.molten_image_provider = "image.nvim"
      vim.g.molten_output_win_max_height = 20
    end,
  },
  {
    -- see the image.nvim readme for more information about configuring this plugin
    "3rd/image.nvim",
    opts = {
      backend = "kitty", -- whatever backend you would like to use
      max_width = 100,
      max_height = 12,
      max_height_window_percentage = math.huge,
      max_width_window_percentage = math.huge,
      window_overlap_clear_enabled = true, -- toggles images when windows are overlapped
      window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
    },
  },
  {
    "echasnovski/mini.ai",
    dependencies = { "GCBallesteros/NotebookNavigator.nvim" },

    version = "*",
    opts = function()
      return {
        n_lines = 1000,
        custom_textobjects = {
          h = require("notebook-navigator").miniai_spec,
        },
      }
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
    config = function(_, opts)
      require("mini.diff").setup(opts)
      vim.keymap.set("n", "<leader>m", function()
        require("mini.diff").toggle_overlay()
      end, { noremap = true, silent = true })
    end,
  },
  -- {
  --   "luckasRanarison/tailwind-tools.nvim",
  --   name = "tailwind-tools",
  --   build = ":UpdateRemotePlugins",
  --   dependencies = {
  --     "nvim-treesitter/nvim-treesitter",
  --     "nvim-telescope/telescope.nvim", -- optional
  --     "neovim/nvim-lspconfig", -- optional
  --   },
  --   opts = {}, -- your configuration
  -- },
}
