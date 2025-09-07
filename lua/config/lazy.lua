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

local plugins = {
        require("config.lazy.telescope"),
        require("config.lazy.mason-lspconfig"),
        require("config.lazy.nvim-cmp"),
        require("config.lazy.lazydev"),
        require("config.lazy.fidget"),
        require("config.lazy.oil"),
        require("config.lazy.treesitter"),
        require("config.lazy.rose-pine"),
}

require("lazy").setup(plugins)
