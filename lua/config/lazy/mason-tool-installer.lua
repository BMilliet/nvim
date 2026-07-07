return {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = {
        "mason-org/mason.nvim",
    },
    opts = {
        ensure_installed = {
            "prettierd",
            "prettier",
        },
        auto_update = false,
        run_on_start = true,
        start_delay = 3000,
    },
}
