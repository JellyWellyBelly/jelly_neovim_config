-- Highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
    pattern = "*",
    callback = function()
        vim.highlight.on_yank({
            higroup = "IncSearch", -- Highlight group used
            timeout = 100,         -- Duration in ms
            on_visual = true,      -- Highlight visual selection
            on_macro = true,       -- Also highlight macro
        })
    end,
})
