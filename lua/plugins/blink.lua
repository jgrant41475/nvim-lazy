-- Super-tab completion: <Tab> accepts the selected item (or jumps forward in a
-- snippet), <S-Tab> goes back. LazyVim's blink extra wraps <Tab> so snippet
-- jumps and AI suggestions still work under this preset.
return {
  {
    "saghen/blink.cmp",
    opts = {
      keymap = {
        preset = "super-tab",
        -- Close the menu without leaving insert mode; a second <Esc> leaves.
        ["<Esc>"] = { "hide", "fallback" },
        ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
        ["<M-Space>"] = { "select_and_accept", "snippet_forward", "show" },
      },
    },
  },
}
