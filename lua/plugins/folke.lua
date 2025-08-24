local snacksRootDirDesc = "Explorer Snacks (Root Dir)"
local snacksCwdDesc = "Explorer Snacks (cwd)"

local pickerCwdDesc = "Find Files (cwd)"

local exploreExclude = { "**/node_modules/**" }
local pickerExclude = { "**/node_modules/**", "**/.next/**", "**/.idea/**", "**/.vscode/**" }

return {
  {
    "folke/snacks.nvim",
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
          Snacks.picker.files({ cwd = LazyVim.root(), hidden = true, ignored = true, exclude = pickerExclude })
        end,
        desc = "Find Files (Root Dir)",
      },
      {
        "<leader>ff",
        function()
          Snacks.picker.files({ hidden = true, ignored = true, exclude = pickerExclude })
        end,
        desc = pickerCwdDesc,
      },
      {
        "<leader>fe",
        function()
          Snacks.explorer({ exclude = exploreExclude })
        end,
        desc = snacksCwdDesc,
      },
      {
        "<leader>fE",
        function()
          Snacks.explorer({ cwd = LazyVim.root(), exclude = exploreExclude })
        end,
        desc = snacksRootDirDesc,
      },
      { "<leader><leader>", "<leader>ff", desc = pickerCwdDesc, remap = true },
      { "<leader>e", "<leader>fe", desc = snacksCwdDesc, remap = true },
      { "<leader>E", "<leader>fE", desc = snacksRootDirDesc, remap = true },
    },
  },
}
