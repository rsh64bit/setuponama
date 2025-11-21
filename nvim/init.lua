-- ~/.config/nvim/init.lua
vim.cmd [[packadd packer.nvim]]

require("packer").startup(function(use)
  use "wbthomason/packer.nvim"
  use "neovim/nvim-lspconfig"
end)

-- Setup LSP
local lspconfig = require("lspconfig")
lspconfig.rust_analyzer.setup({})

-----------------------------------------------------------
-- Basic Settings
-----------------------------------------------------------
vim.g.mapleader = " "
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.termguicolors = true
vim.opt.cursorline = true

-----------------------------------------------------------
-- Install Lazy.nvim if not exists
-----------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-----------------------------------------------------------
-- Plugins
-----------------------------------------------------------
require("lazy").setup({

  -----------------------
  -- UI
  -----------------------
  { "nvim-tree/nvim-web-devicons" },
  -- File tree
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({
        view = {
          width = 30,
          side = "left",
        },
        renderer = {
          group_empty = true,
        },
        filters = {
          dotfiles = false,
        },
      })

      -- Keymap to toggle tree
      vim.keymap.set("n", "<C-n>", ":NvimTreeToggle<CR>", { silent = true })
    end,
  },
  { "nvim-tree/nvim-tree.lua" },
  {
    "nvim-lualine/lualine.nvim",
    config = function()
      require("lualine").setup()
    end
  },

  -----------------------
  -- Treesitter
  -----------------------
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "lua", "python", "c", "cpp", "bash", "json", "yaml", "vim" },
        highlight = { enable = true },
      })
    end
  },

  -----------------------
  -- LSP + Autocomplete
  -----------------------
  { "williamboman/mason.nvim", build = ":MasonUpdate" },
  { "williamboman/mason-lspconfig.nvim" },
  { "neovim/nvim-lspconfig" },
  { "hrsh7th/nvim-cmp" },
  { "hrsh7th/cmp-nvim-lsp" },
  { "hrsh7th/cmp-buffer" },
  { "hrsh7th/cmp-path" },
  { "L3MON4D3/LuaSnip" },
  { "saadparwaiz1/cmp_luasnip" },

  -----------------------
  -- Telescope
  -----------------------
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" }
  },

  -----------------------
  -- Utilities
  -----------------------
  { "lewis6991/gitsigns.nvim" },
  { "numToStr/Comment.nvim" },

  { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
})

-----------------------------------------------------------
-- Plugin Configurations
-----------------------------------------------------------

-- Mason + LSP
require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = { "lua_ls", "bashls", "pyright", "clangd", "jsonls", "yamlls" }
})

-- Setup LSP config
local lspconfig = require("lspconfig")
local cmp = require("cmp")
local luasnip = require("luasnip")

-- Autocomplete
cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
    ["<Tab>"] = cmp.mapping.select_next_item(),
    ["<S-Tab>"] = cmp.mapping.select_prev_item(),
  }),
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "luasnip" },
  }, {
    { name = "buffer" },
    { name = "path" },
  }),
})

-- Attach LSP to servers
local capabilities = require("cmp_nvim_lsp").default_capabilities()
local servers = { "lua_ls", "pyright", "clangd", "bashls", "jsonls", "yamlls" }

for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup({ capabilities = capabilities })
end

-- Lua LSP for Neovim
lspconfig.lua_ls.setup({
  settings = {
    Lua = {
      diagnostics = { globals = { "vim" } }
    }
  }
})

-----------------------------------------------------------
-- Telescope Keymaps
-----------------------------------------------------------
vim.keymap.set("n", "<leader>ff", ":Telescope find_files<CR>")
vim.keymap.set("n", "<leader>fg", ":Telescope live_grep<CR>")

-----------------------------------------------------------
-- NvimTree
-----------------------------------------------------------
require("nvim-tree").setup()
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>")

-----------------------------------------------------------
-- Comment.nvim
-----------------------------------------------------------
require("Comment").setup()

-----------------------------------------------------------
-- Gitsigns
-----------------------------------------------------------
require("gitsigns").setup()

require("telescope").setup({
  defaults = {
    layout_strategy = "vertical",
    layout_config = { width = 0.4 },  -- right side narrow
  },
})
