return {
    'j-hui/fidget.nvim',
    opts = function()
        local notification = require("fidget.notification")

        return {
            notification = {
                configs = {
                    default = notification.default_config,
                    ["undo-cleanup"] = vim.tbl_extend("force", notification.default_config, {
                        name = "Undo cleanup",
                        icon = "",
                        ttl = 4,
                        skip_history = true,
                    }),
                },
            },
        }
    end,
}
