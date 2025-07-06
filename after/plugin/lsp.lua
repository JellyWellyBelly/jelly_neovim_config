local lsp_list = { "lua_ls", "clangd", "ts_ls", "cssls", "jsonls", "ast_grep" }

local attach = function(_, _)
    local telescope = require("telescope.builtin")
    vim.keymap.set("n", "<leader>n", vim.lsp.buf.rename, {})
    vim.keymap.set("n", "<leader><CR>", vim.lsp.buf.code_action, {})
    vim.keymap.set("n", "<leader>w", function()
        vim.lsp.buf.format()
        vim.cmd("w")
    end, {})
    vim.keymap.set("n", "<leader>D", telescope.lsp_implementations, {})
    vim.keymap.set("n", "<leader>d", telescope.lsp_definitions, {})
    vim.keymap.set("n", "<leader>r", telescope.lsp_references, {})
end

require("mason").setup()
require("mason-lspconfig").setup({ ensure_installed = lsp_list, })
for _, value in ipairs(lsp_list) do
    require("lspconfig")[value].setup {
        on_attach = attach,
    }
end
require("lspconfig")["pylsp"].setup({
    on_attach = attach,
    settings = {
        pylsp = {
            plugins = {
                black = { enabled = true },
                pycodestyle = { maxLineLength = 100, ignore = { "E501", "W605" } },
                jedi_completion = { fuzzy = true },
                rope_autoimport = { enabled = true, },
                rope_completion = { enabled = true, }
            }
        }
    }
})
