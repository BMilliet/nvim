return {
    {
        "neovim/nvim-lspconfig",
        config = function()
            vim.lsp.config.sourcekit = {
                cmd = { "sourcekit-lsp" },
                filetypes = { "swift", "objective-c" },
                root_markers = { "Package.swift" },
            }

            vim.lsp.enable("sourcekit")
        end,
    },
}
