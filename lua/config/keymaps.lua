-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("n", "<leader>td", ':lua require("dbee").toggle()<cr>', { desc = "Toggle the database viewer" })
vim.keymap.set("t", "<esc><esc>", "<c-\\><c->", { desc = "Exit Terminal Mode" })
