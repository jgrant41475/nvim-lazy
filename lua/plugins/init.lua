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

  -- TMUX Navigator
  {
    "christoomey/vim-tmux-navigator",
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
      "TmuxNavigatePrevious",
      "TmuxNavigatorProcessList",
    },
    keys = {
      { "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>" },
      { "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>" },
      { "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>" },
      { "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>" },
      --{ "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
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
    init = function()
      -- Your DBUI configuration
      vim.g.db_ui_use_nerd_fonts = 1
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
