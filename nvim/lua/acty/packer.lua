-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
  -- Packer can manage itself
  use('wbthomason/packer.nvim')

  -- Colorscheme
  use('folke/tokyonight.nvim')
  use('morhetz/gruvbox')

  -- Telescope
  use('nvim-lua/plenary.nvim')
  use('nvim-telescope/telescope.nvim')

  -- Git
  use('TimUntersberger/neogit')

  -- LSP
  use('neovim/nvim-lspconfig')
  use('onsails/lspkind-nvim')
  use "hrsh7th/nvim-cmp"
  use('hrsh7th/cmp-nvim-lsp')
  use("simrat39/symbols-outline.nvim")
  use("L3MON4D3/LuaSnip")
  use("saadparwaiz1/cmp_luasnip")

  -- Train vim motions
  use("ThePrimeagen/vim-be-good")

end)
