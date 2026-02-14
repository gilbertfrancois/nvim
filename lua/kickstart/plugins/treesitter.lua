return {
    {
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        config = function()
            local filetypes = {
                'bash',
                'c',
                'diff',
                'html',
                'lua',
                'luadoc',
                'markdown',
                'markdown_inline',
                'query',
                'vim',
                'vimdoc',
                'python',
            }

            require('nvim-treesitter').install(filetypes)

            vim.api.nvim_create_autocmd('FileType', {
                pattern = filetypes,
                callback = function()
                    vim.treesitter.start()
                end,
            })
        end,
    },
}
-- vim: ts=2 sts=2 sw=2 et
