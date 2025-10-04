return {
    {
        "neovim/nvim-lspconfig",
        config = function()
            local lspconfig = require("lspconfig")

            -- Swift LSP
            lspconfig.sourcekit.setup({
                cmd = { "sourcekit-lsp" },
                filetypes = { "swift", "objective-c" },
                root_dir = lspconfig.util.root_pattern("Package.swift"),
            })
        end,
    },
}
