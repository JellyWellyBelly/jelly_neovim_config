local telescope = require("telescope")
local builtin = require("telescope.builtin")
local themes = require("telescope.themes")
local actions = require("telescope.actions")
local sorters = require("telescope.sorters")

local mappings = {
    n = {
        ["<c-s>"] = actions.select_horizontal,
        ["<c-v"] = actions.select_vertical,
        ["<c-t>"] = actions.select_tab,
        ["D"] = actions.delete_buffer,
        ["dd"] = actions.delete_buffer,
        ["m"] = actions.toggle_selection,
        ["sm"] = actions.send_selected_to_qflist + actions.open_qflist,
        ["<leader>q"] = actions.close,
        ["<Esc>"] = actions.nop
    },
}

telescope.setup({
    defaults = {
        file_sorter = sorters.get_fuzzy_file,
        generic_sorter = sorters.get_fzf_sorter,
        hidden = true,
        preview = false,
        mappings = mappings,
        theme = "ivy",
        file_ignore_patterns = { "node_modules", "*.db", "*.min.js", "*.min.ts", "*.pyc", "*.o", ".swp" },
    },
    pickers = {
        find_files = themes.get_ivy({
            multi_selection = true,
            prompt_title = "Search files",
        }),
        live_grep = themes.get_ivy({
            multi_selection = true,
            prompt_title = "Search text",
            preview = false,
        }),
        buffers = themes.get_ivy({
            prompt_title = "Search buffers",
            multi_selection = false,
            preview = false,
        }),
        diagnostics = themes.get_ivy({
            prompt_title = "Search issues",
            multi_selection = false,
            preview = true,
        }),
        treesitter = themes.get_ivy({
            prompt_title = "Search symbols",
            multi_selection = false,
            preview = true,
        }),
    },
    extensions = {
        fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = false,
        }
    }
})

telescope.load_extension("fzf")

vim.keymap.set('n', '<leader>ff', builtin.find_files)
vim.keymap.set('n', '<leader>fw', builtin.live_grep)
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, {})
vim.keymap.set("n", "<leader>E", builtin.diagnostics)
vim.keymap.set("n", "<leader>A", "<cmd>Telescope treesitter<CR>")
vim.keymap.set("n", "<leader>b", builtin.buffers)
