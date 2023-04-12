-- vim: set foldmethod=marker:

-- {{{ ensure packer is installed
local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({ 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path })
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end
-- }}}

local packer_bootstrap = ensure_packer()

-- {{{ plugins
return require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'

  use 'neevparikh/gruvbox'
  use 'lervag/vimtex'
  use 'honza/vim-snippets'
  use { 'andymass/vim-matchup', setup = function()
    -- may set any options here
    vim.g.matchup_matchparen_offscreen = { method = "popup" }
  end
  }
  use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
  use { 'anuvyklack/pretty-fold.nvim', config = function()
    local pf = require('pretty-fold')
    pf.ft_setup('lua', {
      matchup_patterns = {
        { '^%s*do$', 'end' }, -- do ... end blocks
        { '^%s*if', 'end' }, -- if ... end
        { '^%s*for', 'end' }, -- for
        { 'function%s*%(', 'end' }, -- 'function( or 'function (''
        { '{', '}' },
        { '%(', ')' }, -- % to escape lua pattern char
        { '%[', ']' }, -- % to escape lua pattern char
      },
    })
    pf.setup()
  end
  }
  use { 'VonHeikemen/lsp-zero.nvim',
    requires = {
      -- LSP Support
      { 'neovim/nvim-lspconfig' },
      { 'williamboman/mason.nvim' },
      { 'williamboman/mason-lspconfig.nvim' },

      -- Autocompletion
      { 'hrsh7th/nvim-cmp' },
      { 'hrsh7th/cmp-buffer' },
      { 'hrsh7th/cmp-path' },
      { 'saadparwaiz1/cmp_luasnip' },
      { 'hrsh7th/cmp-nvim-lsp' },
      { 'hrsh7th/cmp-nvim-lua' },

      -- Snippets
      { 'L3MON4D3/LuaSnip' },
      { 'rafamadriz/friendly-snippets' },
    }
  }

  use({ 'scalameta/nvim-metals', requires = { "nvim-lua/plenary.nvim" } })
  use 'mfussenegger/nvim-dap'
  use 'romainl/vim-cool'
  use { 'junegunn/fzf', run = ":call fzf#install()" }
  use { 'ibhagwan/fzf-lua', requires = { 'kyazdani42/nvim-web-devicons' } }
  use 'tmhedberg/SimpylFold'
  use 'tommcdo/vim-lion'
  use 'tpope/vim-repeat'
  use 'tpope/vim-commentary'
  use 'mhinz/vim-startify'
  use 'tpope/vim-fugitive'
  use 'christoomey/vim-conflicted'
  use 'nvim-lualine/lualine.nvim'
  use 'simnalamburt/vim-mundo'
  use 'wellle/targets.vim'
  use 'unblevable/quick-scope'
  use 'bfredl/nvim-miniyank'
  use 'machakann/vim-highlightedyank'
  use 'airblade/vim-rooter'
  use 'chrisbra/Colorizer'

  if packer_bootstrap then
    require('packer').sync()
  end

end)
-- }}}
