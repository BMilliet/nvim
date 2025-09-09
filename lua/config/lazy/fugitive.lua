-- Plugin: vim-fugitive (Git integration for Vim/Neovim)
return {
    "tpope/vim-fugitive",
    event = "VeryLazy",     -- load on demand for performance
    config = function()
        -- Optional: custom keymaps for fugitive
        vim.keymap.set('n', '<leader>gs', ':Git<CR>', { desc = 'Fugitive: Git status' })
        vim.keymap.set('n', '<leader>gv', ':Gdiffsplit<CR>', { desc = 'Fugitive: Git diff split' })
        vim.keymap.set('n', '<leader>gb', ':Git blame<CR>', { desc = 'Fugitive: Git blame' })
        vim.keymap.set('n', '<leader>gc', ':Git commit<CR>', { desc = 'Fugitive: Git commit' })
    end,
}
