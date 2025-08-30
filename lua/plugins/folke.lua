local snacksRootDirDesc = "Explorer Snacks (Root Dir)"
local snacksCwdDesc = "Explorer Snacks (cwd)"

local pickerRootDirDesc = "Find Files (Root Dir)"
local pickerCwdDesc = "Find Files (cwd)"

local exploreExclude = { "**/node_modules/**" }
local pickerExclude =
  { "**/node_modules/**", "**/.next/**", "**/.idea/**", "**/.vscode/**", "**/android/**", "**/ios/**", "**/.expo/**" }

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
    },
    keys = {
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
          Snacks.picker.files({ cwd = LazyVim.root(), hidden = true, ignored = true, exclude = pickerExclude })
        end,
        desc = pickerRootDirDesc,
      },
      {
        "<leader>fe",
        function()
          Snacks.explorer({ cwd = LazyVim.root(), exclude = exploreExclude })
        end,
        desc = snacksRootDirDesc,
      },
      {
        "<leader>fE",
        function()
          Snacks.explorer({ exclude = exploreExclude })
        end,
        desc = snacksCwdDesc,
      },
      {
        "<leader>f/",
        function()
          Snacks.explorer({ cwd = "/" })
        end,
        desc = "Find Files (/)",
      },
      { "<leader><leader>", "<leader>ff", desc = pickerRootDirDesc, remap = true },
      { "<leader>e", "<leader>fe", desc = snacksRootDirDesc, remap = true },
      { "<leader>E", "<leader>fE", desc = snacksCwdDesc, remap = true },
    },
  },
}
