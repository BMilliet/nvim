return {
    "mason-org/mason-lspconfig.nvim",
    opts = {
        ensure_installed = { "lua_ls", "yamlls", "gopls", "jsonls", "bashls" },
    },
    config = function(_, opts)
        require("mason-lspconfig").setup(opts)

        -- sourcekit-lsp is provided by the Swift/Xcode toolchain, not Mason.
        vim.lsp.enable("swift")
    end,
    dependencies = {
        { "mason-org/mason.nvim", opts = {} },
        "neovim/nvim-lspconfig",
    },
}
