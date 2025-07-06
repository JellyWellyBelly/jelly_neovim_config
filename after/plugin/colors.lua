function colorOfDefault(color)
    color = color or "github_dark"
    vim.cmd("colorscheme " .. color)
end


colorOfDefault("github_dark_tritanopia")
