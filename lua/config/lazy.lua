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
    --- Lazy
    require("config.lazy.telescope"),
    require("config.lazy.mason-lspconfig"),
    require("config.lazy.nvim-cmp"),
    require("config.lazy.lazydev"),
    require("config.lazy.fidget"),
    require("config.lazy.oil"),
    require("config.lazy.treesitter"),
    require("config.lazy.color-scheme"),
    require("config.lazy.fugitive"),
    require("config.lazy.gitsigns"),
    require("config.lazy.indent-lines"),
    require("config.lazy.harpoon"),
    --- LSP
    require("config.lsp.swift"),
}

require("lazy").setup(plugins)
