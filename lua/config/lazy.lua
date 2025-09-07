-- lua/config/lazy.lua
-- Basic configuration for lazy.nvim plugin manager

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

require("lazy").setup({
        { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } },

        {
                "mason-org/mason-lspconfig.nvim",
                opts = {
                        ensure_installed = { "lua_ls", "yamlls", "gopls", "jsonls" },
                },
                dependencies = {
                        { "mason-org/mason.nvim", opts = {} },
                        "neovim/nvim-lspconfig",
                },
        },

        {
                -- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
                -- used for completion, annotations and signatures of Neovim apis
                'folke/lazydev.nvim',
                ft = 'lua',
                opts = {
                        library = {
                                -- Load luvit types when the `vim.uv` word is found
                                { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
                        },
                },
        },

        { 'j-hui/fidget.nvim',             opts = {} },

        {
                'stevearc/oil.nvim',
                ---@module 'oil'
                ---@type oil.SetupOpts
                opts = {},
                -- Optional dependencies
                -- dependencies = { { "echasnovski/mini.icons", opts = {} } },
                -- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if you prefer nvim-web-devicons
                -- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
                lazy = false,
        },

        { "nvim-treesitter/nvim-treesitter", branch = 'master', lazy = false, build = ":TSUpdate" },


        {
                "rose-pine/neovim",
                name = "rose-pine",
                config = function()
                        vim.cmd("colorscheme rose-pine")
                end
        },
})
