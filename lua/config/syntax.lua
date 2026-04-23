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

-- Auto format on save
vim.api.nvim_create_autocmd("BufWritePre", {
    group = vim.api.nvim_create_augroup("config_format_on_save", { clear = true }),
    callback = function(args)
        if format_on_save_disabled_filetypes[vim.bo[args.buf].filetype] then
            return
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
