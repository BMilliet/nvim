local M = {}

local ns = vim.api.nvim_create_namespace("config.lore")
local state = nil

local config = {
    history_limit = 80,
    author_width = 22,
}

local function notify(message, level)
    vim.notify("[Lore] " .. message, level or vim.log.levels.INFO)
end

local function starts_with(value, prefix)
    return value:sub(1, #prefix) == prefix
end

local function split_lines(value)
    if value == nil or value == "" then
        return {}
    end

    local lines = vim.split(value, "\n", { plain = true })
    if lines[#lines] == "" then
        table.remove(lines, #lines)
    end

    return lines
end

local function run(command)
    local result = vim.system(command, { text = true }):wait()
    return result.code or 0, result.stdout or "", result.stderr or ""
end

local function run_git(root, args)
    local command = { "git", "-C", root, "--no-pager" }
    vim.list_extend(command, args)
    return run(command)
end

local function find_repo_root(path)
    local dir = vim.fs.dirname(path)
    local code, stdout, stderr = run({ "git", "-C", dir, "rev-parse", "--show-toplevel" })
    if code ~= 0 then
        return nil, vim.trim(stderr)
    end

    return vim.fs.normalize(vim.trim(stdout)), nil
end

local function relative_path(root, path)
    local ok, relpath = pcall(vim.fs.relpath, root, path)
    if ok and relpath then
        return relpath
    end

    local prefix = vim.pesc(root .. "/")
    return path:gsub("^" .. prefix, "")
end

local function load_commits(root, relpath)
    local code, stdout, stderr = run_git(root, {
        "log",
        "--follow",
        "-n",
        tostring(config.history_limit),
        "--date=short",
        "--format=LORE%x00%H%x00%h%x00%an%x00%ad%x00%s",
        "--name-status",
        "--",
        relpath,
    })

    if code ~= 0 then
        return nil, vim.trim(stderr)
    end

    local commits = {}
    local current = nil

    local function push_current()
        if not current then
            return
        end

        current.path = current.path or relpath
        table.insert(commits, current)
        current = nil
    end

    for _, line in ipairs(split_lines(stdout)) do
        if starts_with(line, "LORE\0") then
            push_current()

            local parts = vim.split(line, "\0", { plain = true })
            current = {
                hash = parts[2],
                short = parts[3],
                author = parts[4],
                date = parts[5],
                subject = parts[6],
                path = relpath,
            }
        elseif current and line ~= "" then
            local fields = vim.split(line, "\t", { plain = true })
            local status = fields[1] or ""

            if starts_with(status, "R") or starts_with(status, "C") then
                current.previous_path = fields[2]
                current.path = fields[3] or fields[2] or relpath
            else
                current.path = fields[2] or fields[1] or relpath
            end
        end
    end

    push_current()
    return commits, nil
end

local function read_blob(root, commit)
    local code, stdout, stderr = run_git(root, { "show", commit.hash .. ":" .. commit.path })
    if code ~= 0 then
        return nil, vim.trim(stderr)
    end

    return split_lines(stdout), nil
end

local function get_snapshot(index)
    if state.snapshots[index] then
        return state.snapshots[index]
    end

    local snapshot
    if index == 0 then
        snapshot = {
            lines = vim.api.nvim_buf_get_lines(state.original_buf, 0, -1, false),
            label = "working tree",
            path = state.relpath,
            commit = nil,
        }
    else
        local commit = state.commits[index]
        if not commit then
            snapshot = {
                lines = {},
                label = "empty tree",
                path = state.relpath,
                commit = nil,
            }
        else
            local lines, err = read_blob(state.root, commit)
            snapshot = {
                lines = lines or {},
                error = err,
                label = commit.short,
                path = commit.path,
                commit = commit,
            }
        end
    end

    state.snapshots[index] = snapshot

    for cached_index, _ in pairs(state.snapshots) do
        if cached_index < state.index - 1 or cached_index > state.index + 1 then
            state.snapshots[cached_index] = nil
        end
    end

    return snapshot
end

local function temp_file(lines)
    local path = vim.fn.tempname()
    vim.fn.writefile(lines, path, "b")
    return path
end

local function build_diff(old_snapshot, new_snapshot)
    local old_path = temp_file(old_snapshot.lines)
    local new_path = temp_file(new_snapshot.lines)

    local code, stdout, stderr = run_git(state.root, {
        "diff",
        "--no-index",
        "--no-ext-diff",
        "--unified=3",
        old_path,
        new_path,
    })

    vim.fn.delete(old_path)
    vim.fn.delete(new_path)

    if code > 1 then
        local lines = { "diff error:" }
        vim.list_extend(lines, split_lines(vim.trim(stderr)))
        return lines
    end

    local lines = split_lines(stdout)
    if #lines == 0 then
        return { "No changes in this step." }
    end

    local old_header_found = false
    local new_header_found = false
    for index, line in ipairs(lines) do
        if not old_header_found and starts_with(line, "--- ") then
            lines[index] = "--- " .. old_snapshot.label
            old_header_found = true
        elseif not new_header_found and starts_with(line, "+++ ") then
            lines[index] = "+++ " .. new_snapshot.label
            new_header_found = true
        end
    end

    return lines
end

local function parse_changed_snapshot_lines(diff_lines, total_lines)
    local changed = {
        added = {},
        chunk = {},
        deletion_anchor = {},
    }

    local current_new_line = nil

    local function mark_line(target, bucket)
        if total_lines == 0 then
            return
        end

        local line_number = math.min(math.max(target, 1), total_lines)
        changed.chunk[line_number] = true
        if bucket then
            changed[bucket][line_number] = true
        end
    end

    for _, line in ipairs(diff_lines) do
        local new_start, new_count = line:match("^@@ %-%d+,?%d* %+(%d+),?(%d*) @@")
        if new_start then
            current_new_line = tonumber(new_start)
            local count = new_count ~= "" and tonumber(new_count) or 1

            if count == 0 then
                mark_line(current_new_line, "deletion_anchor")
            else
                for line_number = current_new_line, current_new_line + count - 1 do
                    mark_line(line_number)
                end
            end
        elseif current_new_line then
            if starts_with(line, "+") and not starts_with(line, "+++") then
                mark_line(current_new_line, "added")
                current_new_line = current_new_line + 1
            elseif starts_with(line, "-") and not starts_with(line, "---") then
                mark_line(current_new_line, "deletion_anchor")
            elseif not starts_with(line, "\\") then
                current_new_line = current_new_line + 1
            end
        end
    end

    return changed
end

local function parse_blame(stdout, fallback_lines)
    local rows = {}
    local author = nil

    for _, line in ipairs(split_lines(stdout)) do
        if starts_with(line, "author ") then
            author = line:sub(8)
        elseif starts_with(line, "\t") then
            table.insert(rows, {
                author = author or "unknown",
                text = line:sub(2),
            })
            author = nil
        end
    end

    if #rows == #fallback_lines then
        return rows
    end

    rows = {}
    for _, line in ipairs(fallback_lines) do
        table.insert(rows, {
            author = "unknown",
            text = line,
        })
    end

    return rows
end

local function build_blame(snapshot)
    if #snapshot.lines == 0 then
        return {}
    end

    if snapshot.commit then
        local code, stdout = run_git(state.root, {
            "blame",
            "--line-porcelain",
            snapshot.commit.hash,
            "--",
            snapshot.path,
        })

        if code == 0 then
            return parse_blame(stdout, snapshot.lines)
        end
    else
        local code, stdout = run_git(state.root, {
            "blame",
            "--line-porcelain",
            "--",
            state.relpath,
        })

        if code == 0 then
            return parse_blame(stdout, snapshot.lines)
        end
    end

    return parse_blame("", snapshot.lines)
end

local function truncate_display(value, width)
    if vim.fn.strdisplaywidth(value) <= width then
        return value
    end

    return vim.fn.strcharpart(value, 0, math.max(1, width - 3)) .. "..."
end

local function pad_display(value, width)
    local padding = width - vim.fn.strdisplaywidth(value)
    if padding <= 0 then
        return value
    end

    return value .. string.rep(" ", padding)
end

local function add_highlight(highlights, row, group, start_col, end_col)
    table.insert(highlights, {
        row = row,
        group = group,
        start_col = start_col or 0,
        end_col = end_col or -1,
    })
end

local function build_view()
    local index = state.index
    local current = get_snapshot(index)
    local older = nil

    if index + 1 <= #state.commits then
        older = get_snapshot(index + 1)
    else
        older = {
            lines = {},
            label = "empty tree",
            path = state.relpath,
        }
    end

    local diff = build_diff(older, current)
    local blame = build_blame(current)
    local changed_lines = parse_changed_snapshot_lines(diff, #blame)
    local lines = {}
    local highlights = {}

    local function add(line, group)
        local row = #lines
        table.insert(lines, line)
        if group then
            add_highlight(highlights, row, group)
        end
        return row
    end

    local total_steps = #state.commits
    local title = string.format("Lore: %s", state.relpath)
    add(title, "LoreHeader")

    if index == 0 then
        add(string.format("Step: present / %d past commits", total_steps), "LoreMeta")
        add("Snapshot: working tree buffer", "LoreMeta")
        add("Blame: git blame for the saved file; diff uses the current buffer lines.", "LoreMeta")
    else
        local commit = state.commits[index]
        add(string.format("Step: %d / %d past commits", index, total_steps), "LoreMeta")
        add(string.format("Commit: %s  %s  %s", commit.short, commit.date or "", commit.author or ""), "LoreMeta")
        add(string.format("Subject: %s", commit.subject or ""), "LoreMeta")
        if commit.path ~= state.relpath then
            add(string.format("Path at this commit: %s", commit.path), "LoreMeta")
        end
    end

    add("Keys: <Right> older commit, <Left> newer commit, q or :Loreq exits.", "LoreMeta")

    if current.error then
        add("")
        add("Snapshot error: " .. current.error, "LoreDelete")
    end

    add("")
    add("Changes introduced at this step", "LoreSection")

    for _, line in ipairs(diff) do
        local row = add(line)
        if starts_with(line, "@@") then
            add_highlight(highlights, row, "LoreHunk")
        elseif starts_with(line, "+") and not starts_with(line, "+++") then
            add_highlight(highlights, row, "LoreAdd")
        elseif starts_with(line, "-") and not starts_with(line, "---") then
            add_highlight(highlights, row, "LoreDelete")
        elseif starts_with(line, "diff --git") or starts_with(line, "index ") then
            add_highlight(highlights, row, "LoreMeta")
        end
    end

    add("")
    add("Snapshot with blame", "LoreSection")

    local line_width = #tostring(math.max(1, #blame))
    for line_number, row in ipairs(blame) do
        local author = pad_display(truncate_display(row.author, config.author_width), config.author_width)
        local prefix = string.format("%" .. line_width .. "d  %s | ", line_number, author)
        local rendered_row = add(prefix .. row.text)

        if changed_lines.added[line_number] then
            add_highlight(highlights, rendered_row, "LoreSnapshotAdd")
        elseif changed_lines.deletion_anchor[line_number] then
            add_highlight(highlights, rendered_row, "LoreSnapshotDeleteAnchor")
        elseif changed_lines.chunk[line_number] then
            add_highlight(highlights, rendered_row, "LoreSnapshotChunk")
        end

        add_highlight(highlights, rendered_row, "LoreAuthor", 0, #prefix)
    end

    if #blame == 0 then
        add("(empty file)", "LoreMeta")
    end

    return lines, highlights
end

local function define_highlights()
    vim.api.nvim_set_hl(0, "LoreHeader", { link = "Title", default = true })
    vim.api.nvim_set_hl(0, "LoreSection", { link = "Statement", default = true })
    vim.api.nvim_set_hl(0, "LoreMeta", { link = "Comment", default = true })
    vim.api.nvim_set_hl(0, "LoreAdd", { link = "DiffAdd", default = true })
    vim.api.nvim_set_hl(0, "LoreDelete", { link = "DiffDelete", default = true })
    vim.api.nvim_set_hl(0, "LoreHunk", { link = "DiffChange", default = true })
    vim.api.nvim_set_hl(0, "LoreAuthor", { link = "Identifier", default = true })
    vim.api.nvim_set_hl(0, "LoreSnapshotAdd", { link = "DiffAdd", default = true })
    vim.api.nvim_set_hl(0, "LoreSnapshotChunk", { link = "DiffText", default = true })
    vim.api.nvim_set_hl(0, "LoreSnapshotDeleteAnchor", { link = "DiffDelete", default = true })
end

function M.render()
    if not state or not vim.api.nvim_buf_is_valid(state.buf) then
        return
    end

    define_highlights()

    local lines, highlights = build_view()
    for index, line in ipairs(lines) do
        lines[index] = tostring(line):gsub("\r", ""):gsub("\n", "\\n")
    end

    vim.bo[state.buf].modifiable = true
    vim.api.nvim_buf_clear_namespace(state.buf, ns, 0, -1)
    vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, lines)

    for _, highlight in ipairs(highlights) do
        vim.api.nvim_buf_add_highlight(
            state.buf,
            ns,
            highlight.group,
            highlight.row,
            highlight.start_col,
            highlight.end_col
        )
    end

    vim.bo[state.buf].modified = false
    vim.bo[state.buf].modifiable = false

    if vim.api.nvim_win_is_valid(state.win) then
        pcall(vim.api.nvim_win_set_cursor, state.win, { 1, 0 })
    end
end

function M.move(delta)
    if not state then
        return
    end

    local next_index = math.max(0, math.min(#state.commits, state.index + delta))
    if next_index == state.index then
        return
    end

    state.index = next_index
    M.render()
end

local function restore_window_options(saved)
    if not saved or not vim.api.nvim_win_is_valid(saved.win) then
        return
    end

    for name, value in pairs(saved.options) do
        pcall(function()
            vim.wo[saved.win][name] = value
        end)
    end
end

function M.quit()
    if not state then
        return
    end

    local current = state
    state = nil

    if current.augroup then
        pcall(vim.api.nvim_del_augroup_by_id, current.augroup)
    end

    if vim.api.nvim_win_is_valid(current.win) and vim.api.nvim_buf_is_valid(current.original_buf) then
        pcall(vim.api.nvim_set_current_win, current.win)
        pcall(vim.api.nvim_win_set_buf, current.win, current.original_buf)
        restore_window_options(current)
        pcall(vim.api.nvim_win_set_cursor, current.win, current.cursor)
    end

    if vim.api.nvim_buf_is_valid(current.buf) then
        pcall(vim.api.nvim_buf_delete, current.buf, { force = true })
    end
end

local function configure_lore_buffer(buf)
    vim.bo[buf].bufhidden = "wipe"
    vim.bo[buf].buftype = "nofile"
    vim.bo[buf].buflisted = false
    vim.bo[buf].filetype = "lore"
    vim.bo[buf].modifiable = false
    vim.bo[buf].readonly = false
    vim.bo[buf].swapfile = false

    vim.keymap.set("n", "<Right>", function()
        M.move(1)
    end, { buffer = buf, desc = "Lore: older commit", nowait = true, silent = true })

    vim.keymap.set("n", "<Left>", function()
        M.move(-1)
    end, { buffer = buf, desc = "Lore: newer commit", nowait = true, silent = true })

    vim.keymap.set("n", "q", function()
        M.quit()
    end, { buffer = buf, desc = "Lore: quit", nowait = true, silent = true })

    vim.api.nvim_buf_call(buf, function()
        vim.cmd("cnoreabbrev <buffer> q Loreq")
        vim.cmd("cnoreabbrev <buffer> quit Loreq")
    end)
end

local function configure_window(win)
    vim.wo[win].cursorline = true
    vim.wo[win].foldcolumn = "0"
    vim.wo[win].list = false
    vim.wo[win].number = false
    vim.wo[win].relativenumber = false
    vim.wo[win].signcolumn = "no"
    vim.wo[win].spell = false
    vim.wo[win].wrap = false
end

function M.start()
    if state then
        M.quit()
    end

    local original_buf = vim.api.nvim_get_current_buf()
    local original_name = vim.api.nvim_buf_get_name(original_buf)
    if original_name == "" then
        notify("Salve o arquivo antes de abrir o Lore.", vim.log.levels.WARN)
        return
    end

    local path = vim.fs.normalize(vim.fn.fnamemodify(original_name, ":p"))
    local root, root_err = find_repo_root(path)
    if not root then
        notify("Arquivo fora de um repositorio git: " .. (root_err or "git root nao encontrado"), vim.log.levels.ERROR)
        return
    end

    local relpath = relative_path(root, path)
    local commits, commits_err = load_commits(root, relpath)
    if not commits then
        notify("Nao foi possivel carregar o historico: " .. commits_err, vim.log.levels.ERROR)
        return
    end

    local win = vim.api.nvim_get_current_win()
    local cursor = vim.api.nvim_win_get_cursor(win)
    local options = {
        cursorline = vim.wo[win].cursorline,
        foldcolumn = vim.wo[win].foldcolumn,
        list = vim.wo[win].list,
        number = vim.wo[win].number,
        relativenumber = vim.wo[win].relativenumber,
        signcolumn = vim.wo[win].signcolumn,
        spell = vim.wo[win].spell,
        wrap = vim.wo[win].wrap,
    }

    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_name(buf, "lore://" .. relpath)
    configure_lore_buffer(buf)
    vim.api.nvim_win_set_buf(win, buf)
    configure_window(win)

    state = {
        buf = buf,
        commits = commits,
        cursor = cursor,
        index = 0,
        options = options,
        original_buf = original_buf,
        relpath = relpath,
        root = root,
        snapshots = {},
        win = win,
    }

    state.augroup = vim.api.nvim_create_augroup("config_lore_" .. buf, { clear = true })
    vim.api.nvim_create_autocmd("BufWipeout", {
        buffer = buf,
        group = state.augroup,
        callback = function()
            if state and state.buf == buf then
                state = nil
            end
        end,
    })

    M.render()
end

vim.api.nvim_create_user_command("Lore", function()
    M.start()
end, { desc = "Open interactive git history for the current file" })

vim.api.nvim_create_user_command("Loreq", function()
    M.quit()
end, { desc = "Close Lore mode" })

return M
