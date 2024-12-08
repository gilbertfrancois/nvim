return {
    {
        'RRethy/base16-nvim',
        -- init = function()
        --     vim.cmd.colorscheme 'base16-onedark'
        -- end,
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
    {
        "rose-pine/neovim",
        name = "rose-pine",
        config = function()
            require('rose-pine').setup({
                disable_background = true,
                styles = {
                    italic = false,
                },
            })
        end
    },
}
