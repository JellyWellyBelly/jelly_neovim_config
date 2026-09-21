--------------
-- REQUIRES --
--------------

require("vim._core.ui2").enable({})


-------------
-- GLOBALS --
-------------

local available_colors = {
    -- Based on Vague
    jelly_pastel = {
        added = "#80b918",
        bracket = "#b4d4cf",
        builtin = "#b4d4cf",
        comment = "#adb5bd",
        constant = "#cdcdcd",
        cursor_bg = "#6e94b2",
        cursor_linenr = "#6e94b2",
        error = "#9d0208",
        error_bg = "#9d0208",
        error_fg = "#ffffff",
        fg = "#cdcdcd",
        func = "#c48282",
        identifier = "#9fa0ff",
        keyword = "#6e94b2",
        line = "#252530",
        number = "#cdcdcd",
        operator = "#90a0b5",
        parameter = "#bb9dbd",
        property = "#c3c3d5",
        search_bg = "#aec6cf",
        search_fg = "#222222",
        cur_search_bg = "#d6e2e7",
        cur_search_fg = "#222222",
        status_line_bg = "#9fa0ff",
        status_line_fg = "#222222",
        status_linenc_bg = "#B069DB",
        status_linenc_fg = "#dddddd",
        string = "#eab590",
        terminal_color_09 = "#e08398",
        terminal_color_10 = "#99b782",
        terminal_color_11 = "#f5cb96",
        terminal_color_12 = "#8ba9c1",
        terminal_color_13 = "#c9b1ca",
        terminal_color_14 = "#bebeda",
        terminal_color_15 = "#d7d7d7",
        todo = "#969673",
        type = "#9bb4bc",
        warning = "#ffd000"
    },
    -- Based on Miasma
    jelly_woods = {
        added = "#78824b",
        bracket = "#b37342",
        builtin = "#c9a554",
        comment = "#666666",
        constant = "#bb7744",
        cursor = "#908f6d",
        cursor_bg = "#bb7744",
        cursor_linenr = "#78834b",
        delimiter = "#f7d08a",
        error = "#9d0208",
        error_bg = "#bb7744",
        error_fg = "#c2c2b0",
        fg = "#b36d43",
        folded_bg = "#1c1c1c",
        folded_fg = "#b36d43",
        func = "#78834b",
        identifier = "#e3cf88",
        keyword = "#5f875f",
        linenr = "#666666",
        number = "#78824b",
        operator = "#c89b62",
        status_line_bg = "#bb7744",
        status_line_fg = "#222222",
        status_linenc_bg = "#685641",
        status_linenc_fg = "#d4c282",
        string = "#5d4e3c",
        terminal_color_09 = "#e08398",
        terminal_color_10 = "#99b782",
        terminal_color_11 = "#f5cb96",
        terminal_color_12 = "#8ba9c1",
        terminal_color_13 = "#c9b1ca",
        terminal_color_14 = "#bebeda",
        terminal_color_15 = "#d7d7d7",
        todo = "#f7d08a",
        type = "#463c31",
        visual = "#e3f09b",
        warning = "#ffd000"
    }
}

----------------
-- PROTOTYPES --
----------------

local set_current_colorscheme

---------------------
-- GENERAL OPTIONS --
---------------------

vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.netrw_liststyle = 3
vim.g.netrw_banner = 1

vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true

vim.opt.wrap = false
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.termguicolors = true
vim.opt.scrolloff = 15
vim.opt.sidescrolloff = 20
vim.opt.colorcolumn = "120"
vim.opt.cursorline = true
vim.opt.showmatch = true

vim.opt.showmode = true
vim.opt.guicursor = "n-v-c-i:block-Cursor"
vim.opt.clipboard = "unnamedplus"
vim.opt.signcolumn = "yes"
vim.opt.inccommand = "split"
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.foldcolumn = "1"

vim.opt.eof = true
vim.opt.swapfile = false

vim.lsp.omnifunc = "v:lua.vim.lsp.omnifunc"
vim.opt.complete:append("o")
vim.opt.completeopt = { "fuzzy", "menuone", "noselect", "popup" }
vim.opt.winborder = "double"
vim.opt.pumborder = "double"
vim.opt.pumheight = 5
vim.opt.pumblend = 30


------------------
-- AUTOCOMMANDS --
------------------

-- Highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
    pattern = "*",
    callback = function()
        vim.highlight.on_yank({
            higroup = "IncSearch", -- Highlight group used
            timeout = 100,         -- Duration in ms
            on_visual = true,      -- Highlight visual selection
            on_macro = true        -- Also highlight macro
        })
    end
})


--------------
-- COMMANDS --
--------------

vim.api.nvim_create_user_command("JellyColorSchemes", function(opts)
    if available_colors[opts.args] ~= nil then
        set_current_colorscheme({ colorscheme = opts.args })
        return
    end
    vim.notify("Requires one of the following color schemes: " .. string(vim.fn.keys(available_colors)),
        vim.log.levels.WARN)
end, {
    desc = "Changes color scheme. Usage: JellyColorScheme <option>",
    nargs = 1,
    complete = function(arglead)
        local values = vim.fn.keys(available_colors)
        return vim.tbl_filter(function(value)
            return vim.startswith(value, arglead)
        end, values)
    end
})

--------------
-- SURROUND --
--------------

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
                token_list[itr] =
                "("
            elseif char == "[" or char == "]" then
                token_list[itr] =
                "["
            elseif char == "{" or char == "}" then
                token_list[itr] =
                "{"
            else
                token_str_buf = token_str_buf .. char
            end
            itr = itr + 1
        end
    end
    if not (token_str_buf == "") then
        token_list[itr] = token_str_buf
    end
    -- Consume "token" list
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
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<esc>", true, false, true), "x", false)
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
    local lines = vim.api.nvim_buf_get_lines(curr_buf, start_line, end_line, false)
    if mode == "V" then
        -- In "V", it applies surround on every line
        -- Left white space is respected
        for i, line in ipairs(lines) do
            local temp = line
            -- %1 are the white chars
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
local function surround_general()
    local text_to_surround = vim.fn.input("Enter text to surround: ")
    if text_to_surround == "" then
        return
    end
    local start_str, end_str
    start_str, end_str = check_brackets(text_to_surround, text_to_surround)
    start_str, end_str = check_clang_comm(start_str, end_str)
    surround_helper(start_str, end_str)
end

local function surround_tag()
    local text_to_surround = vim.fn.input("Enter text to surround: ")
    if text_to_surround == "" then
        return
    end
    local start_str, end_str
    start_str = string.format("<%s>", text_to_surround)
    end_str = string.format("</%s>", text_to_surround)
    surround_helper(start_str, end_str)
end

local function surround_bracket()
    surround_helper("(", ")")
end

local function surround_word()
    vim.cmd("normal! viw")
    surround_general()
end

local function surround_in_word()
    vim.cmd("normal! viW")
    surround_general()
end


--------------
-- TERMINAL --
--------------

local terminal_state = {
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
        relative = "editor",
        width = width,
        height = height,
        col = col,
        row = row,
        style = "minimal",
        border = "double",
        title =
        " < Terminal > ",
        title_pos = "center"
    }
    -- Create window
    vim.api.nvim_buf_set_name(buf, vim.fn.tempname())
    local win = vim.api.nvim_open_win(buf, true, win_opts)
    return {
        buf = buf,
        win = win
    }
end

local function toggle_terminal()
    if not vim.api.nvim_win_is_valid(terminal_state.floating.win) then
        terminal_state.floating = create_terminal_window({ buf = terminal_state.floating.buf })
        if vim.bo[terminal_state.floating.buf].buftype ~= "terminal" then
            vim.cmd.terminal()
            vim.cmd("startinsert")
        end
    else
        vim.api.nvim_win_hide(terminal_state.floating.win)
    end
end


---------
-- LSP --
---------

local on_attach = function(client, bufnr)
    if client:supports_method("textDocument/completion") then
        vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = true })
    end
end

if vim.fn.executable("lua-language-server") then
    vim.lsp.config("lua_ls", {
        cmd = { "lua-language-server" },
        filetypes = { "lua" },
        on_attach = on_attach,
        settings = {
            Lua = {
                runtime = { version = "LuaJIT" },
                diagnostics = {
                    globals = { "vim" },
                    unusedLocalExclude = { "_" }, -- Variables that do not have their name style checked
                    neededFileStatus = {
                        ["name-style-check"] = "Opened",
                        ["codestyle-check"] = "Opened"
                    }
                },
                workspace = { library = vim.api.nvim_get_runtime_file("", true) },
                telemetry = { enable = false },
                hint = { enable = true },
                format = {
                    enable = true,
                    defaultConfig = {
                        indent_style = "space",
                        indent_size = "4",
                        tab_width = "4",
                        quote_style = "double",
                        quote_style_force = "true",
                        continuation_indent = "4",
                        max_line_length = "120",
                        space_around_table_append_operator = "true",
                        align_function_params = "false",
                        align_continuous_assign_statement = "false",
                        align_continuous_rect_table_field = "false",
                        align_array_table = "false",
                        align_call_args = "false",
                        trailing_table_separator = "never"
                    }
                },
                nameStyle = {
                    config = {
                        local_name_style = "snake_case",
                        function_param_name_style = "snake_case",
                        function_name_style = "snake_case",
                        local_function_name_style = "snake_case",
                        table_field_name_style = "snake_case",
                        global_variable_name_style = "UPPER_SNAKE_CASE",
                        class_name_style = "PascalCase",
                        const_variable_name_style = "snake_case"
                    }
                }
            }
        }
    })
    vim.lsp.enable("lua_ls")
end


-- TODO
if vim.fn.executable("clangd") then
    vim.lsp.config["c"] = {
        cmd = { "clangd" },
        filetypes = { "c" }
    }
    vim.lsp.enable("c")
end

-- Mappings
vim.keymap.set("n", "<leader>n", function(new_name)
    if #vim.lsp.get_clients({ bufnr = 0 }) > 0 then
        local client = vim.lsp.get_clients({ bufnr = 0 })[1]
        if client:supports_method("textDocument/rename") then
            vim.lsp.buf.rename(new_name, { bufnr = 0 })
        end
    end
end, {})

vim.keymap.set("n", "<leader><CR>", function()
    if #vim.lsp.get_clients({ bufnr = 0 }) > 0 then
        local client = vim.lsp.get_clients({ bufnr = 0 })[1]
        if client:supports_method("textDocument/codeAction") then
            vim.lsp.buf.code_action({ bufnr = 0 })
        end
    end
end, {})

vim.keymap.set("n", "<leader>w", function()
    if #vim.lsp.get_clients({ bufnr = 0 }) > 0 then
        local client = vim.lsp.get_clients({ bufnr = 0 })[1]
        if client:supports_method("textDocument/completion") then
            vim.lsp.completion.enable(true, client.id, 0, { autotrigger = true })
        end
        vim.lsp.buf.format()
    end
    vim.cmd("w")
end, {})


--------------
-- MAPPINGS --
--------------


-- Set general mappings
vim.keymap.set({ "n" }, "<Space>", "<Nop>", { noremap = true, silent = true })
vim.keymap.set({ "n" }, "<leader>q", "<cmd>q<CR>", { noremap = true, silent = true })
vim.keymap.set({ "n" }, "<leader>l", "<cmd>15Lexplore<CR>", { noremap = true, silent = true })
vim.keymap.set({ "n" }, "<Esc>", "<cmd>let @/=\"\"<CR>", { noremap = true, silent = true })

-- Tab mappings
vim.keymap.set({ "n", "t" }, "<C-t>", "<cmd>tabnew<CR>", { noremap = true, silent = true })
vim.keymap.set({ "t" }, "<Esc>", "<C-\\><C-n>", { noremap = true, silent = true })
vim.keymap.set({ "n", "t" }, "<A-l>", "gt", { noremap = true, silent = true })
vim.keymap.set({ "n", "t" }, "<A-h>", "gT", { noremap = true, silent = true })

-- Nice to have
vim.keymap.set({ "v" }, ">", ">gv", { noremap = true, silent = true })
vim.keymap.set({ "v" }, "<", "<gv", { noremap = true, silent = true })
vim.keymap.set({ "n" }, "J", "mzJ`z", { noremap = true, silent = true })
vim.keymap.set({ "v" }, "J", ":m '>+1<CR>gv=gv", { noremap = true, silent = true })
vim.keymap.set({ "v" }, "K", ":m '<-2<CR>gv=gv", { noremap = true, silent = true })
vim.keymap.set({ "n", "v", "t" }, "<C-s>", "<cmd>rightbelow vnew<CR>",
    { noremap = true, silent = true }
)
vim.keymap.set({ "n", "t" }, "<C-Space>", toggle_terminal, { noremap = true, silent = true })

-- Surround
vim.keymap.set({ "v", "x" }, "<leader>ss", surround_general, { noremap = true, silent = true })
vim.keymap.set({ "v", "x" }, "<leader>st", surround_tag, { noremap = true, silent = true })
vim.keymap.set({ "v", "x" }, "<leader>sb", surround_bracket, { noremap = true, silent = true })
vim.keymap.set({ "n" }, "<leader>sw", surround_word, { noremap = true, silent = true })
vim.keymap.set({ "n" }, "<leader>sW", surround_in_word, { noremap = true, silent = true })

-- Learning
vim.keymap.set({ "n", "v" }, "<Up>", "<Nop>", { noremap = true, silent = true })
vim.keymap.set({ "n", "v" }, "<Down>", "<Nop>", { noremap = true, silent = true })
vim.keymap.set({ "n", "v" }, "<Left>", "<Nop>", { noremap = true, silent = true })
vim.keymap.set({ "n", "v" }, "<Right>", "<Nop>", { noremap = true, silent = true })

-- Navigating
vim.keymap.set({ "n", "v" }, "<C-d>", "<C-d>zz", { noremap = true, silent = true })
vim.keymap.set({ "n", "v" }, "<C-u>", "<C-u>zz", { noremap = true, silent = true })
vim.keymap.set({ "n", "v" }, "<C-o>", "<C-o>zz", { noremap = true, silent = true })
vim.keymap.set({ "n", "v" }, "<C-i>", "<C-i>zz", { noremap = true, silent = true })
vim.keymap.set({ "n" }, "n", "nzzzv", { noremap = true, silent = true })
vim.keymap.set({ "n" }, "N", "Nzzzv", { noremap = true, silent = true })

-- Config
vim.keymap.set({ "n" }, "<leader>C", function()
    vim.cmd("edit " .. vim.fn.fnameescape(vim.fn.stdpath("config") .. "/init.lua"))
end, { noremap = true, silent = true })

-- Miscellanious
vim.keymap.set({ "n" }, "<leader>e", function()
    vim.diagnostic.open_float(nil, { focus = false, border = "rounded" })
end, { noremap = true, silent = true })


-----------------
-- DIAGNOSTICS --
-----------------

vim.diagnostic.config({ virtual_text = true })


-----------------
-- COLORSCHEME --
-----------------

vim.cmd("highlight clear")
vim.cmd("syntax reset")

---Changes colorscheme based of preset values.
---The new colorschemes are NOT included in colorscheme list when using:
---
---:colorscheme
---
---Has 2 colors available:
---    jelly_pastel (Default)
---    jelly_woods
---
---Example:
---
---```lua
---set_highlights({ colorscheme = "jelly_pastel" })
---```
---
--- If input is badly formatted, the default color will be applied instead.
---@param options { colorscheme:string }?
set_current_colorscheme = function(options)
    -- Picking color based on options given
    local picked_scheme = available_colors["jelly_pastel"] -- Default color
    if options ~= nil then
        for color_key, colorscheme in pairs(available_colors) do
            if options.colorscheme == color_key then
                picked_scheme = colorscheme
                break
            end
        end
    end
    local highlight_group_setting = {
        ["@variable"] = { fg = picked_scheme.builtin },
        ["@variable.parameter"] = { fg = picked_scheme.identifier },
        ["@string.special.url"] = { fg = picked_scheme.string, bold = true, underline = true },
        ["@punctuation.bracket"] = { fg = picked_scheme.bracket },
        Added = { fg = picked_scheme.added, bold = true },
        Boolean = { fg = picked_scheme.number, bold = true },
        Changed = { fg = picked_scheme.warning, bold = true },
        Character = { fg = picked_scheme.string },
        Comment = { fg = picked_scheme.comment },
        Conditional = { fg = picked_scheme.keyword, bold = true },
        Constant = { fg = picked_scheme.constant, bold = true },
        CurSearch = { fg = picked_scheme.cur_search_fg, bg = picked_scheme.cur_search_bg },
        Cursor = { bg = picked_scheme.cursor_bg, fg = picked_scheme.cursor },
        CursorLineNr = { fg = picked_scheme.cursor_linenr, bold = true },
        Delimiter = { fg = picked_scheme.fg },
        DiffChange = { fg = picked_scheme.warning },
        Error = { fg = picked_scheme.error_fg, bg = picked_scheme.error_bg, bold = true },
        Exception = { fg = picked_scheme.keyword, bold = true },
        Float = { fg = picked_scheme.number },
        FloatBorder = { fg = picked_scheme.fg, bold = true },
        FloatTitle = { fg = picked_scheme.fg, bold = true },
        Function = { fg = picked_scheme.func },
        Identifier = { fg = picked_scheme.identifier },
        Include = { fg = picked_scheme.keyword, bold = true },
        IncSearch = { fg = picked_scheme.search_fg, bg = picked_scheme.search_bg },
        Search = { fg = picked_scheme.search_fg, bg = picked_scheme.search_bg },
        Keyword = { fg = picked_scheme.keyword },
        Label = { fg = picked_scheme.keyword, bold = true },
        Linenr = { fg = picked_scheme.linenr },
        NormalFloat = { fg = picked_scheme.fg },
        Number = { fg = picked_scheme.number },
        Operator = { fg = picked_scheme.operator },
        PreProc = { fg = picked_scheme.keyword, bold = true },
        Repeat = { fg = picked_scheme.keyword, bold = true },
        Special = { fg = picked_scheme.bracket },
        SpecialChar = { fg = picked_scheme.keyword, bold = true },
        SpecialComment = { fg = picked_scheme.keyword, bold = true },
        Statement = { fg = picked_scheme.keyword, bold = true },
        StatusLine = { bg = picked_scheme.status_line_bg, fg = picked_scheme.status_line_fg, bold = true },
        StatusLineNC = { bg = picked_scheme.status_linenc_bg, fg = picked_scheme.status_linenc_fg, bold = true },
        StorageClass = { fg = picked_scheme.constant },
        String = { fg = picked_scheme.string },
        Structure = { fg = picked_scheme.constant },
        Tag = { fg = picked_scheme.builtin },
        Title = { fg = picked_scheme.property },
        Todo = { fg = picked_scheme.todo, bold = true },
        Type = { fg = picked_scheme.type },
        Typedef = { fg = picked_scheme.constant },
        Removed = { fg = picked_scheme.error, bold = true }
    }
    -- Setting terminal colors
    vim.g.terminal_color_0 = picked_scheme.line
    vim.g.terminal_color_1 = picked_scheme.error
    vim.g.terminal_color_2 = picked_scheme.plus
    vim.g.terminal_color_3 = picked_scheme.warning
    vim.g.terminal_color_4 = picked_scheme.keyword
    vim.g.terminal_color_5 = picked_scheme.parameter
    vim.g.terminal_color_6 = picked_scheme.constant
    vim.g.terminal_color_7 = picked_scheme.fg
    vim.g.terminal_color_8 = picked_scheme.comment
    vim.g.terminal_color_9 = picked_scheme.terminal_color_9
    vim.g.terminal_color_10 = picked_scheme.terminal_color_10
    vim.g.terminal_color_11 = picked_scheme.terminal_color_11
    vim.g.terminal_color_12 = picked_scheme.terminal_color_12
    vim.g.terminal_color_13 = picked_scheme.terminal_color_13
    vim.g.terminal_color_14 = picked_scheme.terminal_color_14
    vim.g.terminal_color_15 = picked_scheme.terminal_color_15
    -- Setting highlight colors
    for group, highlight_options in pairs(highlight_group_setting) do
        vim.api.nvim_set_hl(0, group, highlight_options)
    end
end
set_current_colorscheme() -- Sneaky call :>
