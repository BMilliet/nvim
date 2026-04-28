-- 🌱 sets --
vim.g.mapleader = " "

-- 🪟 window navigation --
vim.keymap.set('n', '<leader><left>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<leader><right>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<leader><down>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<leader><up>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })
vim.keymap.set('n', '<leader>vp', ':vsplit<CR>', { desc = 'Split window vertically' })

-- ⭐️ custom commands --
vim.keymap.set('n', '<leader>vp', ':vsplit<CR>', { desc = 'Split window vertically' })
vim.keymap.set('n', '<leader>gs', ':Status<CR>', { desc = 'Git Status: Open changed file list' })

vim.keymap.set('n', '<leader>m', function()
    local filename = vim.fn.expand('%')
    vim.fn.setreg('+', filename)
    vim.fn.setreg('"', filename)
    print('Copiado: ' .. filename)
end, { desc = 'Copy current filename to clipboard' })
-- using harpoon
-- vim.api.nvim_set_keymap('n', '<leader>[', ':bprevious<CR>', { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('n', '<leader>]', ':bnext<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>p', ':b#<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '.', '5k<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', ',', '5j<CR>', { noremap = true, silent = true })
vim.keymap.set('v', '<', '<gv', { desc = 'Move block to L' })
vim.keymap.set('v', '>', '>gv', { desc = 'Move block to R' })

-- 🔭 Telescope shortcuts --
vim.keymap.set('n', '<leader>sf', require('telescope.builtin').find_files, { desc = 'Telescope: Search Files' })
vim.keymap.set('n', '<leader>sg', require('telescope.builtin').live_grep, { desc = 'Telescope: Search Grep' })

-- 🔎 Find and Replace --
vim.keymap.set('n', '<leader>fr', ':%s//g<Left><Left>', { desc = 'Find and Replace' })

-- ☁️ buffer navigation --
vim.keymap.set('n', '<leader>bn', ':bnext<CR>', { desc = 'Buffer: Next' })
vim.keymap.set('n', '<leader>bp', ':bprevious<CR>', { desc = 'Buffer: Previous' })
vim.keymap.set('n', '<leader>bd', ':bdelete<CR>', { desc = 'Buffer: Delete' })
vim.keymap.set('n', '<leader><leader>', require('telescope.builtin').buffers, { desc = 'Telescope: List Buffers' })

-- 🛢️ Oil shortcuts --
vim.keymap.set('n', '-', '<CMD>Oil<CR>', { desc = 'Open parent directory' })


-- ⚡️ LSP commands --
vim.keymap.set('n', '<leader>rn', function()
    vim.lsp.buf.rename()
end, { desc = 'LSP: Rename symbol under cursor' })

vim.keymap.set('n', '<leader>h', function()
    vim.lsp.buf.hover()
end, { desc = 'LSP: Hover documentation' })

vim.keymap.set('n', '<leader>gd', function()
    vim.lsp.buf.definition()
end, { desc = 'LSP: Go to Definition' })

vim.keymap.set('n', '<leader>gu', function()
    vim.lsp.buf.references()
end, { desc = 'LSP: Show Usages (References)' })
