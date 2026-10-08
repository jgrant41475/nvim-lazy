local leader = '<leader>h'

local function list()
    return require('harpoon'):list()
end

local keys = {
    {
        '<leader>H',
        function()
            list():add()
        end,
        desc = 'Add Current File to Harpoon',
    },
    { leader, '', desc = '+harpoon' },
    {
        leader .. 'h',
        function()
            require('harpoon').ui:toggle_quick_menu(list())
        end,
        desc = 'List Harpoon Files',
    },
    {
        leader .. 'p',
        function()
            list():prev()
        end,
        desc = 'Select Prev Harpoon File',
    },
    {
        leader .. 'n',
        function()
            list():next()
        end,
        desc = 'Select Next Harpoon File',
    },
    {
        leader .. 'dd',
        function()
            list():clear()
        end,
        desc = 'Clear Harpoon List',
    },
}
for i = 1, 5 do
    vim.list_extend(keys, {
        {
            leader .. i,
            function()
                list():select(i)
            end,
            desc = 'Select Harpoon File (' .. i .. ')',
        },
        {
            leader .. 'a' .. i,
            function()
                list():replace_at(i)
            end,
            desc = 'Set Current File to Harpoon #' .. i,
        },
        {
            leader .. 'd' .. i,
            function()
                list():remove_at(i)
            end,
            desc = 'Delete Harpoon File #' .. i,
        },
    })
end

return {
    {
        'ThePrimeagen/harpoon',
        branch = 'harpoon2',
        dependencies = { 'nvim-lua/plenary.nvim' },
        keys = keys,
        config = function()
            require('harpoon'):setup({
                default = {
                    -- `name` is set when a line is typed into the quick menu ("path" or
                    -- "path:123"); otherwise the item is the current buffer and line.
                    create_list_item = function(_, name)
                        local file_path, line_number
                        if name then
                            file_path, line_number = name:match('^(.-):(%d+)$')
                            file_path = vim.fn.fnamemodify(file_path or name, ':p')
                            line_number = tonumber(line_number) or 1
                        else
                            file_path = vim.fn.expand('%:p') -- Absolute file path
                            line_number = vim.fn.line('.')
                        end

                        if file_path == '' then
                            ---@diagnostic disable-next-line: return-type-mismatch
                            return nil
                        end

                        return {
                            value = file_path .. ':' .. line_number,
                            context = { file_path = file_path, line_number = line_number },
                        }
                    end,

                    -- One entry per file: re-adding a file is a no-op (use <leader>ha<n>
                    -- to update a slot's line).
                    equals = function(a, b)
                        if a == nil or b == nil then
                            return a == b
                        end
                        return a.context.file_path == b.context.file_path
                    end,

                    select = function(list_item)
                        vim.cmd('edit ' .. vim.fn.fnameescape(list_item.context.file_path))

                        -- Jump to the line, clamped to the buffer's current size.
                        local line = list_item.context.line_number or 1
                        local last = vim.api.nvim_buf_line_count(0)
                        if line < 1 then
                            line = 1
                        end
                        if line > last then
                            line = last
                        end
                        vim.api.nvim_win_set_cursor(0, { line, 0 })
                    end,
                },
            })
        end,
    },
}
