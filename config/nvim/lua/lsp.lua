vim.lsp.enable("bashls")
vim.lsp.enable("clangd")
vim.lsp.enable("jsonls")
vim.lsp.enable("lua_ls")
vim.lsp.enable("pyright")
vim.lsp.enable("ts_ls")

local runtime_path = vim.split(package.path, ";")
table.insert(runtime_path, "lua/?.lua")
table.insert(runtime_path, "lua/?/init.lua")

vim.lsp.config("lua_ls", {
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
vim.lsp.config("pyright", {
  settings = {
    pyright = { venvPath = "~/.venvs/" },
  },
})
vim.lsp.config("ts_ls", {
  root_dir = require("lspconfig").util.root_pattern({ "package.json", "tsconfig.json" }),
  single_file_support = false,
  settings = {},
})
vim.lsp.config("denols", {
  root_dir = require("lspconfig").util.root_pattern({ "deno.json", "deno.jsonc" }),
  single_file_support = false,
  settings = {},
})
vim.lsp.config("clangd", {
  settings = {
    clangd = {
      arguments = {
        "--header-insertion=never",
        "--query-driver=**",
      },
    },
  },
})
