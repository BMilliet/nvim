local M = {}

local ns = vim.api.nvim_create_namespace("config_git_scrollbar")
local augroup = vim.api.nvim_create_augroup("config_git_scrollbar", { clear = true })

local enabled = true
local autocmds_created = false
local attached_buffers = {}
local floats = {}

local chars = {
    add = "+",
    change = "~",
    delete = "-",
    cursor = ">",
}

local highlights = {
    add = "GitSignsAdd",
    change = "GitSignsChange",
    delete = "GitSignsDelete",
    cursor = "CursorLineNr",
}

local priorities = {
    add = 1,
    change = 2,
    delete = 3,
}

local function marker_text(kind, line)
    return ("%d%s"):format(line, chars[kind])
end

local function has_ui()
    return #vim.api.nvim_list_uis() > 0
end

local function is_normal_window(win)
    return vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_config(win).relative == ""
end

local function close_float(win)
    local state = floats[win]
    if not state then
        return
    end

    if state.win and vim.api.nvim_win_is_valid(state.win) then
        pcall(vim.api.nvim_win_close, state.win, true)
    end

    if state.buf and vim.api.nvim_buf_is_valid(state.buf) then
        pcall(vim.api.nvim_buf_delete, state.buf, { force = true })
    end

    floats[win] = nil
end

local function cleanup()
    for win, state in pairs(floats) do
        if not is_normal_window(win) or not state.win or not vim.api.nvim_win_is_valid(state.win) then
            close_float(win)
        end
    end
end

local function scale_line(line, line_count, height)
    if height <= 1 or line_count <= 1 then
        return 1
    end

    local row = math.floor(((line - 1) / (line_count - 1)) * (height - 1)) + 1
    return math.max(1, math.min(height, row))
end

local function hunk_range(hunk, line_count)
    local start = hunk.added and hunk.added.start or 1
    local added_count = hunk.added and hunk.added.count or 0
    local removed_count = hunk.removed and hunk.removed.count or 0
    local size = math.max(added_count, removed_count, 1)
    local finish = start + size - 1

    return math.max(1, math.min(line_count, start)), math.max(1, math.min(line_count, finish))
end

local function build_markers(bufnr, height)
    local ok, gitsigns = pcall(require, "gitsigns")
    if not ok or type(gitsigns.get_hunks) ~= "function" then
        return nil, nil
    end

    local hunks = gitsigns.get_hunks(bufnr)
    if not hunks or vim.tbl_isempty(hunks) then
        return nil, nil
    end

    local line_count = math.max(vim.api.nvim_buf_line_count(bufnr), 1)
    local markers = {}
    local marker_width = 1

    for _, hunk in ipairs(hunks) do
        local kind = hunk.type
        if chars[kind] then
            local first, last = hunk_range(hunk, line_count)
            local first_row = scale_line(first, line_count, height)
            local last_row = scale_line(last, line_count, height)
            local text = marker_text(kind, first)
            marker_width = math.max(marker_width, #text)

            for row = first_row, last_row do
                local existing = markers[row]
                if not existing or priorities[kind] > priorities[existing.kind] then
                    markers[row] = {
                        kind = kind,
                        text = text,
                    }
                end
            end
        end
    end

    return next(markers) and markers or nil, marker_width
end

local function ensure_float(win, height, bar_width)
    local state = floats[win]
    local width = vim.api.nvim_win_get_width(win)

    if
        state
        and state.win
        and vim.api.nvim_win_is_valid(state.win)
        and state.buf
        and vim.api.nvim_buf_is_valid(state.buf)
    then
        if vim.api.nvim_win_get_height(state.win) ~= height then
            vim.api.nvim_win_set_height(state.win, height)
        end
        if state.width ~= width or state.bar_width ~= bar_width then
            vim.api.nvim_win_set_config(state.win, {
                relative = "win",
                win = win,
                anchor = "NE",
                row = 0,
                col = width,
                width = bar_width,
                height = height,
            })
            state.width = width
            state.bar_width = bar_width
        end
        return state
    end

    local buf = vim.api.nvim_create_buf(false, true)
    vim.bo[buf].bufhidden = "wipe"
    vim.bo[buf].buftype = "nofile"
    vim.bo[buf].swapfile = false

    local float_win = vim.api.nvim_open_win(buf, false, {
        relative = "win",
        win = win,
        anchor = "NE",
        row = 0,
        col = width,
        width = bar_width,
        height = height,
        focusable = false,
        noautocmd = true,
        style = "minimal",
        zindex = 45,
    })

    vim.wo[float_win].winhighlight = "Normal:Normal"
    vim.wo[float_win].wrap = false

    state = { buf = buf, win = float_win, width = width, bar_width = bar_width }
    floats[win] = state
    return state
end

local function render_window(win)
    if not enabled or not has_ui() or not is_normal_window(win) then
        close_float(win)
        return
    end

    local bufnr = vim.api.nvim_win_get_buf(win)
    if not attached_buffers[bufnr] then
        close_float(win)
        return
    end

    local height = vim.api.nvim_win_get_height(win)
    local markers, marker_width = build_markers(bufnr, height)
    if not markers then
        close_float(win)
        return
    end

    local bar_width = marker_width + 1
    local state = ensure_float(win, height, bar_width)
    local line_count = math.max(vim.api.nvim_buf_line_count(bufnr), 1)
    local cursor_line = vim.api.nvim_win_get_cursor(win)[1]
    local cursor_row = scale_line(cursor_line, line_count, height)
    local lines = {}
    for row = 1, height do
        local marker = markers[row]
        local git_text = marker and marker.text or ""
        local cursor_char = row == cursor_row and chars.cursor or " "
        lines[row] = git_text .. string.rep(" ", marker_width - #git_text) .. cursor_char
    end

    vim.bo[state.buf].modifiable = true
    vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, lines)
    vim.api.nvim_buf_clear_namespace(state.buf, ns, 0, -1)

    for row, marker in pairs(markers) do
        vim.api.nvim_buf_add_highlight(state.buf, ns, highlights[marker.kind], row - 1, 0, #marker.text)
    end
    vim.api.nvim_buf_add_highlight(state.buf, ns, highlights.cursor, cursor_row - 1, marker_width, marker_width + 1)

    vim.bo[state.buf].modifiable = false
end

function M.render(bufnr)
    cleanup()

    for _, win in ipairs(vim.api.nvim_list_wins()) do
        if is_normal_window(win) and (not bufnr or vim.api.nvim_win_get_buf(win) == bufnr) then
            render_window(win)
        end
    end
end

local function schedule_render(bufnr)
    vim.schedule(function()
        if bufnr and not vim.api.nvim_buf_is_valid(bufnr) then
            return
        end
        M.render(bufnr)
    end)
end

local function create_autocmds()
    if autocmds_created then
        return
    end

    autocmds_created = true

    vim.api.nvim_create_autocmd("User", {
        group = augroup,
        pattern = "GitSignsUpdate",
        callback = function(args)
            schedule_render(args.data and args.data.buffer or nil)
        end,
    })

    vim.api.nvim_create_autocmd({
        "BufEnter",
        "CursorMoved",
        "CursorMovedI",
        "WinEnter",
        "WinScrolled",
        "VimResized",
    }, {
        group = augroup,
        callback = function()
            schedule_render()
        end,
    })

    vim.api.nvim_create_autocmd({ "WinClosed", "BufWipeout" }, {
        group = augroup,
        callback = function()
            schedule_render()
        end,
    })

    vim.api.nvim_create_user_command("GitScrollbarToggle", function()
        enabled = not enabled
        if not enabled then
            for win in pairs(floats) do
                close_float(win)
            end
        else
            schedule_render()
        end
        vim.notify("Git scrollbar " .. (enabled and "enabled" or "disabled"))
    end, {})
end

function M.attach(bufnr)
    attached_buffers[bufnr] = true
    create_autocmds()
    schedule_render(bufnr)
end

return M
