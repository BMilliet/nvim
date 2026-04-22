local parsers = require("config.treesitter_parsers")

local function is_large_file(buf)
    local name = vim.api.nvim_buf_get_name(buf)
    if name == "" then
        return false
    end

    local max_filesize = 100 * 1024 -- 100 KB
    local uv = vim.uv or vim.loop
    local ok, stats = pcall(uv.fs_stat, name)
    return ok and stats and stats.size > max_filesize
end

local ok, treesitter = pcall(require, "nvim-treesitter")
if ok and type(treesitter.setup) == "function" and type(treesitter.install) == "function" then
    treesitter.setup({
        install_dir = vim.fn.stdpath("data") .. "/site",
    })

    treesitter.install(parsers)

    vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("config_treesitter", { clear = true }),
        callback = function(args)
            if is_large_file(args.buf) then
                return
            end

            pcall(vim.treesitter.start, args.buf)
        end,
    })

    return
end

-- Temporary compatibility path for the old master branch while Lazy updates
-- the plugin to main.
local ok_configs, configs = pcall(require, "nvim-treesitter.configs")
if ok_configs then
    configs.setup({
        ensure_installed = parsers,
        sync_install = false,
        auto_install = false,
        ignore_install = { "javascript" },
        highlight = {
            enable = true,
            disable = function(lang, buf)
                if lang == "markdown" or lang == "markdown_inline" then
                    return true
                end

                return is_large_file(buf)
            end,
            additional_vim_regex_highlighting = false,
        },
    })
end
