-- Vitest and Jest adapters for the test.core extra (<leader>t…), with per-suite
-- configs: foo.db.test.ts runs with the nearest <runner>.db.config.*, anything
-- else with <runner>.config.*. Each adapter only claims files in projects whose
-- package.json depends on its runner. A whole-project run (<leader>tT) is a
-- single command, so when the project root has several configs it asks which.

local exts = {
    vitest = { 'mts', 'ts', 'mjs', 'js' },
    jest = { 'ts', 'js', 'mjs', 'cjs', 'json' },
}

-- Config picked for the next whole-project run, { runner =, path = }; consumed
-- by the first directory-level spec that runner's adapter builds.
local project_config

-- Nearest `<prefix><ext>` file for `runner`, searching upward from `path`.
local function find_upward(runner, path, prefix)
    local names = vim.tbl_map(function(e)
        return prefix .. e
    end, exts[runner])
    local dir = vim.fn.isdirectory(path) == 1 and path or vim.fs.dirname(path)
    return vim.fs.find(names, { path = dir, upward = true })[1]
end

local function config_for(runner)
    return function(path)
        if project_config and project_config.runner == runner and vim.fn.isdirectory(path) == 1 then
            local config = project_config.path
            project_config = nil
            return config
        end
        local suite = vim.fs.basename(path):match('%.([%w_-]+)%.test%.[cm]?[jt]sx?$')
        return (suite and find_upward(runner, path, runner .. '.' .. suite .. '.config.'))
            or find_upward(runner, path, runner .. '.config.')
    end
end

-- vitest.db.config.mts -> "vitest", jest.config.json -> "jest", else nil.
local function config_runner(name)
    local runner, ext = name:match('^(%a+)%..*config%.(%a+)$')
    return runner and exts[runner] and vim.list_contains(exts[runner], ext) and runner or nil
end

-- Both adapters register for a project root, and a plain run.run(root) goes to
-- the first one even when it has no tests (e.g. vitest in a jest project), so
-- name the runner's adapter explicitly. The `project_run` consumer below gets
-- at the client, whose get_adapters() starts neotest if needed and only lists
-- adapters that found test files.
local function run_root(root, runner)
    require('neotest').project_run.run(root, runner)
end

local function project_run_consumer(client)
    return {
        run = function(root, runner)
            require('nio').run(function()
                local id
                for _, a in ipairs(client:get_adapters()) do
                    if not runner or vim.startswith(a, 'neotest-' .. runner .. ':') then
                        id = a
                        break
                    end
                end
                vim.schedule(function()
                    require('neotest').run.run(id and { root, adapter = id } or root)
                end)
            end)
        end,
    }
end

local function run_all()
    local root = vim.uv.cwd()
    local configs = {}
    for name, type in vim.fs.dir(root or '') do
        if type == 'file' and config_runner(name) then
            configs[#configs + 1] = name
        end
    end
    if #configs < 2 then
        return run_root(root, configs[1] and config_runner(configs[1]))
    end

    -- Each runner's default <runner>.config.* first, then the suites alphabetically.
    local function is_default(name)
        return name:match('^%a+%.config%.') ~= nil
    end
    table.sort(configs, function(a, b)
        if is_default(a) ~= is_default(b) then
            return is_default(a)
        end
        return a < b
    end)
    vim.ui.select(configs, { prompt = 'Run all tests with config' }, function(choice)
        if choice then
            local runner = config_runner(choice)
            project_config = { runner = runner, path = vim.fs.joinpath(root, choice) }
            run_root(root, runner)
        end
    end)
end

return {
    {
        'nvim-neotest/neotest',
        dependencies = { 'marilari88/neotest-vitest', 'nvim-neotest/neotest-jest' },
        opts = {
            consumers = {
                project_run = project_run_consumer,
            },
            adapters = {
                ['neotest-vitest'] = {
                    vitestConfigFile = config_for('vitest'),
                },
                ['neotest-jest'] = {
                    jestConfigFile = config_for('jest'),
                },
            },
        },
        keys = {
            { '<leader>tT', run_all, desc = 'Run All Test Files (Neotest)' },
        },
    },
}
