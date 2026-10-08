-- Helpers for the dadbod saved-query pickers (<leader>db / <leader>dB) and
-- :DadbodInitProject. Saved queries live under <save_loc>/<connection>/<query>.sql,
-- where the parent directory name is the dadbod connection.

local M = {}

-- The shared/global store, set by the lazyvim sql extra. A project's .lazy.lua may
-- override `vim.g.db_ui_save_location` to a repo-local dir, so this constant is what
-- the *global* picker uses regardless of any per-project override.
local GLOBAL_SAVE = vim.fn.stdpath('data') .. '/dadbod_ui'

-- The currently effective save location: the project-local dir if a .lazy.lua set
-- one, otherwise the global store.
local function save_location()
    local save_loc = vim.g.db_ui_save_location
    if not save_loc or save_loc == '' then
        save_loc = GLOBAL_SAVE
    end
    return vim.fn.expand(save_loc)
end

-- Connection names defined for the *current project* (set per-project via .lazy.lua's vim.g.dbs).
local function project_conn_names()
    local dbs = vim.g.dbs
    local names = {}
    if type(dbs) == 'table' then
        if dbs[1] ~= nil then -- list form: { { name = , url = }, ... }
            for _, d in ipairs(dbs) do
                if d.name then
                    names[#names + 1] = d.name
                end
            end
        else -- dict form: { name = url }
            for k in pairs(dbs) do
                names[#names + 1] = k
            end
        end
    end
    return names
end

local function url_from_dbs(conn_name)
    local dbs = vim.g.dbs
    if type(dbs) ~= 'table' then
        return nil
    end
    if dbs[1] ~= nil then
        for _, d in ipairs(dbs) do
            if d.name == conn_name then
                return d.url
            end
        end
        return nil
    end
    return dbs[conn_name]
end

local function url_from_connections_json(conn_name, save_loc)
    local conn_file = save_loc .. '/connections.json'
    if vim.fn.filereadable(conn_file) == 0 then
        return nil
    end
    local ok, decoded = pcall(vim.fn.json_decode, vim.fn.readfile(conn_file))
    if ok and type(decoded) == 'table' then
        for _, d in ipairs(decoded) do
            if d.name == conn_name then
                return d.url
            end
        end
    end
    return nil
end

-- Resolve a connection's URL. Project queries prefer the project's vim.g.dbs; global
-- queries prefer the store's connections.json, so a global "dev" query doesn't run
-- against whichever project happens to also have a "dev" connection.
local function resolve_url(conn_name, save_loc, project_only)
    if project_only then
        return url_from_dbs(conn_name) or url_from_connections_json(conn_name, save_loc)
    end
    return url_from_connections_json(conn_name, save_loc) or url_from_dbs(conn_name)
end

-- postgres://user:pass@host:5432/db -> postgres://host:5432/db, for the prompt.
local function redact(url)
    return (url:gsub('^(%w[%w+.-]*://)[^@/]*@', '%1'))
end

-- Open the saved-query file picker and execute the chosen query (after confirmation).
-- `project_only` restricts results to the current project's connections.
function M.pick_query(project_only)
    -- Project picker follows the effective (possibly repo-local) location; the global
    -- picker always targets the shared store so a per-project override can't hide it.
    local save_loc = project_only and save_location() or vim.fn.expand(GLOBAL_SAVE)
    if vim.fn.isdirectory(save_loc) == 0 then
        vim.notify('No saved dadbod queries found at ' .. save_loc, vim.log.levels.WARN)
        return
    end

    local picker_opts = {
        confirm = function(picker, item)
            picker:close()
            if not item then
                return
            end
            local file = Snacks.picker.util.path(item)
            local conn_name = vim.fn.fnamemodify(file or '', ':h:t')
            local url = resolve_url(conn_name, save_loc, project_only)
            if not url or url == '' then
                vim.notify(
                    ('No dadbod connection %q found for this query (check vim.g.dbs / connections.json)'):format(
                        conn_name
                    ),
                    vim.log.levels.ERROR
                )
                return
            end

            local prompt = ('Execute %s against %q (%s)?'):format(
                vim.fn.fnamemodify(file or '', ':t'),
                conn_name,
                redact(url)
            )
            if vim.fn.confirm(prompt, '&Yes\n&No', 1) ~= 1 then
                return
            end
            vim.cmd(('DB %s < %s'):format(url, vim.fn.fnameescape(file or '')))
        end,
    }

    if project_only then
        local dirs = {}
        for _, name in ipairs(project_conn_names()) do
            local dir = save_loc .. '/' .. name
            if vim.fn.isdirectory(dir) == 1 then
                dirs[#dirs + 1] = dir
            end
        end
        if #dirs == 0 then
            vim.notify("No saved queries for this project's connections (vim.g.dbs)", vim.log.levels.WARN)
            return
        end
        picker_opts.dirs = dirs
    else
        picker_opts.cwd = save_loc
    end

    Snacks.picker.files(picker_opts)
end

-- Scaffold a project-local dadbod config (vim.g.dbs + repo-local save
-- location) into the cwd from the template. :DadbodInitProject! overwrites.
function M.create_commands()
    vim.api.nvim_create_user_command('DadbodInitProject', function(opts)
        local target = vim.fn.getcwd() .. '/.lazy.lua'
        if vim.fn.filereadable(target) == 1 and not opts.bang then
            vim.notify(
                '.lazy.lua already exists in this directory (use :DadbodInitProject! to overwrite)',
                vim.log.levels.WARN
            )
            return
        end
        local template = vim.fn.stdpath('config') .. '/dadbod.lazy.lua.example'
        if vim.fn.filereadable(template) == 0 then
            vim.notify('Template not found: ' .. template, vim.log.levels.ERROR)
            return
        end
        if vim.fn.writefile(vim.fn.readfile(template), target) ~= 0 then
            vim.notify('Failed to write ' .. target, vim.log.levels.ERROR)
            return
        end
        vim.notify('Created ' .. target .. ' — edit your connections, then restart nvim', vim.log.levels.INFO)
        vim.cmd('edit ' .. vim.fn.fnameescape(target))
    end, { bang = true, desc = 'Scaffold a project-local dadbod .lazy.lua' })
end

return M
