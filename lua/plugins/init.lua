-- smart-splits, but from a float anchored to a split (the pinned snacks
-- explorer's list/input sit on its sidebar split), move as if from that split.
-- smart-splits judges a float's screen edge by its anchor-relative col (0 for
-- the explorer), so it sends <c-h> out to tmux (which wraps right) and <c-l>
-- back into the editor.
local function smart_move(dir)
    local cur = vim.api.nvim_get_current_win()
    local anchor = cur
    local cfg = vim.api.nvim_win_get_config(anchor)
    while cfg.relative == 'win' and cfg.win do
        anchor = cfg.win
        cfg = vim.api.nvim_win_get_config(anchor)
    end
    local from_float = anchor ~= cur and cfg.relative == ''
    if from_float then
        vim.cmd('noautocmd call nvim_set_current_win(' .. anchor .. ')')
    end
    require('smart-splits')['move_cursor_' .. dir]()
    -- Still on the anchor: the move went to a tmux pane (or nowhere), so put the
    -- cursor back in the float for when focus returns.
    if from_float and vim.api.nvim_get_current_win() == anchor then
        vim.cmd('noautocmd call nvim_set_current_win(' .. cur .. ')')
    end
end

return {
    { 'ThePrimeagen/vim-be-good', cmd = 'VimBeGood' },
    { 'tpope/vim-sleuth' },

    -- AutoSession (LazyVim's persistence.nvim is disabled so the two don't both
    -- save sessions)
    {
        'rmagatti/auto-session',
        lazy = false,

        ---enables autocomplete for opts
        ---@module "auto-session"
        ---@type AutoSession.Config
        opts = {
            suppressed_dirs = { '~/', '~/Projects', '~/Downloads', '/' },
            -- log_level = 'debug',

            -- The startup restore runs inside VimEnter, after something has already
            -- fired FileType there, so did_filetype() is set and filetype detection's
            -- :setf is a no-op for the buffers the session opens: they come back with
            -- no filetype, treesitter or LSP. Setting 'filetype' directly isn't guarded.
            post_restore_cmds = {
                function()
                    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                        if
                            vim.api.nvim_buf_is_loaded(buf)
                            and vim.bo[buf].buftype == ''
                            and vim.bo[buf].filetype == ''
                        then
                            local ft = vim.filetype.match({ buf = buf })
                            if ft then
                                vim.bo[buf].filetype = ft
                            end
                        end
                    end
                end,
            },
        },
    },
    { 'folke/persistence.nvim', enabled = false },

    -- Window navigation that continues into tmux panes at the edge (tmux side:
    -- vim-tmux-navigator in .tmux.conf). Not lazy-loaded: smart-splits marks the
    -- pane as running nvim on startup.
    {
        'mrjones2014/smart-splits.nvim',
        lazy = false,
        opts = {},
        keys = {
            {
                '<c-h>',
                function()
                    smart_move('left')
                end,
                desc = 'Go to Left Window',
            },
            {
                '<c-j>',
                function()
                    smart_move('down')
                end,
                desc = 'Go to Lower Window',
            },
            {
                '<c-k>',
                function()
                    smart_move('up')
                end,
                desc = 'Go to Upper Window',
            },
            {
                '<c-l>',
                function()
                    smart_move('right')
                end,
                desc = 'Go to Right Window',
            },
            {
                '<c-\\>',
                function()
                    require('smart-splits').move_cursor_previous()
                end,
                desc = 'Go to Previous Window',
            },
        },
    },

    {
        'folke/snacks.nvim',
        keys = {
            {
                '<leader>dd',
                function()
                    Snacks.terminal('lazydocker', { win = { border = 'rounded' } })
                end,
                desc = 'Lazydocker',
            },
        },
    },

    -- Dadbod UI (installed and configured by the lazyvim sql extra; these are
    -- just the saved-query pickers from config/dadbod.lua)
    {
        'kristijanhusak/vim-dadbod-ui',
        keys = {
            {
                '<leader>db',
                function()
                    require('config.dadbod').pick_query(true)
                end,
                desc = 'Run saved DB query (project)',
            },
            {
                '<leader>dB',
                function()
                    require('config.dadbod').pick_query(false)
                end,
                desc = 'Run saved DB query (all)',
            },
        },
    },

    -- NVIM Treesitter Context - Keep context lines at top
    {
        'nvim-treesitter/nvim-treesitter-context',
        opts = {
            multiline_threshold = 1,
        },
    },

    -- NPM Version Info
    {
        'vuki656/package-info.nvim',
        dependencies = {
            'MunifTanjim/nui.nvim',
        },
        ft = { 'json' },
        opts = {
            colors = {
                up_to_date = '#3C4048',
                outdated = '#d19a66',
                invalid = '#ee4b2b',
            },
        },
        config = function(_, opts)
            require('package-info').setup(opts)

            -- manually register them
            vim.cmd([[highlight PackageInfoUpToDateVersion guifg=]] .. opts.colors.up_to_date)
            vim.cmd([[highlight PackageInfoOutdatedVersion guifg=]] .. opts.colors.outdated)
        end,
        keys = {
            {
                '<leader>ps',
                function()
                    require('package-info').toggle()
                end,
                desc = 'Toggle dependency versions',
            },
        },
    },
}
