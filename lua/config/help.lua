-- Help
vim.api.nvim_create_user_command("Help", function()
    local sections = {
        {
            title = "Windows",
            icon = "🪟",
            items = {
                { "n", "<leader><left>", "Move focus to the left window" },
                { "n", "<leader><right>", "Move focus to the right window" },
                { "n", "<leader><down>", "Move focus to the lower window" },
                { "n", "<leader><up>", "Move focus to the upper window" },
                { "n", "<leader>vp", "Split window vertically" },
            },
        },
        {
            title = "Files and Search",
            icon = "🔭",
            items = {
                { "n", "<leader>sf", "Telescope: search files" },
                { "n", "<leader>sg", "Telescope: search text" },
                { "n", "<leader><leader>", "Telescope: list buffers" },
                { "n", "-", "Oil: open parent directory" },
                { "n", "<leader>m", "Copy current file path" },
            },
        },
        {
            title = "Editing",
            icon = "✍️",
            items = {
                { "n", "<leader>fr", "Find and replace in current file" },
                { "v", "<", "Reindent selection to the left" },
                { "v", ">", "Reindent selection to the right" },
            },
        },
        {
            title = "Buffers and Movement",
            icon = "☁️",
            items = {
                { "n", "<leader>bn", "Next buffer" },
                { "n", "<leader>bp", "Previous buffer" },
                { "n", "<leader>bd", "Delete buffer" },
                { "n", "<leader>p", "Switch to alternate buffer" },
                { "n", ".", "Move 5 lines up" },
                { "n", ",", "Move 5 lines down" },
            },
        },
        {
            title = "Harpoon",
            icon = "📌",
            items = {
                { "n", "<leader>a", "Add current file" },
                { "n", "<leader>r", "Remove current file" },
                { "n", "<leader>hc", "Clear project list" },
                { "n", "<leader>l", "Open quick menu" },
                { "n", "<leader>1..4", "Open item 1 through 4" },
                { "n", "<leader>[", "Previous item" },
                { "n", "<leader>]", "Next item" },
            },
        },
        {
            title = "LSP",
            icon = "⚡",
            items = {
                { "n", "<leader>rn", "Rename symbol under cursor" },
                { "n", "<leader>h", "Show hover documentation" },
                { "n", "<leader>gd", "Go to definition" },
                { "n", "<leader>gu", "Show references" },
            },
        },
        {
            title = "Git Status",
            icon = "🌱",
            items = {
                { ":", "Blame", "Open blame for current file" },
                { ":", "Status", "Open changed file list" },
                { ":", "GitStatusRefresh", "Refresh git signs and scrollbar" },
                { ":", "GitStatusToggle", "Toggle git signs and scrollbar" },
            },
        },
        {
            title = "Lore",
            icon = "🧭",
            items = {
                { ":", "Lore", "Open interactive file history" },
                { ":", "Loreq", "Exit Lore mode" },
                { ":", "Snapshot DD-MM-YYYY", "Open file as it was on a date" },
                { ":", "Snapshotq", "Exit Snapshot mode" },
                { "n", "<Right>", "Lore: older commit" },
                { "n", "<Left>", "Lore: newer commit" },
                { "n", "q", "Close Lore/Snapshot" },
            },
        },
    }

    local namespace = vim.api.nvim_create_namespace("config_help")
    local lines = {
        "Config Help",
        "Leader: <Space>    Close: q or <Esc>",
        "",
    }
    local highlights = {}

    local function add(line, group, start_col, end_col)
        local line_index = #lines
        table.insert(lines, line)

        if group then
            table.insert(highlights, {
                line = line_index,
                group = group,
                start_col = start_col or 0,
                end_col = end_col or -1,
            })
        end
    end

    local function add_item(mode, key, description)
        local line = string.format("  %-2s  %-22s  %s", mode, key, description)
        local mode_start = 2
        local mode_end = mode_start + #mode
        local key_start = 6
        local key_end = key_start + #key
        local desc_start = 30

        add(line)
        local line_index = #lines - 1

        table.insert(highlights, {
            line = line_index,
            group = "ConfigHelpMode",
            start_col = mode_start,
            end_col = mode_end,
        })
        table.insert(highlights, {
            line = line_index,
            group = "ConfigHelpKey",
            start_col = key_start,
            end_col = key_end,
        })
        table.insert(highlights, {
            line = line_index,
            group = "ConfigHelpDescription",
            start_col = desc_start,
            end_col = -1,
        })
    end

    for _, section in ipairs(sections) do
        add(section.icon .. " " .. section.title, "ConfigHelpSection")
        add("  M   Key/Command             Action", "ConfigHelpHeader")

        for _, item in ipairs(section.items) do
            add_item(item[1], item[2], item[3])
        end

        add("")
    end

    vim.api.nvim_set_hl(0, "ConfigHelpTitle", { link = "Title" })
    vim.api.nvim_set_hl(0, "ConfigHelpSubtitle", { link = "Comment" })
    vim.api.nvim_set_hl(0, "ConfigHelpSection", { link = "Function" })
    vim.api.nvim_set_hl(0, "ConfigHelpHeader", { link = "Identifier" })
    vim.api.nvim_set_hl(0, "ConfigHelpMode", { link = "Type" })
    vim.api.nvim_set_hl(0, "ConfigHelpKey", { link = "String" })
    vim.api.nvim_set_hl(0, "ConfigHelpDescription", { link = "Normal" })

    local buf = vim.api.nvim_create_buf(false, true)
    vim.bo[buf].bufhidden = "wipe"
    vim.bo[buf].filetype = "config-help"
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].modifiable = false

    vim.api.nvim_buf_add_highlight(buf, namespace, "ConfigHelpTitle", 0, 0, -1)
    vim.api.nvim_buf_add_highlight(buf, namespace, "ConfigHelpSubtitle", 1, 0, -1)

    for _, highlight in ipairs(highlights) do
        vim.api.nvim_buf_add_highlight(
            buf,
            namespace,
            highlight.group,
            highlight.line,
            highlight.start_col,
            highlight.end_col
        )
    end

    local width = math.min(78, math.max(20, vim.o.columns - 8))
    local height = math.min(#lines, math.max(1, vim.o.lines - 6))
    local row = math.max(0, math.floor((vim.o.lines - height) / 2) - 1)
    local col = math.max(0, math.floor((vim.o.columns - width) / 2))

    local win = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        width = width,
        height = height,
        row = row,
        col = col,
        style = "minimal",
        border = "rounded",
        title = " :Help ",
        title_pos = "center",
    })

    vim.wo[win].cursorline = true
    vim.wo[win].wrap = false

    local close = function()
        if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_close(win, true)
        end
    end

    vim.keymap.set("n", "q", close, { buffer = buf, nowait = true, silent = true })
    vim.keymap.set("n", "<Esc>", close, { buffer = buf, nowait = true, silent = true })
end, { desc = "Show custom keymaps and commands" })
