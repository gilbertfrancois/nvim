return {
    { -- Autoformat
        'stevearc/conform.nvim',
        lazy = false,
        keys = {
            {
                '<leader>ff',
                function()
                    require('conform').format { async = true, lsp_fallback = true }
                end,
                mode = '',
                desc = '[F]ormat buffer',
            },
        },
        opts = {
            format = {
                timeout_ms = 3000,
                async = false, -- not recommended to change
                quiet = false, -- not recommended to change
                lsp_fallback = true, -- not recommended to change
            },
            notify_on_error = false,
            format_on_save = function(bufnr)
                -- Disable "format_on_save lsp_fallback" for languages that don't
                -- have a well standardized coding style. You can add additional
                -- languages here or re-enable it for the disabled ones.
                local disable_filetypes = {}
                return {
                    timeout_ms = 500,
                    lsp_fallback = not disable_filetypes[vim.bo[bufnr].filetype],
                }
            end,
            formatters_by_ft = {
                lua = { 'stylua' },
                python = { 'isort', 'black' },
                c = { 'clang-format' },
                cpp = { 'clang-format' },
                objc = { 'clang-format' },
                fish = { 'fish_indent' },
                sh = { 'shfmt' },
                tex = { 'latexindent' },
                javascript = { { 'prettierd', 'prettier' } },
                typescript = { 'prettier' },
                typescriptreact = { 'prettier' },
                javascriptreact = { 'prettier' },
                html = { 'prettier' },
                css = { 'prettier' },
                json = { 'prettier' },
                yaml = { 'prettier' },
                markdown = { 'prettier' },
                graphql = { 'prettier' },
                -- Conform can also run multiple formatters sequentially
                -- python = { "isort", "black" },
                --
                -- You can use a sub-list to tell conform to run *until* a formatter
                -- is found.
                -- javascript = { { "prettierd", "prettier" } },
            },
        },
    },
}
-- vim: ts=4 sts=4 sw=4 et
