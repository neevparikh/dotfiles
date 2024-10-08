-- vim:foldmethod=marker:foldlevel=0

-- {{{ ensure packer is installed
local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({
      "git",
      "clone",
      "--depth",
      "1",
      "https://github.com/wbthomason/packer.nvim",
      install_path,
    })
    vim.cmd([[packadd packer.nvim]])
    return true
  end
  return false
end
-- }}}

local packer_bootstrap = ensure_packer()

-- {{{ plugins
return require("packer").startup(function(use)
  use("wbthomason/packer.nvim")

  use({ "ellisonleao/gruvbox.nvim" })
  use("lervag/vimtex")
  use({
    "andymass/vim-matchup",
    setup = function()
      vim.g.matchup_matchparen_offscreen = { method = "popup" }
    end,
  })
  use({ "nvim-treesitter/nvim-treesitter", run = ":TSUpdate" })
  use({
    "VonHeikemen/lsp-zero.nvim",
    requires = {
      -- LSP Support
      { "neovim/nvim-lspconfig" },
      { "williamboman/mason.nvim" },
      { "williamboman/mason-lspconfig.nvim" },

      -- Autocompletion
      { "hrsh7th/nvim-cmp" },
      { "hrsh7th/cmp-buffer" },
      { "hrsh7th/cmp-path" },
      { "saadparwaiz1/cmp_luasnip" },
      { "hrsh7th/cmp-nvim-lsp" },
      { "hrsh7th/cmp-nvim-lua" },

      -- Snippets
      { "L3MON4D3/LuaSnip" },
      { "honza/vim-snippets" },
      { "rafamadriz/friendly-snippets" },
    },
  })

  use("mfussenegger/nvim-dap")
  use("mfussenegger/nvim-jdtls")
  use("romainl/vim-cool")
  use("junegunn/fzf")
  use("junegunn/fzf.vim")
  use({
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    requires = { "nvim-lua/plenary.nvim" },
  })
  use({ "nvim-telescope/telescope-fzf-native.nvim", run = "make" })
  use("tommcdo/vim-lion")
  use("tpope/vim-repeat")
  use("tpope/vim-commentary")
  use("mhinz/vim-startify")
  use("tpope/vim-fugitive")
  use("christoomey/vim-conflicted")
  use("nvim-lualine/lualine.nvim")
  use("simnalamburt/vim-mundo")
  use("wellle/targets.vim")
  use("unblevable/quick-scope")
  use("bfredl/nvim-miniyank")
  use("machakann/vim-highlightedyank")
  use("airblade/vim-rooter")
  use("chrisbra/Colorizer")
  use("stevearc/conform.nvim")
  use("mfussenegger/nvim-lint")
  use("stevearc/dressing.nvim")

  if packer_bootstrap then
    require("packer").sync()
  end
end)
-- }}}
