local surround = require("jelly.surround")
local terminal = require("jelly.terminal")

-- Function to show a temporary popup
local function debug_popup(lines)
    -- Create buffer for popup window
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    -- Window configuration
    local opts = {
        relative = 'editor',
        width = 100,
        height = 50,
        col = vim.api.nvim_win_get_width(0),
        row = 5,
        style = 'minimal',
        border = 'rounded',
    }
    -- Open the floating window (popup)
    local win = vim.api.nvim_open_win(buf, true, opts)
    -- Close window after some time
    vim.defer_fn(function()
        if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_close(win, true)
        end
    end, 5000)
end


-- Set general mappings
vim.g.mapleader = " "
vim.keymap.set("n", "<Space>", "<Nop>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>q", "<cmd>q<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>l", "<cmd>15Lexplore<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<Esc>", "<cmd>let @/=\"\"<CR>", { noremap = true, silent = true })

-- Tab mappings
vim.keymap.set({ "n", "t" }, "<C-t>", "<cmd>tabnew<CR>", { noremap = true, silent = true })
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { noremap = true, silent = true })
vim.keymap.set({ "n", "t" }, "<A-l>", "gt", { noremap = true, silent = true })
vim.keymap.set({ "n", "t" }, "<A-h>", "gT", { noremap = true, silent = true })

-- Nice to have
vim.keymap.set("v", "<Tab>", ">gv", { noremap = true, silent = true })
vim.keymap.set("v", "<S-Tab>", "<gv", { noremap = true, silent = true })
vim.keymap.set({ "n", "v", "t" }, "<C-s>", "<cmd>rightbelow vnew<CR>", { noremap = true, silent = true })
vim.keymap.set({ "n", "t" }, "<C-Space>", terminal.toggle_terminal, { noremap = true, silent = true })

-- Surround
vim.keymap.set({ "v", "x" }, "<leader>ss", surround.surround_general, { noremap = true, silent = true })
vim.keymap.set({ "v", "x" }, "<leader>st", surround.surround_tag, { noremap = true, silent = true })
vim.keymap.set({ "v", "x" }, "<leader>sb", surround.surround_bracket, { noremap = true, silent = true })

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

-- Extra
-- To check LSP remapings got to after/plugin/lsp.lua
-- To check Telescope remapings got to after/plugin/telescope.lua
