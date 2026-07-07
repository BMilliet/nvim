return {
    "stevearc/conform.nvim",
    cmd = { "ConformInfo" },
    event = { "BufWritePre" },
    opts = {
        notify_on_error = false,
        formatters_by_ft = {
            javascript = { "prettierd", "prettier", "biome", stop_after_first = true },
            javascriptreact = { "prettierd", "prettier", "biome", stop_after_first = true },
            typescript = { "prettierd", "prettier", "biome", stop_after_first = true },
            typescriptreact = { "prettierd", "prettier", "biome", stop_after_first = true },
            json = { "prettierd", "prettier", "biome", stop_after_first = true },
            jsonc = { "prettierd", "prettier", "biome", stop_after_first = true },
            css = { "prettierd", "prettier", "biome", stop_after_first = true },
            scss = { "prettierd", "prettier", "biome", stop_after_first = true },
            sass = { "prettierd", "prettier", "biome", stop_after_first = true },
            html = { "prettierd", "prettier", "biome", stop_after_first = true },
            markdown = { "prettierd", "prettier", stop_after_first = true },
        },
    },
}
