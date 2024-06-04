-- debug.lua
--
-- Shows how to use the DAP plugin to debug your code.
--
-- Primarily focused on configuring the debugger for Go, but can
-- be extended to other languages as well. That's why it's called
-- kickstart.nvim and not kitchen-sink.nvim ;)

return {
    -- NOTE: Yes, you can install new plugins here!
    'mfussenegger/nvim-dap',
    -- NOTE: And you can specify dependencies as well
    dependencies = {
        -- Creates a beautiful debugger UI
        'rcarriga/nvim-dap-ui',
        -- Required dependency for nvim-dap-ui
        'nvim-neotest/nvim-nio',

        -- Installs the debug adapters for you
        'williamboman/mason.nvim',
        'jay-babu/mason-nvim-dap.nvim',

        -- Add your own debuggers here
        -- 'leoluz/nvim-dap-go',
        'mfussenegger/nvim-dap-python',
        'theHamsta/nvim-dap-virtual-text',
    },
    config = function()
        local dap = require 'dap'
        local dapui = require 'dapui'
        local debugpy_path = require('mason-registry').get_package('debugpy'):get_install_path()

        require('mason-nvim-dap').setup {
            -- Makes a best effort to setup the various debuggers with
            -- reasonable debug configurations
            automatic_installation = true,

            -- You can provide additional configuration to the handlers,
            -- see mason-nvim-dap README for more information
            handlers = {},

            -- You'll need to check that you have the required things installed
            -- online, please don't ask me how to install them :)
            ensure_installed = {
                -- Update this to ensure that you have the debuggers for the langs you want
                'debugpy',
                'codelldb',
            },
        }
        require('dap-python').setup(debugpy_path .. '/venv/bin/python')
        table.insert(dap.configurations.python, {
            justMyCode = false,
        })

        -- Basic debugging keymaps, feel free to change to your liking!
        vim.keymap.set('n', '<F1>', dap.continue, { desc = 'Debug: Start/Continue' })
        vim.keymap.set('n', '<F6>', dap.terminate, { desc = 'Debug: Stop' })
        vim.keymap.set('n', '<F2>', dap.step_into, { desc = 'Debug: Step into' })
        vim.keymap.set('n', '<F3>', dap.step_over, { desc = 'Debug: Step over' })
        vim.keymap.set('n', '<F4>', dap.step_out, { desc = 'Debug: Step out' })
        vim.keymap.set('n', '<F5>', dap.step_back, { desc = 'Debug: Step back' })
        vim.keymap.set('n', '<F7>', dapui.toggle, { desc = 'Debug: See last session result.' })
        -- vim.keymap.set('n', '<F10>', dap.run_last, { desc = 'Debug: Run last' })
        vim.keymap.set('n', '<leader>b', dap.toggle_breakpoint, { desc = 'Debug: Toggle breakpoint' })
        vim.keymap.set('n', '<leader>B', function()
            dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
        end, { desc = 'Debug: Set Breakpoint' })

        -- Dap UI setup
        -- For more information, see |:help nvim-dap-ui|
        dapui.setup {
            -- icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
        }

        -- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.

        dap.listeners.before.attach.dapui_config = dapui.open
        dap.listeners.before.launch.dapui_config = dapui.open
        dap.listeners.before.event_terminated.dapui_config = dapui.close
        dap.listeners.before.event_exited.dapui_config = dapui.close

        -- dap.listeners.after.event_initialized.dapui_config = dapui.open

        require('nvim-dap-virtual-text').setup {}

        dap.adapters.codelldb = {
            type = 'server',
            port = '13000',
            -- executable = {
            -- 	command = vim.fn.getenv("HOME") .. "/.local/share/nvim/mason/packages/codelldb/extension/adapter/codelldb",
            -- 	args = { "--port", "13000" },
            -- 	-- On windows you may have to uncomment this:
            -- 	-- detached = false,
            -- },
        }

        dap.configurations.cpp = {
            {
                name = 'Launch',
                type = 'codelldb',
                request = 'launch',
                program = function()
                    return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
                end,
                cwd = '${workspaceFolder}',
                stopOnEntry = false,
                args = {},
            },
        }
        dap.configurations.c = dap.configurations.cpp
    end,
}
