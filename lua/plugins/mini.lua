-- A path token: path-ish chars containing at least one "/", ending on a char
-- that can't be trailing punctuation, with an optional ":123" line suffix.
-- The `()` captures mark the span that gets highlighted.
local path_patterns = {
  "%f[%w%.~/]()[%w%.%-_~/]*/[%w%.%-_~/]*[%w%-_]()",
  "%f[%w%.~/]()[%w%.%-_~/]*/[%w%.%-_~/]*[%w%-_]:%d+()",
}

local exists_cache = {}

-- Only highlight paths that actually resolve on disk, so prose like "and/or"
-- stays plain text.
local function path_exists(buf_id, match)
  local p = match:match("^(.-):%d+$") or match
  local hit = exists_cache[p]
  if hit ~= nil then return hit end

  local abs = vim.fs.normalize(p) -- expands ~
  local candidates = {}
  if abs:sub(1, 1) == "/" then
    candidates[1] = abs
  else
    candidates[1] = vim.fs.joinpath(vim.fn.getcwd(), abs)
    local name = vim.api.nvim_buf_get_name(buf_id)
    if name ~= "" then
      candidates[2] = vim.fs.joinpath(vim.fs.dirname(name), abs)
    end
  end

  local found = false
  for _, c in ipairs(candidates) do
    if vim.uv.fs_stat(c) then
      found = true
      break
    end
  end
  exists_cache[p] = found
  return found
end

local function set_path_hl()
  local src = vim.api.nvim_get_hl(0, { name = "@markup.link.url", link = false })
  if vim.tbl_isempty(src) then
    src = vim.api.nvim_get_hl(0, { name = "Directory", link = false })
  end
  vim.api.nvim_set_hl(0, "FilePathLink", { fg = src.fg, sp = src.fg, underline = true })
end

-- mini.surround and mini.ai are set up by LazyVim (the coding.mini-surround
-- extra and the core mini.ai spec), so only the modules it doesn't own live here.
return {
  {
    "nvim-mini/mini.nvim",
    config = function()
      -- mini.move's <M-j>/<M-k> are replaced by LazyVim's move-line keymaps;
      -- this still adds <M-h>/<M-l> and the visual-mode moves.
      require("mini.move").setup()

      -- Defaults clash: gx is the builtin "open URL", gr is LazyVim's LSP
      -- references, and gs is the mini.surround prefix.
      require("mini.operators").setup({
        exchange = { prefix = "gX" },
        replace = { prefix = "gR" },
        sort = { prefix = "gS" },
      })

      -- Render resolvable file paths as underlined links. Use gF (not gf) to
      -- honour a trailing :123, or ctrl-click.
      local group = vim.api.nvim_create_augroup("file_path_links", { clear = true })
      set_path_hl()
      vim.api.nvim_create_autocmd("ColorScheme", { group = group, callback = set_path_hl })
      vim.api.nvim_create_autocmd({ "BufWritePost", "DirChanged", "FocusGained" }, {
        group = group,
        desc = "Re-check file path links",
        callback = function()
          exists_cache = {}
        end,
      })
      vim.keymap.set("n", "<C-LeftMouse>", "<LeftMouse>gF", { desc = "Open file path under cursor" })

      require("mini.hipatterns").setup({
        highlighters = {
          filepath = {
            pattern = path_patterns,
            group = function(buf_id, match)
              return path_exists(buf_id, match) and "FilePathLink" or nil
            end,
          },
        },
      })
    end,
  },
}
