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

[![Demo](assets/demo_zoom_sync_with_animation.png)](https://private-user-images.githubusercontent.com/61352040/472376279-1dc1fe78-d3b1-4d17-9394-096a7f8a7c67.mov?jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3NTM4NjQ1NzcsIm5iZiI6MTc1Mzg2NDI3NywicGF0aCI6Ii82MTM1MjA0MC80NzIzNzYyNzktMWRjMWZlNzgtZDNiMS00ZDE3LTkzOTQtMDk2YTdmOGE3YzY3Lm1vdj9YLUFtei1BbGdvcml0aG09QVdTNC1ITUFDLVNIQTI1NiZYLUFtei1DcmVkZW50aWFsPUFLSUFWQ09EWUxTQTUzUFFLNFpBJTJGMjAyNTA3MzAlMkZ1cy1lYXN0LTElMkZzMyUyRmF3czRfcmVxdWVzdCZYLUFtei1EYXRlPTIwMjUwNzMwVDA4MzExN1omWC1BbXotRXhwaXJlcz0zMDAmWC1BbXotU2lnbmF0dXJlPTFhOWJhNjM0ZTQ1NTkzOGFjYTIyYjkxMjMzMThiYWUwNjUwZDVjYjU3OTZhYTNlZjY2OGFmMmRlOWNiODA3NWEmWC1BbXotU2lnbmVkSGVhZGVycz1ob3N0In0.lELvVX8xSVP0Bv3Q2Hr0H4QBICoSDh-Cv22UggiJBoI)

[![Demo](assets/demo_zoom_sync.png)](https://private-user-images.githubusercontent.com/61352040/472234944-00b6e2c6-de0c-428d-9da4-08847a55c2d1.mov?jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3NTM4NjQ1NzcsIm5iZiI6MTc1Mzg2NDI3NywicGF0aCI6Ii82MTM1MjA0MC80NzIyMzQ5NDQtMDBiNmUyYzYtZGUwYy00MjhkLTlkYTQtMDg4NDdhNTVjMmQxLm1vdj9YLUFtei1BbGdvcml0aG09QVdTNC1ITUFDLVNIQTI1NiZYLUFtei1DcmVkZW50aWFsPUFLSUFWQ09EWUxTQTUzUFFLNFpBJTJGMjAyNTA3MzAlMkZ1cy1lYXN0LTElMkZzMyUyRmF3czRfcmVxdWVzdCZYLUFtei1EYXRlPTIwMjUwNzMwVDA4MzExN1omWC1BbXotRXhwaXJlcz0zMDAmWC1BbXotU2lnbmF0dXJlPTRiNWEyYjllOWRmM2QyM2U5ZWMwNWRlYTE4ZDRiZGFjNGM2MjUzNjRmZDU5NzhmMjQzMTlkZmEzMGYwYTc5ZTQmWC1BbXotU2lnbmVkSGVhZGVycz1ob3N0In0.RXaIlaAHHetWjnCcbjcB73UDoIkbCyOdTajlFCW2M-M)

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
    "anuvyklack/animation.nvim",
  },
  config = function()
    vim.o.winwidth = 1
    vim.o.winminwidth = 1
    vim.o.equalalways = false -- disable equal window size to let zoomsync handle it
    require("windows").setup({
      autowidth = { enable = false },
      animation = { enable = true, duration = 300, fps = 45, easing = "in_out_sine" },
    })
    require("zoomsync").setup({
      sync_tmux_on = {
        win_enter = true,  -- sync Tmux zoom on Neovim window enter
        focus_lost = true,  -- sync Tmux zoom on Neovim focus lost
      },
      equalalways = true,  -- keep windows equal size upon split or quitting window
    })
    -- The bang version syncs Nvim to Tmux zoom state
    vim.keymap.set("n", "<leader>zs", "<cmd>ZoomToggle!<CR>", { desc = "Toggle and sync Neovim and Tmux zoom" })
    vim.keymap.set("n", "<leader>zz", "<cmd>ZoomToggle<CR>", { desc = "Toggle Neovim zoom" })
  end,
}
```

⚠️ Note: Don't forget to setup windows.nvim.

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

## 🔍 Commands

This plugin provides the following user commands:

| Command           | Description                                                                             |
| ----------------- | --------------------------------------------------------------------------------------- |
| `:ZoomToggle[!]`  | Toggles zoom in Neovim and optionally Tmux. <br> Use `!` to sync with Tmux.             |
| `:ZoomEnable[!]`  | Zoom on in Neovim if not zoomed. <br> Use `!` to avoid zooming if Tmux not zoomed.      |
| `:ZoomDisable[!]` | Zoom off in Neovim if currently zoomed. <br> Use `!` to avoid unzooming if Tmux zoomed. |
