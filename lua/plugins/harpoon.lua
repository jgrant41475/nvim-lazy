return {
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local leader = "<leader>h"
      local harpoon = require("harpoon")

      -- REQUIRED
      harpoon:setup({
        default = {
          create_list_item = function()
            local file_path = vim.fn.expand("%:p") -- Absolute file path
            local line_number = vim.fn.line(".")

            if file_path == "" then
              ---@diagnostic disable-next-line: return-type-mismatch
              return nil
            end

            return {
              value = file_path .. ":" .. line_number,
              context = { file_path = file_path, line_number = line_number },
            }
          end,

          select = function(list_item)
            vim.cmd("edit " .. list_item.context.file_path)

            -- Jump to the line
            vim.api.nvim_win_set_cursor(0, { list_item.context.line_number, 0 })
          end,
        },
      })
      -- REQUIRED

      vim.keymap.set("n", "<leader>a", function()
        harpoon:list():add()
      end, { desc = "Add Current File to Harpoon" })

      vim.keymap.set("n", leader .. "h", function()
        harpoon.ui:toggle_quick_menu(harpoon:list())
      end, { desc = "List Harpoon Files" })

      for i = 1, 4 do
        vim.keymap.set("n", leader .. i, function()
          harpoon:list():select(i)
        end, { desc = "Select Harpoon File (" .. i .. ")" })

        vim.keymap.set("n", leader .. "a" .. i, function()
          harpoon:list():replace_at(i)
        end, { desc = "Set Current File to Harpoon #" .. i })

        vim.keymap.set("n", leader .. "d" .. i, function()
          harpoon:list():remove_at(i)
        end, { desc = "Delete Harpoon File #" .. i })
      end

      vim.keymap.set("n", leader .. "p", function()
        harpoon:list():prev()
      end, { desc = "Select Prev Harpoon File" })
      vim.keymap.set("n", leader .. "n", function()
        harpoon:list():next()
      end, { desc = "Select Next Harpoon File" })

      vim.keymap.set("n", leader .. "dd", function()
        harpoon:list():clear()
      end, { desc = "Clear Harpoon List" })
    end,
  },
}
