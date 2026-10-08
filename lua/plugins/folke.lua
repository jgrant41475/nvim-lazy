-- Pickers respect .gitignore (LazyVim's default); toggle ignored/hidden files
-- inside a picker with <a-i>/<a-h>. `exclude` is only for noise that projects
-- usually don't gitignore.
local exclude = {
  "**/.git/**",
  "**/.idea/**",
  "**/.vscode/**",
  "**/android/**",
  "**/ios/**",
  "**/db_backups/**",
  "**/*_snapshot.json",
  "**/tmp/**",
}

-- The explorer reads directories itself and shows ignored files, so it keeps
-- its own short list of directories too big to be worth listing.
local explore_exclude = { "**/node_modules/**", "**/cdk.out/**" }

-- Places with their own keys: <leader>f<explore> opens the explorer there,
-- <leader>f<files> finds files there.
local places = {
  { dir = "/", explore = "/", name = "/" },
  { dir = "~", explore = "h", files = "H", name = "Home" },
  { dir = "~/.dotfiles", explore = "d", files = "D", name = ".Dotfiles" },
  { dir = vim.fn.stdpath("config"), explore = "c", files = "C", name = "Config" },
}

local place_keys = {}
for _, p in ipairs(places) do
  place_keys[#place_keys + 1] = {
    "<leader>f" .. p.explore,
    function()
      Snacks.explorer({ cwd = p.dir })
    end,
    desc = "Explorer (" .. p.name .. ")",
  }
  if p.files then
    place_keys[#place_keys + 1] = {
      "<leader>f" .. p.files,
      function()
        Snacks.picker.files({ cwd = p.dir })
      end,
      desc = "Find Files (" .. p.name .. ")",
    }
  end
end

return {
  {
    "folke/snacks.nvim",
    ---@type snacks.Config
    opts = {
      picker = {
        sources = {
          files = { hidden = true, exclude = exclude },
          grep = { hidden = true, exclude = exclude },
          explorer = {
            hidden = true,
            ignored = true,
            exclude = explore_exclude,
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
      lazygit = {
        -- snacks defaults os.editPreset to "nvim-remote", whose commands all use
        -- `nvim --server "$NVIM" --remote-tab ...` — the `--remote-tab` opens in a
        -- NEW TAB. Override each one to mirror the preset but with plain `--remote`,
        -- so things open in the current window instead. editPreset still covers
        -- what is left (edit-in-terminal).
        --   edit/editAtLine  -> `e` on a file
        --   openDirInEditor  -> `o` in the Worktrees panel. The tab `--remote-tab`
        --     made here was especially messy: the new tab inherited the current
        --     buffer AND snacks hijacked the directory buffer, so you landed in a
        --     second tab holding a stray copy of the file you were on plus the
        --     explorer sidepanel. With `--remote` the explorer just opens in place.
        config = {
          os = {
            edit = [[[ -z "$NVIM" ] && (nvim -- {{filename}}) || (nvim --server "$NVIM" --remote-send "q" && nvim --server "$NVIM" --remote {{filename}})]],
            editAtLine = [[[ -z "$NVIM" ] && (nvim +{{line}} -- {{filename}}) || (nvim --server "$NVIM" --remote-send "q" && nvim --server "$NVIM" --remote {{filename}} && nvim --server "$NVIM" --remote-send ":{{line}}<CR>")]],
            openDirInEditor = [[[ -z "$NVIM" ] && (nvim -- {{dir}}) || (nvim --server "$NVIM" --remote-send "q" && nvim --server "$NVIM" --remote {{dir}})]],
          },
        },
      },
    },
    keys = vim.list_extend({
      {
        "<leader>ba",
        function()
          -- Prompts for unsaved buffers instead of failing partway (E89).
          Snacks.bufdelete.all()
          -- Only take over the leftover empty buffer, not one kept by a "No".
          if vim.api.nvim_buf_get_name(0) == "" and not vim.bo.modified then
            Snacks.dashboard({ win = 0, buf = 0 })
          end
        end,
        desc = "Delete All Buffers",
      },
      -- Pinned: the explorer stays open after picking a file.
      {
        "<leader>fo",
        function()
          Snacks.explorer({ cwd = LazyVim.root(), auto_close = false })
        end,
        desc = "Explorer (Root Dir, Pinned)",
      },
      {
        "<leader>fO",
        function()
          Snacks.explorer({ auto_close = false })
        end,
        desc = "Explorer (cwd, Pinned)",
      },
      {
        "<leader>//",
        function()
          Snacks.picker.grep()
        end,
        desc = "Grep (cwd)",
      },
      -- Browse a frequently used directory (zoxide) without changing the cwd.
      {
        "<leader>fz",
        function()
          Snacks.picker.zoxide({
            confirm = function(picker, item)
              picker:close()
              if item then
                Snacks.explorer({ cwd = item.file })
              end
            end,
          })
        end,
        desc = "Explorer (zoxide)",
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
    }, place_keys),
  },
}
