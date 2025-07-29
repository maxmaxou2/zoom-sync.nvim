# zoom-sync.nvim

Synchronize zoom between Neovim splits and Tmux panes.

This plugin lets you **maximize a Neovim window** using [`windows.nvim`](https://github.com/anuvyklack/windows.nvim) while **automatically toggling Tmux zoom mode** at the same time — and **keeps them in sync**. If you unzoom in Tmux or Neovim, the other follows.
Just press your **tmux zoom keybinding** and the plugin will **sync the zoom state in Neovim**.

---

## ✨ Features

- Toggle zoom in Neovim **and** Tmux together
- Synchronize zoom state in both directions
- Automatically unzoom when switching windows or focus
- Minimal config, no performance overhead

---

## ⚙️ Requirements

- [anuvyklack/windows.nvim](https://github.com/anuvyklack/windows.nvim)
- [anuvyklack/middleclass.nvim](https://github.com/anuvyklack/middleclass.nvim)
- Tmux ≥ `3.2`
- Neovim ≥ `0.8`
- Unix-like system (uses shell + `tmux` CLI)

---

## 📦 Installation

### [lazy.nvim](https://github.com/folke/lazy.nvim)

Here's the recommended configuration for `lazy.nvim`:

```lua
{
  "maxmaxou2/zoom-sync.nvim",
  dependencies = {
    "anuvyklack/windows.nvim",
    "anuvyklack/middleclass", -- required by windows.nvim
    -- uncomment if you want animations (configurable in windows.nvim)
    -- "anuvyklack/animation.nvim",
  },
  config = function()
    vim.o.winwidth = 1
    vim.o.winminwidth = 1
    vim.o.equalalways = true
    require("zoomsync").setup({
      sync_tmux_on = {
        win_enter = true,  -- sync Tmux zoom on Neovim window enter
        focus_lost = true,  -- sync Tmux zoom on Neovim focus lost
      },
    })
    -- The bang version syncs Nvim to Tmux zoom state
    vim.keymap.set("n", "<leader>zs", "<cmd>ZoomToggle!<CR>", { desc = "Toggle and sync Neovim and Tmux zoom" })
    vim.keymap.set("n", "<leader>zz", "<cmd>ZoomToggle<CR>", { desc = "Toggle Neovim zoom" })
  end,
}
{ "anuvyklack/windows.nvim",
   requires = "anuvyklack/middleclass",
   config = function()
     require("windows").setup({
       autowidth = { enable = false },
       animation = { enable = false },
     })
   end
}
```

⚠️ Note: Don't forget to setup windows.nvim yourself.

### .tmux.conf

To enable Tmux zoom synchronization, add the following to your `.tmux.conf`:

```tmux
# Enable zoom synchronization with Neovim
unbind z
bind z run-shell ' \
  tmux resize-pane -Z; \
  if [ "$(tmux display-message -p "#{pane_current_command}")" = "nvim" ]; then \
    tmux send-keys Escape : "ZoomToggle!" Enter; \
  fi; \
'
```

```lua

```

## 🔍 Commands

This plugin provides the following user commands:

| Command           | Description                                                                             |
| ----------------- | --------------------------------------------------------------------------------------- |
| `:ZoomToggle[!]`  | Toggles zoom in Neovim and optionally Tmux. <br> Use `!` to sync with Tmux.             |
| `:ZoomEnable[!]`  | Zoom on in Neovim if not zoomed. <br> Use `!` to avoid zooming if Tmux not zoomed.      |
| `:ZoomDisable[!]` | Zoom off in Neovim if currently zoomed. <br> Use `!` to avoid unzooming if Tmux zoomed. |
