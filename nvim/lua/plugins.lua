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

  -- An implementation of the Popup API from vim in Neovim
  use 'nvim-lua/popup.nvim'

  -- Useful lua functions used ny lots of plugins
  use 'nvim-lua/plenary.nvim'
  use 'b0o/mapx.nvim'

  -- File tree
  use {
    'kyazdani42/nvim-tree.lua',
    requires = {
      'kyazdani42/nvim-web-devicons',
    },
    config = function() require'nvim-tree'.setup {} end
  }

  -- Completion
  use 'L3MON4D3/LuaSnip' 
  use 'saadparwaiz1/cmp_luasnip'
  use 'neovim/nvim-lspconfig'
  use 'hrsh7th/cmp-nvim-lsp'
  use 'hrsh7th/cmp-buffer'
  use 'hrsh7th/cmp-path'
  use 'hrsh7th/cmp-cmdline'
  use 'hrsh7th/nvim-cmp'

  -- Status line
  use { 'nvim-lualine/lualine.nvim', requires = { 'kyazdani42/nvim-web-devicons', opt = true }}

  -- Theme
  use 'EdenEast/nightfox.nvim'

  -- Treesitter
  use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }


  -- Automatically set up configuration after cloning packer.nvim
  if PACKER_BOOTSTRAP then
    require('packer').sync()
  end
end)
