-- Post to read: https://jdhao.github.io/2021/07/11/from_vim_plug_to_packer/
-- This was copied from https://www.chrisatmachine.com/Neovim-2/03-plugins/
local fn = vim.fn

-- Automatically install packer
local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  PACKER_BOOTSTRAP = fn.system({
	  'git',
	  'clone',
	  '--depth',
	  '1',
	  'https://github.com/wbthomason/packer.nvim',
	  install_path
  })
  print('Installing packer close and reopen Neovim...')
  vim.cmd [[packadd packer.nvim]]
end

-- Autocommand that reloads neovim whenever you save the plugins.lua file
vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerSync
  augroup end
]])
-- Use a protected call so we don't error out on first use
local status_ok, packer = pcall(require, 'packer')
if not status_ok then
  return
end

-- Have packer use a popup window
packer.init({
    display = {
      open_fn = function()
        return require('packer.util').float({ border = 'rounded' })
      end
    }
  }
)

-- Install your plugins here
return packer.startup(function(use)
  -- Plugin manager, packer can manage itself
  use 'wbthomason/packer.nvim'

  -- Useful lua functions used ny lots of plugins
  use 'nvim-lua/plenary.nvim'

  -- File tree
  use {
    'kyazdani42/nvim-tree.lua',
    requires = {
      'kyazdani42/nvim-web-devicons',
    },
    config = function() require'nvim-tree'.setup {} end
  }

  -- LSP
  use {
    'folke/neodev.nvim',
    'mfussenegger/nvim-dap',
    'williamboman/mason.nvim',
    'williamboman/mason-lspconfig.nvim',
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    'neovim/nvim-lspconfig',
  }

  -- Completion
  use 'hrsh7th/cmp-nvim-lsp'
  use 'hrsh7th/cmp-buffer'
  use 'hrsh7th/cmp-path'
  use 'hrsh7th/cmp-cmdline'
  use 'hrsh7th/nvim-cmp'
  use 'L3MON4D3/LuaSnip'
  use 'saadparwaiz1/cmp_luasnip'
  use {
    'zbirenbaum/copilot.lua',
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        -- disabling due to using copilot-cmp
        suggestion = { enabled = false },
        panel = { enabled = false }
      })
    end
  }
  use {
    'zbirenbaum/copilot-cmp',
    after = { 'copilot.lua' },
    config = function()
      require('copilot_cmp').setup {
        method = 'getCompletionsCycling'
      }
    end
  }

  -- Telescope
  use {
    'nvim-telescope/telescope.nvim',
    requires = {
      'debugloop/telescope-undo.nvim'
    }
  }

  use {'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }

  -- Status line
  use {
    'nvim-lualine/lualine.nvim',
    requires = {
      'kyazdani42/nvim-web-devicons',
      'arkav/lualine-lsp-progress',
      opt = true
    }
  }

  -- Which key
  use {
    'folke/which-key.nvim',
    config = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
      require('which-key').setup()
      end
  }


  -- Theme
  use 'EdenEast/nightfox.nvim'
  use 'lukas-reineke/indent-blankline.nvim'
  use 'xiyaowong/nvim-transparent'

  -- Treesitter
  use { 'nvim-treesitter/nvim-treesitter',
        run = function()
            local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
            ts_update()
        end,
      }

  -- Git plugins
  use 'lewis6991/gitsigns.nvim'

  -- TODO: trying copilot-cmp instead
  -- Copilot
  -- :Copilot setup to authenticate with github
  -- :Copilot enable to turn on
  -- use 'github/copilot.vim'

  -- Tmux/vim navigation
  use 'christoomey/vim-tmux-navigator'

  -- Vim Util plugins
  use 'gioele/vim-autoswap'

  -- Automatically set up configuration after cloning packer.nvim
  if PACKER_BOOTSTRAP then
    require('packer').sync()
  end
end)
