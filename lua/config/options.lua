-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.o.tabstop = 4 -- A TAB character looks like 4 spaces
vim.o.expandtab = true -- Pressing the TAB key will insert spaces instead of a TAB character
vim.o.softtabstop = 4 -- Number of spaces inserted instead of a TAB character
vim.o.shiftwidth = 4 -- Number of spaces inserted when indenting

-- Neovim 0.12 enables synchronized output (DEC private mode 2026, 'termsync') by
-- default. Inside tmux (3.7a) the deferred flush is mishandled: nvim's frames are
-- held and the pane stays black until an unrelated redraw (switching tmux panes)
-- forces a repaint. Disable termsync so nvim renders without the 2026 wrapper.
-- Guarded so it's a harmless no-op on Neovim < 0.12, where the option is absent.
if vim.fn.exists("+termsync") == 1 then
  vim.o.termsync = false
end
