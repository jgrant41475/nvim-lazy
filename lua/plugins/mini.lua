return {
  {
    "nvim-mini/mini.nvim",
    config = function()
      require("mini.surround").setup()

      require("mini.ai").setup()

      require("mini.move").setup()

      require("mini.operators").setup()
    end,
  },
}
