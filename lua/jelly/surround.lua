local M = {}

-- Specific handler for C language
-- This could be done with other tools, but I gave it a go aswell
local function check_clang_comm(start_str, end_str)
    if start_str == "/*" then
        return "/*", "*/"
    end
    if start_str == "*/" then
        return "/*", "*/"
    end
    if start_str == "//" then
        return "//", ""
    end
    return start_str, end_str
end

-- TODO
-- This has to be improved, particularly with motions and without the use of < or >
local function check_brackets(start_str, _)
    -- Special case because it's so common
    local token_list = {}
    local token_str_buf = ""
    local itr = 1
    -- Building "token" list
    for i = 1, #start_str do
        local char = start_str:sub(i, i)
        if not string.find("()[]{}", char, 1, true) then
            token_str_buf = token_str_buf .. char
        else
            token_list[itr] = token_str_buf
            token_str_buf = ""
            itr = itr + 1
            if char == "(" or char == ")" then
                token_list[itr] = "("
            elseif char == "[" or char == "]" then
                token_list[itr] = "["
            elseif char == "{" or char == "}" then
                token_list[itr] = "{"
            else
                token_str_buf = token_str_buf .. char
            end
            itr = itr + 1
        end
    end
    if not (token_str_buf == "") then
        token_list[itr] = token_str_buf
    end
    -- Consume token list
    local res_start_str = ""
    local res_end_str = ""
    for _, v in ipairs(token_list) do
        if v == "(" then
            res_start_str = res_start_str .. "("
            res_end_str = ")" .. res_end_str
        elseif v == "[" then
            res_start_str = res_start_str .. "["
            res_end_str = "]" .. res_end_str
        elseif v == "{" then
            res_start_str = res_start_str .. "{"
            res_end_str = "}" .. res_end_str
        else
            res_start_str = res_start_str .. v
            res_end_str = v .. res_end_str
        end
    end
    return res_start_str, res_end_str
end

local function surround_helper(start_str, end_str)
    local mode = vim.api.nvim_get_mode().mode
    local curr_buf = 0
    -- Exiting current mode to make marks
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<esc>', true, false, true), 'x', false)
    -- Applies text only at the end points of the visual selection
    if mode == "v" then
        -- Getting positions of selection
        local start_pos = vim.api.nvim_buf_get_mark(curr_buf, "<")
        local end_pos = vim.api.nvim_buf_get_mark(curr_buf, ">")
        local start_line, start_col = start_pos[1] - 1, start_pos[2]
        local end_line, end_col = end_pos[1] - 1, end_pos[2] + 1
        -- Get text and surround it
        local lines = vim.api.nvim_buf_get_text(curr_buf, start_line, start_col, end_line, end_col, {})
        lines[1] = start_str .. lines[1]
        lines[#lines] = lines[#lines] .. end_str
        vim.api.nvim_buf_set_text(curr_buf, start_line, start_col, end_line, end_col, lines)
        return
    end
    local start_line = vim.api.nvim_buf_get_mark(curr_buf, "<")[1] - 1
    local end_line = vim.api.nvim_buf_get_mark(curr_buf, ">")[1]
    local lines = vim.api.nvim_buf_get_lines(curr_buf, start_line, end_line, {})
    if mode == "V" then
        -- In "V", it applies surround on every line
        -- Left white space is respected
        for i, line in ipairs(lines) do
            local temp = line
            -- %1 are the empty chars
            -- %2 is the remaining string
            lines[i] = string.gsub(temp, "^(%s*)(%S)", "%1" .. start_str .. "%2") .. end_str
        end
    elseif mode == "\22" then
        -- Apply before and after selection
        table.insert(lines, 1, start_str)
        table.insert(lines, end_str)
    else
        return
    end
    vim.api.nvim_buf_set_lines(curr_buf, start_line, end_line, false, lines)
end

-- Main function
function M.surround_general()
    local text_to_surround = vim.fn.input("Enter text to surround: ")
    local start_str, end_str
    start_str, end_str = check_brackets(text_to_surround, text_to_surround)
    start_str, end_str = check_clang_comm(start_str, end_str)
    surround_helper(start_str, end_str)
end

function M.surround_tag()
    local text_to_surround = vim.fn.input("Enter text to surround: ")
    if text_to_surround == "" then
        return
    end
    local start_str, end_str
    start_str, end_str = string.format("<%s>", text_to_surround), string.format("</%s>", text_to_surround)
    surround_helper(start_str, end_str)
end

function M.surround_bracket()
    surround_helper("(", ")")
end

return M
