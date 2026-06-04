local snacksRootDirDesc = "Explorer (Root Dir)"
local snacksCwdDesc = "Explorer (cwd)"

local pickerRootDirDesc = "Find Files (Root Dir)"
local pickerCwdDesc = "Find Files (cwd)"

local exploreExclude = { "**/node_modules/**", "**/cdk.out/**" }
local pickerExclude = {
  "**/node_modules/**",
  "**/.next/**",
  "**/.swc/**",
  "**/.idea/**",
  "**/.vscode/**",
  "**/android/**",
  "**/ios/**",
  "**/.expo/**",
  "**/.git/**",
  "**/db_backups/**",
  "**/**_snapshot.json",
  "**/cdk.out/**",
  "**/.jest-cache/**",
  "**/tmp/**",
  "**/dist/**",
  "**/__tests__/**",
  "**/__mocks__/**",
}

return {
  {
    "folke/snacks.nvim",
    ---@type snacks.Config
    opts = {
      picker = {
        sources = {
          explorer = {
            auto_close = true,
            layout = {
              layout = {
                position = "right",
              },
            },
          },
        },
      },
      scratch = {
        win = {
          style = "float",
        },
      },
    },
    keys = {
      {
        "<leader>ba",
        function()
          vim.cmd("%bdelete")
          Snacks.dashboard({ win = 0, buf = 0 })
        end,
        desc = "Delete All Buffers",
      },
      {
        "<leader>fF",
        function()
          Snacks.picker.files({ hidden = true, ignored = true, exclude = pickerExclude })
        end,
        desc = pickerCwdDesc,
      },
      {
        "<leader>ff",
        function()
          Snacks.picker.files({
            cwd = LazyVim.root(),
            hidden = true,
            ignored = true,
            exclude = pickerExclude,
          })
        end,
        desc = pickerRootDirDesc,
      },
      {
        "<leader>fe",
        function()
          Snacks.explorer({
            cwd = LazyVim.root(),
            hidden = true,
            ignored = true,
            exclude = exploreExclude,
          })
        end,
        desc = snacksRootDirDesc,
      },
      {
        "<leader>fE",
        function()
          Snacks.explorer({ hidden = true, ignored = true, exclude = exploreExclude })
        end,
        desc = snacksCwdDesc,
      },
      {
        "<leader>fo",
        function()
          Snacks.explorer({
            cwd = LazyVim.root(),
            hidden = true,
            ignored = true,
            exclude = exploreExclude,
            auto_close = false,
          })
        end,
        desc = snacksRootDirDesc,
      },
      {
        "<leader>fO",
        function()
          Snacks.explorer({ hidden = true, ignored = true, exclude = exploreExclude, auto_close = false })
        end,
        desc = snacksCwdDesc,
      },
      {
        "<leader>f/",
        function()
          Snacks.explorer({ cwd = "/", hidden = true })
        end,
        desc = "Find Files (/)",
      },
      {
        "<leader>fh",
        function()
          Snacks.explorer({ cwd = "~", hidden = true })
        end,
        desc = "Explorer (Home)",
      },
      {
        "<leader>fH",
        function()
          Snacks.picker.files({ cwd = "~", hidden = true })
        end,
        desc = "Find Files (Home)",
      },
      {
        "<leader>fd",
        function()
          Snacks.explorer({ cwd = "~/.dotfiles", hidden = true, ignored = true })
        end,
        desc = "Explorer (.Dotfiles)",
      },
      {
        "<leader>fD",
        function()
          Snacks.picker.files({ cwd = "~/.dotfiles", hidden = true, ignored = true })
        end,
        desc = "Find Files (.Dotfiles)",
      },
      {
        "<leader>fr",
        function()
          Snacks.picker.recent({ filter = { cwd = true }, hidden = true, ignored = true, exclude = pickerExclude })
        end,
        desc = "Recent (cwd)",
        remap = true,
      },
      {
        "<leader>fR",
        function()
          Snacks.picker.recent({
            hidden = true,
            ignored = true,
            exclude = pickerExclude,
          })
        end,
        desc = "Recent",
        remap = true,
      },
      {
        "<leader>//",
        function()
          Snacks.picker.grep({ hidden = true, ignored = true, exclude = pickerExclude })
        end,
        desc = "Grep (cwd)",
      },
      {
        "<leader>/",
        function()
          Snacks.picker.grep({
            cwd = LazyVim.root(),
            hidden = true,
            ignored = true,
            exclude = pickerExclude,
          })
        end,
        desc = "Grep (Root Dir)",
        remap = true,
      },
      {
        "<leader>.",
        function()
          Snacks.scratch.open({
            name = "Scratch",
            ft = "text",
            filekey = {
              id = nil,
              cwd = true,
              branch = false,
              count = true,
            },
          })
        end,
        desc = "Scratch (cwd)",
      },
      {
        "<leader>..",
        function()
          Snacks.scratch.open({
            name = "Global Scratch",
            ft = "text",
            filekey = {
              id = nil,
              cwd = false,
              branch = false,
              count = true,
            },
          })
        end,
        desc = "Scratch (Global)",
      },
      { "<leader><leader>", "<leader>ff", desc = pickerRootDirDesc, remap = true },
      { "<leader>e", "<leader>fe", desc = snacksRootDirDesc, remap = true },
      { "<leader>E", "<leader>fE", desc = snacksCwdDesc, remap = true },
    },
  },
}
