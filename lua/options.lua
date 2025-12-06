-- [[ Setting options ]]
-- See `:help vim.opt`
-- NOTE: You can change these options as you wish!
--  For more options, you can see `:help option-list`
--
vim.o.termguicolors = true

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
-- Make line numbers default
vim.opt.number = true
-- You can also add relative line numbers, to help with jumping.
--  Experiment for yourself to see if you like it!
-- vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

-- Enable mouse mode, can be useful for resizing splits for example!
vim.opt.mouse = 'a'

-- vim.o.winborder = 'rounded'

vim.opt.conceallevel = 0
-- Enable global statusbar
vim.o.laststatus = 3

-- Set to true if you have a Nerd Font installed
vim.g.have_nerd_font = true

-- Make line numbers default
vim.opt.number = true
-- You can also add relative line numbers, to help with jumping.
--  Experiment for yourself to see if you like it!
-- vim.opt.relativenumber = true

-- Don't show the mode, since it's already in the status line
vim.opt.showmode = false

-- Begin clipboard config
--
local osc = require 'vim.ui.clipboard.osc52'
local uname = vim.loop.os_uname()
local os_name = uname.sysname

-- Check if we're running inside an SSH session
local is_ssh = os.getenv 'SSH_TTY' ~= nil or os.getenv 'SSH_CONNECTION' ~= nil

local clipboard = {
    name = 'osc52+system',
    copy = { ['+'] = osc.copy '+', ['*'] = osc.copy '*' },
    paste = { ['+'] = osc.paste '+', ['*'] = osc.paste '*' },
    cache_enabled = 0,
}

-- If not SSH (i.e., local session), use system-specific tools for paste (more reliable)
if not is_ssh then
    if os_name == 'Darwin' then
        -- clipboard.copy['+'] = { 'pbcopy' }
        -- clipboard.copy['*'] = { 'pbcopy' }
        clipboard.paste['+'] = { 'pbpaste' }
        clipboard.paste['*'] = { 'pbpaste' }
    elseif os_name == 'Linux' then
        local has_wayland = os.getenv 'WAYLAND_DISPLAY' ~= nil
        if has_wayland then
            -- clipboard.copy['+'] = { 'wl-copy' }
            -- clipboard.copy['*'] = { 'wl-copy', '--primary' }
            clipboard.paste['+'] = { 'wl-paste', '--no-newline' }
            clipboard.paste['*'] = { 'wl-paste', '--no-newline', '--primary' }
        else
            -- clipboard.copy['+'] = { 'xclip', '-selection', 'clipboard' }
            -- clipboard.copy['*'] = { 'xclip', '-selection', 'primary' }
            clipboard.paste['+'] = { 'xclip', '-selection', 'clipboard', '-out' }
            clipboard.paste['*'] = { 'xclip', '-selection', 'primary', '-out' }
        end
    end
end

vim.g.clipboard = clipboard
vim.opt.clipboard:append { 'unnamed', 'unnamedplus' }
--
-- end clipboard config

-- Enable break indent
vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = 'yes'

-- Decrease update time
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
vim.opt.inccommand = 'split'

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10

-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s)
-- See `:help 'confirm'`
vim.opt.confirm = true

vim.env.PATH = vim.fn.expand '$HOME/.local/share/nvim/lib/node/bin' .. ':' .. vim.env.PATH
vim.g.python3_host_prog = vim.fn.getenv 'HOME' .. '/.local/share/nvim/lib/python/bin/python3'
vim.g.node_host_prog = vim.fn.getenv 'HOME' .. '/.local/share/nvim/lib/node/bin/neovim-node-host'

-- vim: ts=2 sts=2 sw=2 et
