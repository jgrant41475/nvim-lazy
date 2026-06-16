-- Helpers for the dadbod saved-query pickers (<leader>db / <leader>dB).
-- Saved queries live under <save_loc>/<connection>/<query>.sql, where the parent
-- directory name is the dadbod connection.

-- The shared/global store, set by the lazyvim sql extra. A project's .lazy.lua may
-- override `vim.g.db_ui_save_location` to a repo-local dir, so this constant is what
-- the *global* picker uses regardless of any per-project override.
local DADBOD_GLOBAL_SAVE = vim.fn.stdpath("data") .. "/dadbod_ui"

-- The currently effective save location: the project-local dir if a .lazy.lua set
-- one, otherwise the global store.
local function dadbod_save_location()
  local save_loc = vim.g.db_ui_save_location
  if not save_loc or save_loc == "" then
    save_loc = DADBOD_GLOBAL_SAVE
  end
  return vim.fn.expand(save_loc)
end

-- Connection names defined for the *current project* (set per-project via .lazy.lua's vim.g.dbs).
local function project_conn_names()
  local dbs = vim.g.dbs
  local names = {}
  if type(dbs) == "table" then
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

-- Resolve a connection's URL from the project's vim.g.dbs or DBUIAddConnection's connections.json.
local function dadbod_resolve_url(conn_name, save_loc)
  local dbs = vim.g.dbs
  if type(dbs) == "table" then
    if dbs[1] ~= nil then
      for _, d in ipairs(dbs) do
        if d.name == conn_name then
          return d.url
        end
      end
    elseif dbs[conn_name] then
      return dbs[conn_name]
    end
  end
  local conn_file = save_loc .. "/connections.json"
  if vim.fn.filereadable(conn_file) == 1 then
    local ok, decoded = pcall(vim.fn.json_decode, vim.fn.readfile(conn_file))
    if ok and type(decoded) == "table" then
      for _, d in ipairs(decoded) do
        if d.name == conn_name then
          return d.url
        end
      end
    end
  end
  return nil
end

-- Open the saved-query file picker and execute the chosen query (after confirmation).
-- `project_only` restricts results to the current project's connections.
local function dadbod_pick_query(project_only)
  -- Project picker follows the effective (possibly repo-local) location; the global
  -- picker always targets the shared store so a per-project override can't hide it.
  local save_loc = project_only and dadbod_save_location() or vim.fn.expand(DADBOD_GLOBAL_SAVE)
  if vim.fn.isdirectory(save_loc) == 0 then
    vim.notify("No saved dadbod queries found at " .. save_loc, vim.log.levels.WARN)
    return
  end

  local picker_opts = {
    confirm = function(picker, item)
      picker:close()
      if not item then
        return
      end
      local file = item._path or (item.cwd and (item.cwd .. "/" .. item.file)) or item.file
      local conn_name = vim.fn.fnamemodify(file, ":h:t")
      local url = dadbod_resolve_url(conn_name, save_loc)

      local prompt = ("Execute %s against %q?"):format(vim.fn.fnamemodify(file, ":t"), conn_name)
      if vim.fn.confirm(prompt, "&Yes\n&No", 1) ~= 1 then
        return
      end

      if url and url ~= "" then
        vim.cmd(("DB %s < %s"):format(url, vim.fn.fnameescape(file)))
      else
        vim.notify(
          ("No dadbod connection %q found for this query (check vim.g.dbs / connections.json)"):format(conn_name),
          vim.log.levels.ERROR
        )
      end
    end,
  }

  if project_only then
    local dirs = {}
    for _, name in ipairs(project_conn_names()) do
      local dir = save_loc .. "/" .. name
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

return {
  { "ThePrimeagen/vim-be-good" },
  { "tpope/vim-sleuth" },

  -- LazyDev (Lua plugin typedefs)
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        "~/.local/share/nvim-lazy/lazy/", -- Path to your lazy.nvim plugins
      },
    },
  },

  -- AutoSession
  {
    "rmagatti/auto-session",
    lazy = false,

    ---enables autocomplete for opts
    ---@module "auto-session"
    ---@type AutoSession.Config
    opts = {
      suppressed_dirs = { "~/", "~/Projects", "~/Downloads", "/" },
      -- log_level = 'debug',
    },
  },

  {
    "numToStr/Navigator.nvim",
    lazy = false,
    config = function()
      require("Navigator").setup({})
    end,
    cmd = {
      "NavigatorLeft",
      "NavigatorRight",
      "NavigatorUp",
      "NavigatorDown",
      "NavigatorPrevious",
    },
    keys = {
      { "<c-h>", "<CMD>NavigatorLeft<CR>" },
      { "<c-l>", "<CMD>NavigatorRight<CR>" },
      { "<c-k>", "<CMD>NavigatorUp<CR>" },
      { "<c-j>", "<CMD>NavigatorDown<CR>" },
      { "<c-\\>", "<CMD>NavigatorPrevious<CR>" },
    },
  },

  -- lazydocker.nvim
  {
    "mgierada/lazydocker.nvim",
    dependencies = { "akinsho/toggleterm.nvim" },
    config = function()
      require("lazydocker").setup({
        border = "curved", -- valid options are "single" | "double" | "shadow" | "curved"
      })
    end,
    event = "BufRead",
    keys = {
      {
        "<leader>dd",
        function()
          require("lazydocker").open()
        end,
        desc = "Open Lazydocker floating window",
      },
    },
  },

  -- Dadbob UI
  {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = {
      { "tpope/vim-dadbod", lazy = true },
      { "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" }, lazy = true }, -- Optional
    },
    cmd = {
      "DBUI",
      "DBUIToggle",
      "DBUIAddConnection",
      "DBUIFindBuffer",
    },
    keys = {
      {
        "<leader>db",
        function()
          dadbod_pick_query(true)
        end,
        desc = "Run saved DB query (project)",
      },
      {
        "<leader>dB",
        function()
          dadbod_pick_query(false)
        end,
        desc = "Run saved DB query (all)",
      },
    },
    init = function()
      -- Your DBUI configuration
      vim.g.db_ui_use_nerd_fonts = 1

      -- Scaffold a project-local dadbod config (vim.g.dbs + repo-local save
      -- location) into the cwd from the template. :DadbodInitProject! overwrites.
      vim.api.nvim_create_user_command("DadbodInitProject", function(opts)
        local target = vim.fn.getcwd() .. "/.lazy.lua"
        if vim.fn.filereadable(target) == 1 and not opts.bang then
          vim.notify(
            ".lazy.lua already exists in this directory (use :DadbodInitProject! to overwrite)",
            vim.log.levels.WARN
          )
          return
        end
        local template = vim.fn.stdpath("config") .. "/dadbod.lazy.lua.example"
        if vim.fn.filereadable(template) == 0 then
          vim.notify("Template not found: " .. template, vim.log.levels.ERROR)
          return
        end
        if vim.fn.writefile(vim.fn.readfile(template), target) ~= 0 then
          vim.notify("Failed to write " .. target, vim.log.levels.ERROR)
          return
        end
        vim.notify("Created " .. target .. " — edit your connections, then restart nvim", vim.log.levels.INFO)
        vim.cmd("edit " .. vim.fn.fnameescape(target))
      end, { bang = true, desc = "Scaffold a project-local dadbod .lazy.lua" })
    end,
  },

  -- NVIM Treesitter Context - Keep context lines at top
  {
    "nvim-treesitter/nvim-treesitter-context",
    opts = {
      multiline_threshold = 1,
    },
  },

  -- NPM Version Info
  {
    "vuki656/package-info.nvim",
    dependencies = {
      "MunifTanjim/nui.nvim",
    },
    ft = { "json" },
    opts = {
      colors = {
        up_to_date = "#3C4048",
        outdated = "#d19a66",
        invalid = "#ee4b2b",
      },
    },
    config = function(_, opts)
      require("package-info").setup(opts)

      -- manually register them
      vim.cmd([[highlight PackageInfoUpToDateVersion guifg=]] .. opts.colors.up_to_date)
      vim.cmd([[highlight PackageInfoOutdatedVersion guifg=]] .. opts.colors.outdated)
    end,
    keys = {
      {
        "<leader>ps",
        function()
          require("package-info").toggle()
        end,
        desc = "Toggle dependency versions",
      },
    },
  },
}
