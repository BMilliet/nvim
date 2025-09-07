return {
    "hrsh7th/nvim-cmp",
    dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-cmdline",
    },
    config = function()
        local cmp = require('cmp')
        vim.o.completeopt = "menu,menuone,noselect"
        cmp.setup({
            snippet = {
                expand = function(args)
                    -- You can add luasnip or vsnip here if you use snippets
                end,
            },
            mapping = {
                ['<C-Space>'] = cmp.mapping.complete(),
                ['<CR>'] = cmp.mapping.confirm({ select = true }),
                ['<Down>'] = cmp.mapping.select_next_item(),
                ['<Up>'] = cmp.mapping.select_prev_item(),
            },
            sources = cmp.config.sources({
                { name = 'nvim_lsp' },
                { name = 'buffer' },
                { name = 'path' },
            })
        })
        -- Optional: cmdline completion
        cmp.setup.cmdline(':', {
            sources = {
                { name = 'path' },
                { name = 'cmdline' },
            }
        })
        cmp.setup.cmdline('/', {
            sources = {
                { name = 'buffer' }
            }
        })
    end,
}
