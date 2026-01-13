return {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
        local harpoon = require("harpoon")

        -- inicializa o harpoon
        harpoon:setup()

        local list = harpoon:list()

        -- 📌 Adicionar arquivo atual
        vim.keymap.set("n", "<leader>a", function()
            local file = vim.fn.expand("%:t") -- nome do arquivo
            list:add()
            vim.notify(
                "📌 Harpoon added: " .. file,
                vim.log.levels.INFO
            )
        end, { desc = "Harpoon: add file" })

        -- 🧹 remover arquivo atual
        vim.keymap.set("n", "<leader>r", function()
            local file = vim.fn.expand("%:t") -- nome do arquivo (ex: main.go)
            list:remove()
            vim.notify(
                "🧹 Harpoon removed: " .. file,
                vim.log.levels.INFO
            )
        end, { desc = "Harpoon: remove file" })


        -- 📂 Menu rápido
        vim.keymap.set("n", "<leader>l", function()
            harpoon.ui:toggle_quick_menu(list)
        end, { desc = "Harpoon: menu" })

        -- 🔢 Navegação direta
        vim.keymap.set("n", "<leader>1", function() list:select(1) end)
        vim.keymap.set("n", "<leader>2", function() list:select(2) end)
        vim.keymap.set("n", "<leader>3", function() list:select(3) end)
        vim.keymap.set("n", "<leader>4", function() list:select(4) end)

        -- ↔️ Navegação cíclica
        vim.keymap.set("n", "<leader>[", function() list:prev() end)
        vim.keymap.set("n", "<leader>]", function() list:next() end)
    end,
}
