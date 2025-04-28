return {
    {
        'Th3Whit3Wolf/space-nvim'
    },
    {
        'navarasu/onedark.nvim',
        priority = 1000,
        opts = {
            style = 'warmer',
            lualine = {
                transparent = true, -- lualine center bar transparency
            },
            transparent = true,
        },
        init = function()
            vim.cmd.colorscheme 'onedark'
            vim.cmd.hi 'Comment gui=none'
        end,
    },
}
