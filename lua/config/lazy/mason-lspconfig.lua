local function capabilities()
    local client_capabilities = vim.lsp.protocol.make_client_capabilities()
    local ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")

    if ok then
        return cmp_nvim_lsp.default_capabilities(client_capabilities)
    end

    return client_capabilities
end

local function configure_lsp()
    vim.lsp.config("*", {
        capabilities = capabilities(),
    })

    vim.lsp.config("vtsls", {
        settings = {
            vtsls = {
                autoUseWorkspaceTsdk = true,
            },
            typescript = {
                preferences = {
                    includePackageJsonAutoImports = "auto",
                    importModuleSpecifier = "non-relative",
                },
                inlayHints = {
                    includeInlayEnumMemberValueHints = true,
                    includeInlayFunctionLikeReturnTypeHints = true,
                    includeInlayFunctionParameterTypeHints = true,
                    includeInlayParameterNameHints = "all",
                    includeInlayParameterNameHintsWhenArgumentMatchesName = true,
                    includeInlayPropertyDeclarationTypeHints = true,
                    includeInlayVariableTypeHints = false,
                    includeInlayVariableTypeHintsWhenTypeMatchesName = false,
                },
            },
            javascript = {
                preferences = {
                    includePackageJsonAutoImports = "auto",
                    importModuleSpecifier = "non-relative",
                },
                inlayHints = {
                    includeInlayEnumMemberValueHints = true,
                    includeInlayFunctionLikeReturnTypeHints = true,
                    includeInlayFunctionParameterTypeHints = true,
                    includeInlayParameterNameHints = "all",
                    includeInlayParameterNameHintsWhenArgumentMatchesName = true,
                    includeInlayPropertyDeclarationTypeHints = true,
                    includeInlayVariableTypeHints = false,
                    includeInlayVariableTypeHintsWhenTypeMatchesName = false,
                },
            },
        },
    })

    local eslint_on_attach = vim.lsp.config.eslint.on_attach
    vim.lsp.config("eslint", {
        on_attach = function(client, bufnr)
            if eslint_on_attach then
                eslint_on_attach(client, bufnr)
            end

            client.server_capabilities.documentFormattingProvider = false
        end,
        settings = {
            codeActionOnSave = {
                enable = false,
                mode = "all",
            },
            format = false,
            workingDirectory = {
                mode = "auto",
            },
        },
    })

    vim.lsp.config("cssls", {
        settings = {
            css = {
                lint = {
                    unknownAtRules = "ignore",
                },
            },
            less = {
                lint = {
                    unknownAtRules = "ignore",
                },
            },
            scss = {
                lint = {
                    unknownAtRules = "ignore",
                },
            },
        },
    })

    vim.lsp.config("tailwindcss", {
        settings = {
            tailwindCSS = {
                classAttributes = { "class", "className", "ngClass", "class:list" },
                includeLanguages = {
                    javascript = "javascript",
                    javascriptreact = "javascript",
                    typescript = "javascript",
                    typescriptreact = "javascript",
                },
            },
        },
    })
end

return {
    "mason-org/mason-lspconfig.nvim",
    opts = {
        ensure_installed = {
            "lua_ls",
            "yamlls",
            "gopls",
            "jsonls",
            "bashls",
            "vtsls",
            "eslint",
            "tailwindcss",
            "cssls",
            "html",
            "emmet_language_server",
        },
    },
    config = function(_, opts)
        configure_lsp()
        require("mason-lspconfig").setup(opts)

        -- sourcekit-lsp is provided by the Swift/Xcode toolchain, not Mason.
        vim.lsp.enable("swift")
    end,
    dependencies = {
        { "mason-org/mason.nvim", opts = {} },
        "neovim/nvim-lspconfig",
        "hrsh7th/cmp-nvim-lsp",
    },
}
