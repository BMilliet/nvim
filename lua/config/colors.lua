function ColorMyPencils(color)
    color = color or "catppuccin-mocha"
    vim.cmd.colorscheme(color)

    vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
    vim.api.nvim_set_hl(0, "Visual", { bg = "#f9e2af", fg = "#1e1e2e" })
    vim.api.nvim_set_hl(0, "VisualNOS", { bg = "#f9e2af", fg = "#1e1e2e" })
end

ColorMyPencils()
