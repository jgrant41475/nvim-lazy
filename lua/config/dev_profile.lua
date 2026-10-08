-- Project databases from the dev profile (dev-profiles.yaml, `databases:`), so a
-- project's connections are defined once for nvim dadbod, lazysql and the db
-- restore UI. Sets vim.g.dbs and points saved queries at <profile path>/.dadbod.
--
-- Profile: $DEV_PROFILE (exported into every `dev` tmux session), else the
-- profile whose `path` contains nvim's cwd — the same rule as the `project` CLI
-- (~/.dotfiles/tools/packages/projects). A project's .lazy.lua still wins: it is loaded
-- later by lazy.nvim and may set either variable itself.
--
-- Runs yq asynchronously: dadbod loads on demand, long after this has landed.

local M = {}

-- Each profile reduced to what we need, with `databases` (an ordered YAML map)
-- turned into a list so the order survives JSON decoding.
local QUERY = [[with_entries(.value |= {
  "path": .path,
  "aliases": (.aliases // []),
  "dbs": ((.databases // {}) | to_entries | map({"name": (.value.name // .key), "url": .value.url}))
})]]

local function expand(p)
  return (p:gsub("^~", vim.env.HOME))
end

local function pick(profiles)
  local wanted = vim.env.DEV_PROFILE
  if wanted and wanted ~= "" then
    for name, p in pairs(profiles) do
      if name == wanted or vim.tbl_contains(p.aliases or {}, wanted) then
        return p
      end
    end
    return nil
  end
  local cwd = vim.fs.normalize(vim.uv.cwd() or "")
  local best, best_len = nil, 0
  for _, p in pairs(profiles) do
    if type(p.path) == "string" then
      local dir = vim.fs.normalize(expand(p.path))
      if (cwd == dir or vim.startswith(cwd, dir .. "/")) and #dir > best_len then
        best, best_len = p, #dir
      end
    end
  end
  return best
end

function M.load()
  local file = expand(vim.env.DEV_PROFILES or "~/dev-profiles.yaml")
  if vim.fn.executable("yq") == 0 or vim.fn.filereadable(file) == 0 then
    return
  end
  vim.system({ "yq", "-o", "json", "-I0", QUERY, file }, { text = true }, function(res)
    if res.code ~= 0 then
      return
    end
    vim.schedule(function()
      local ok, profiles = pcall(vim.json.decode, res.stdout)
      local p = ok and type(profiles) == "table" and pick(profiles) or nil
      if not p or #p.dbs == 0 then
        return
      end
      -- Don't override a project's .lazy.lua if it already set these. The
      -- LazyVim sql extra's init sets the save location to its global store at
      -- startup, so that value counts as unset.
      if vim.g.dbs == nil then
        vim.g.dbs = p.dbs
      end
      local save = vim.g.db_ui_save_location
      if save == nil or save == "" or save == vim.fn.stdpath("data") .. "/dadbod_ui" then
        vim.g.db_ui_save_location = vim.fs.normalize(expand(p.path)) .. "/.dadbod"
      end
    end)
  end)
end

return M
