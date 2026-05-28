vim.g.mapleader = " "

vim.opt.nu = true
vim.opt.relativenumber = true


vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.autoindent = true
vim.opt.smartindent = false

vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false
local undo_dir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undodir = undo_dir
vim.opt.undofile = true

local function notify_removed_undo_file(path)
    local name = vim.fs.basename(path)
    local original_file = vim.fn.fnamemodify(name:gsub("%%", "/"), ":~")
    local ok, fidget = pcall(require, "fidget")

    if ok then
        fidget.notify(original_file, vim.log.levels.INFO, {
            annote = "Removed undo file",
            group = "undo-cleanup",
            key = path,
        })
        return
    end

    vim.notify("Removed undo file: " .. original_file, vim.log.levels.INFO)
end

local function cleanup_old_undo_files()
    local handle = vim.uv.fs_scandir(undo_dir)

    if not handle then
        return
    end

    local cutoff = os.time() - (30 * 24 * 60 * 60)

    while true do
        local name, filetype = vim.uv.fs_scandir_next(handle)

        if not name then
            break
        end

        if filetype == "file" then
            local path = vim.fs.joinpath(undo_dir, name)
            local stat = vim.uv.fs_stat(path)

            if stat and stat.mtime.sec < cutoff then
                local removed = vim.uv.fs_unlink(path)

                if removed then
                    notify_removed_undo_file(path)
                end
            end
        end
    end
end

vim.api.nvim_create_autocmd("VimEnter", {
    group = vim.api.nvim_create_augroup("config_cleanup_undo_files", { clear = true }),
    callback = cleanup_old_undo_files,
})

vim.opt.hlsearch = true
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 10

vim.opt.updatetime = 50

vim.opt.colorcolumn = "100"

vim.opt.clipboard = "unnamedplus"

-- Spell checking
-- vim.opt.spell = true
-- vim.opt.spelllang = "en_us"

-- 🌙 Lua --
vim.api.nvim_create_autocmd("FileType", {
    pattern = "lua",
    callback = function()
        vim.opt_local.tabstop = 4
        vim.opt_local.softtabstop = 4
        vim.opt_local.shiftwidth = 4
        vim.opt_local.expandtab = true
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = "yaml",
    callback = function()
        vim.opt_local.tabstop = 2
        vim.opt_local.softtabstop = 2
        vim.opt_local.shiftwidth = 2
        vim.opt_local.expandtab = true
        vim.opt_local.smartindent = false
    end,
})
