local parsers = require("config.treesitter_parsers")

return {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate " .. table.concat(parsers, " "),
}
