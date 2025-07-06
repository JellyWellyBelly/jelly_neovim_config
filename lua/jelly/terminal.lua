local M = {}

local state = {
    floating = {
        buf = -1,
        win = -1
    }
}


local function create_terminal_window(opts)
    -- Position and size of terminal window
    local width = math.floor(vim.o.columns * 0.8)
    local height = math.floor(vim.o.lines * 0.8)
    local col = math.floor((vim.o.columns - width) / 2)
    local row = math.floor((vim.o.lines - height) / 2)
    -- Create buf
    local buf = nil
    if vim.api.nvim_buf_is_valid(opts.buf) then
        buf = opts.buf
    else
        buf = vim.api.nvim_create_buf(false, true)
    end
    -- Pretty options
    local win_opts = {
        relative = 'editor',
        width = width,
        height = height,
        col = col,
        row = row,
        style = 'minimal',
        border = 'double',
        title = ' < Terminal > ',
        title_pos = 'center',
    }
    -- Create window
    vim.api.nvim_buf_set_name(buf, vim.fn.tempname())
    local win = vim.api.nvim_open_win(buf, true, win_opts)
    return { buf = buf, win = win }
end

function M.toggle_terminal()
    if not vim.api.nvim_win_is_valid(state.floating.win) then
        state.floating = create_terminal_window({ buf = state.floating.buf })
        if vim.bo[state.floating.buf].buftype ~= "terminal" then
            vim.cmd.terminal()
            vim.cmd("startinsert")
        end
    else
        vim.api.nvim_win_hide(state.floating.win)
    end
end

return M
