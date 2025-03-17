return {
    'mfussenegger/nvim-dap',
    dependencies = {
        -- Creates a beautiful debugger UI
        'rcarriga/nvim-dap-ui',
        -- Required dependency for nvim-dap-ui
        'nvim-neotest/nvim-nio',
        'theHamsta/nvim-dap-virtual-text',
        -- Installs the debug adapters for you
        'williamboman/mason.nvim',
        'jay-babu/mason-nvim-dap.nvim',

        -- Language specific debuggers
        -- Add your own debuggers here
        'mfussenegger/nvim-dap-python',
    },
    config = function()
        local dap = require 'dap'
        local dapui = require 'dapui'

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

        -- Basic debugging keymaps, feel free to change to your liking!
        vim.keymap.set('n', '<F1>', dap.continue, { desc = 'Debug: Start/Continue' })
        vim.keymap.set('n', '<F2>', dap.step_into, { desc = 'Debug: Step into' })
        vim.keymap.set('n', '<F3>', dap.step_over, { desc = 'Debug: Step over' })
        vim.keymap.set('n', '<F4>', dap.step_out, { desc = 'Debug: Step out' })
        vim.keymap.set('n', '<F5>', dap.step_back, { desc = 'Debug: Step back' })
        vim.keymap.set('n', '<F6>', dap.terminate, { desc = 'Debug: Stop' })
        vim.keymap.set('n', '<F7>', dapui.toggle, { desc = 'Debug: See last session result.' })
        -- vim.keymap.set('n', '<F10>', dap.run_last, { desc = 'Debug: Run last' })
        vim.keymap.set('n', '<leader>b', dap.toggle_breakpoint, { desc = 'Debug: Toggle breakpoint' })
        vim.keymap.set('n', '<leader>B', function()
            dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
        end, { desc = 'Debug: Set Breakpoint' })
        vim.keymap.set('n', '<leader>?', function()
            dapui.eval(nil, { enter = true })
        end, { desc = 'Debug: Evaluate expression' })

        dap.listeners.before.attach.dapui_config = dapui.open
        dap.listeners.before.launch.dapui_config = dapui.open
        dap.listeners.before.event_terminated.dapui_config = dapui.close
        dap.listeners.before.event_exited.dapui_config = dapui.close
        -- dap.listeners.after.event_initialized.dapui_config = dapui.open

        -- Virtual text setup
        require('nvim-dap-virtual-text').setup {}

        -- Dap UI setup
        -- For more information, see |:help nvim-dap-ui|
        dapui.setup {
            {
                controls = {
                    element = 'repl',
                    enabled = true,
                    icons = {
                        disconnect = '',
                        pause = '',
                        play = '',
                        run_last = '',
                        step_back = '',
                        step_into = '',
                        step_out = '',
                        step_over = '',
                        terminate = '',
                    },
                },
                element_mappings = {},
                expand_lines = true,
                floating = {
                    border = 'single',
                    mappings = {
                        close = { 'q', '<Esc>' },
                    },
                },
                force_buffers = true,
                icons = {
                    collapsed = '',
                    current_frame = '',
                    expanded = '',
                },
                layouts = {
                    {
                        elements = {
                            {
                                id = 'scopes',
                                size = 0.25,
                            },
                            {
                                id = 'breakpoints',
                                size = 0.25,
                            },
                            {
                                id = 'stacks',
                                size = 0.25,
                            },
                            {
                                id = 'watches',
                                size = 0.25,
                            },
                        },
                        position = 'left',
                        size = 40,
                    },
                    {
                        elements = {
                            {
                                id = 'repl',
                                size = 0.5,
                            },
                            {
                                id = 'console',
                                size = 0.5,
                            },
                        },
                        position = 'bottom',
                        size = 10,
                    },
                },
                mappings = {
                    edit = 'e',
                    expand = { '<CR>', '<2-LeftMouse>' },
                    open = 'o',
                    remove = 'd',
                    repl = 'r',
                    toggle = 't',
                },
                render = {
                    indent = 1,
                    max_value_lines = 100,
                },
            },
        }
        -- Python debugging setup
        local debugpy_path = require('mason-registry').get_package('debugpy'):get_install_path()
        require('dap-python').setup(debugpy_path .. '/venv/bin/python')
        dap.adapters.python = {
            type = 'server',
            host = 'localhost',
            port = 5678,
            options = {
                source_filetype = 'python',
            },
        }
        dap.configurations.python = {
            {
                type = 'python',
                request = 'attach',
                connect = {
                    host = 'localhost',
                    port = 5678,
                },
                mode = 'remote',
                name = 'Attach to Docker python /ava-x/genesis/components',
                redirectOutput = true,
                justMyCode = true,
                pathMappings = {
                    {
                        localRoot = '/home/gilbert/ava-x/genesis/components/',
                        remoteRoot = '/ava-x/genesis/components',
                    },
                },
            },
            {
                type = 'python',
                request = 'attach',
                connect = {
                    host = 'localhost',
                    port = 5678,
                },
                mode = 'remote',
                name = 'Attach to Docker python /app',
                redirectOutput = true,
                justMyCode = true,
                pathMappings = {
                    {
                        localRoot = vim.fn.getcwd(),
                        remoteRoot = '/app',
                    },
                },
            },
        }

        -- C++ debugging setup
        local codelldb_path = require('mason-registry').get_package('codelldb'):get_install_path()

        dap.adapters.codelldb = {
            type = 'server',
            port = '13000',
            executable = {
                command = codelldb_path .. '/codelldb',
                args = { '--port', '13000' },
            },
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
