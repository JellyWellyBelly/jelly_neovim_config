vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
    use { 'wbthomason/packer.nvim' }
    use {
        'nvim-telescope/telescope.nvim',
        tag = '0.1.8',
        requires = { {
            'sharkdp/fd',
            'nvim-lua/plenary.nvim',
        } },
        dependencies = { { 'nvim-telescope/telescope-fzf-native.nvim' } },
    }
    use {
        'nvim-telescope/telescope-fzf-native.nvim',
        run = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release',
        cond = vim.fn.executable('make') == 1
    }
    use({
      'projekt0n/github-nvim-theme',
      config = function()
        vim.cmd('colorscheme github_dark')
      end
    })
    use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
    use { 'williamboman/mason.nvim' }
    use { 'williamboman/mason-lspconfig.nvim', commit = '1a31f82' }
    use { 'neovim/nvim-lspconfig' }

    if PACKER_BOOTSTRAP then
        require("packer").sync()
    end
end)
