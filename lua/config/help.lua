-- 👉 Help --
vim.api.nvim_create_user_command('Help', function()
    local sections = {
        {
            title = '🪟 window navigation',
            maps = {
                { '<leader><left>',  'Move focus to the left window' },
                { '<leader><right>', 'Move focus to the right window' },
                { '<leader><down>',  'Move focus to the lower window' },
                { '<leader><up>',    'Move focus to the upper window' },
                { '<leader>vp',      'Split window vertically' },
            },
        },
        {
            title = '⭐️ custom commands',
            maps = {
                { '<leader>vp', 'Split window vertically' },
                { '<leader>[',  'Buffer: Previous' },
                { '<leader>]',  'Buffer: Next' },
                { '<leader>p',  'Buffer: Alternate' },
                { '.',          '5k' },
                { ',',          '5j' },
            },
        },
        {
            title = '🔭 Telescope shortcuts',
            maps = {
                { '<leader>sf', 'Telescope: Search Files' },
                { '<leader>sg', 'Telescope: Search Grep' },
            },
        },
        {
            title = '🔎 Find and Replace',
            maps = {
                { '<leader>fr', 'Find and Replace' },
            },
        },
        {
            title = '☁️ buffer navigation',
            maps = {
                { '<leader>bn', 'Buffer: Next' },
                { '<leader>bp', 'Buffer: Previous' },
                { '<leader>bd', 'Buffer: Delete' },
                { '<leader>bl', 'Telescope: List Buffers' },
            },
        },
        {
            title = '🛢️ Oil shortcuts',
            maps = {
                { '-', 'Open parent directory (Oil)' },
            },
        },
        {
            title = '⚡️ LSP commands',
            maps = {
                { '<leader>rn', 'LSP: Rename symbol under cursor' },
                { '<leader>h',  'LSP: Hover documentation' },
                { '<leader>gd', 'LSP: Go to Definition' },
                { '<leader>gu', 'LSP: Show Usages (References)' },
            },
        },
    }
    print('Remaps definidos em remap.lua:')
    for _, section in ipairs(sections) do
        print(string.format('-- %s --', section.title))
        for _, map in ipairs(section.maps) do
            print(string.format('  %-12s → %s', map[1], map[2]))
        end
    end
end, { desc = 'Show help for remap.lua' })
