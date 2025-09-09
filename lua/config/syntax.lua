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

-- Auto format on save
vim.api.nvim_create_autocmd("BufWritePre", {
    callback = function()
        vim.lsp.buf.format({ async = false })
    end,
})

vim.diagnostic.config({
    signs = false,  -- disables the left column signs
    underline = true, -- keeps underlines
    virtual_text = false,
    virtual_lines = { current_line = true },
})
