local M = {}

local terminal_bufnr = nil
local terminal_winid = nil
local terminal_job_id = nil

local function preferred_shell()
    if vim.fn.executable('fish') == 1 then
        return 'fish'
    end

    if vim.o.shell and vim.o.shell ~= '' then
        return vim.o.shell
    end

    return vim.env.SHELL or 'sh'
end

local function job_is_running(job_id)
    return type(job_id) == 'number' and job_id > 0 and vim.fn.jobwait({ job_id }, 0)[1] == -1
end

local function create_terminal_buffer()
    terminal_bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_win_set_buf(terminal_winid, terminal_bufnr)

    vim.bo[terminal_bufnr].bufhidden = 'hide'
    vim.bo[terminal_bufnr].buflisted = false

    terminal_job_id = vim.fn.termopen(preferred_shell(), {
        on_exit = function()
            terminal_job_id = nil
        end,
    })
end

function M.close()
    if terminal_winid and vim.api.nvim_win_is_valid(terminal_winid) then
        vim.api.nvim_win_close(terminal_winid, true)
        terminal_winid = nil
        return true
    end

    return false
end

function M.toggle()
    if M.close() then
        return
    end

    vim.cmd('botright 15split')
    terminal_winid = vim.api.nvim_get_current_win()

    if terminal_bufnr
        and vim.api.nvim_buf_is_valid(terminal_bufnr)
        and job_is_running(terminal_job_id)
    then
        vim.api.nvim_win_set_buf(terminal_winid, terminal_bufnr)
    else
        create_terminal_buffer()
    end

    vim.cmd('startinsert')
end

return M
