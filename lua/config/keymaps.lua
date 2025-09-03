-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

map("i", "<S-Tab>", "<c-\\><c-n><<a", { desc = "Unindent Line" })

--map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Swap Lines (Below)" })
--map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Swap Lines (Above)" })
