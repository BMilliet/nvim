-- Custom filetypes
vim.api.nvim_create_autocmd({ 'BufEnter' }, {
    desc = 'Set filetypes for ruby',
    pattern = { 'Podfile', '*.podspec', 'Fastfile', 'Dangerfile', 'Appfile', 'Scanfile' },
    command = 'set filetype=ruby',
})

vim.api.nvim_create_autocmd({ 'BufEnter' }, {
    desc = 'Set filetypes for groovy',
    pattern = { '*.dsl' },
    command = 'set filetype=groovy',
})

local format_on_save_disabled_filetypes = {
    yaml = true,
}

local conform_filetypes = {
    css = true,
    html = true,
    javascript = true,
    javascriptreact = true,
    json = true,
    jsonc = true,
    markdown = true,
    sass = true,
    scss = true,
    typescript = true,
    typescriptreact = true,
}

if vim.g.swift_format_on_save == nil then
    vim.g.swift_format_on_save = false
end

local function set_swift_format_on_save(enabled)
    vim.g.swift_format_on_save = enabled

    local state = enabled and "enabled" or "disabled"
    vim.notify("Swift format on save " .. state, vim.log.levels.INFO)
end

vim.api.nvim_create_user_command("SwiftFormat", function()
    set_swift_format_on_save(not vim.g.swift_format_on_save)
end, {
    nargs = 0,
    desc = "Toggle Swift format on save",
})

vim.keymap.set("c", "<CR>", function()
    if vim.fn.getcmdtype() ~= ":" then
        return "<CR>"
    end

    local cmdline = vim.fn.getcmdline()

    if cmdline == "swift-format=true" then
        set_swift_format_on_save(true)
        return "<C-U><CR>"
    end

    if cmdline == "swift-format=false" then
        set_swift_format_on_save(false)
        return "<C-U><CR>"
    end

    return "<CR>"
end, { expr = true, desc = "Handle Swift format toggle aliases" })

-- Auto format on save
vim.api.nvim_create_autocmd("BufWritePre", {
    group = vim.api.nvim_create_augroup("config_format_on_save", { clear = true }),
    callback = function(args)
        local filetype = vim.bo[args.buf].filetype

        if filetype == "swift" and not vim.g.swift_format_on_save then
            return
        end

        if format_on_save_disabled_filetypes[filetype] then
            return
        end

        if conform_filetypes[filetype] then
            local ok, conform = pcall(require, "conform")

            if ok then
                conform.format({ bufnr = args.buf, async = false, lsp_format = "fallback" })
                return
            end
        end

        vim.lsp.buf.format({ bufnr = args.buf, async = false })
    end,
})

vim.diagnostic.config({
    signs = false,  -- disables the left column signs
    underline = true, -- keeps underlines
    virtual_text = false,
    virtual_lines = { current_line = true },
})
