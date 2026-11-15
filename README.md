# dotfiles

My Linux setup for software engineering on Fedora: **i3** + **tmux** + **Neovim**, all themed with [Catppuccin Mocha](https://catppuccin.com) and using `hjkl` everywhere.

```
.
├── .tmux.conf         # tmux config (TPM plugins)
├── i3/
│   ├── config         # i3 window manager
│   └── wallpaper.jpg  # Catppuccin wallpaper (set with feh)
├── i3status/config    # status bar
├── nvim/              # Neovim config (based on kickstart.nvim)
├── DEBUGGING.md       # how to debug each language in Neovim
└── install.sh         # bootstrap script
```

## Install

```sh
git clone git@github.com:danielxzr2/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh --packages   # omit --packages to skip dnf
```

`install.sh` is safe to re-run. It:

1. Installs packages with `dnf` (only with `--packages`, asks for sudo).
2. Symlinks `nvim`, `.tmux.conf`, `i3` and `i3status` into place. Existing files are moved to `~/.dotfiles-backup/<date>/`.
3. Installs [TPM](https://github.com/tmux-plugins/tpm) and the tmux plugins.
4. Downloads **JetBrainsMono Nerd Font** and sets it in xfce4-terminal.
5. Applies the wallpaper if a graphical session is running.

Then restart i3 (`Mod+Shift+r`) and open `nvim` once so lazy.nvim installs its plugins.

> **Icons show as boxes with hex codes?** The terminal was already running when the Nerd Font was installed. xfce4-terminal uses a single process for all windows, so close **every** terminal window and open a new one.

## Keybindings

### i3 (`Mod` = Super)

| Keys | Action |
| --- | --- |
| `Mod+Enter` | Terminal |
| `Mod+Shift+Enter` | Terminal attached to tmux session `main` |
| `Mod+d` / `Mod+Shift+d` | App launcher (rofi drun / run) |
| `Mod+Tab` | Window switcher |
| `Mod+h/j/k/l` | Focus left/down/up/right |
| `Mod+Shift+h/j/k/l` | Move window |
| `Mod+b` / `Mod+v` | Split horizontal / vertical |
| `Mod+f` | Fullscreen |
| `Mod+s` / `Mod+w` / `Mod+e` | Stacking / tabbed / toggle split layout |
| `Mod+Shift+space` | Toggle floating |
| `Mod+1..0` / `Mod+Shift+1..0` | Go to / move window to workspace |
| `Mod+minus` / `Mod+Shift+minus` | Show / send to scratchpad |
| `Mod+r` | Resize mode (`hjkl`, `Esc` to exit) |
| `Mod+Escape` | Lock screen |
| `Mod+Shift+e` | System menu: (l)ock (e)xit (s)uspend (r)eboot (p)oweroff |
| `Mod+Shift+q` | Close window |
| `Mod+Shift+c` / `Mod+Shift+r` | Reload / restart i3 |
| `Print` / `Shift+Print` | Screenshot (area / full screen to clipboard) |

Volume, mic, brightness and media keys work out of the box.

### tmux (prefix = `C-s`)

| Keys | Action |
| --- | --- |
| `prefix \|` / `prefix -` | Split horizontal / vertical (in current dir) |
| `prefix c` | New window (in current dir) |
| `prefix h/j/k/l` | Select pane |
| `prefix H/J/K/L` | Resize pane (repeatable) |
| `prefix C-p` / `prefix C-n` | Previous / next window |
| `prefix Enter` | Copy mode (`v` select, `C-v` block, `y` copy to clipboard) |
| `prefix S` / `prefix R` | Save / restore session (tmux-resurrect) |
| `prefix r` | Reload config |
| `prefix I` | Install TPM plugins |

Sessions are auto-saved every 15 minutes and restored when tmux starts (tmux-continuum).

### tmux + Neovim

[vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator): `C-h/j/k/l` moves between Neovim splits **and** tmux panes with no prefix. In a plain shell, `C-l` no longer clears the screen; use `prefix C-l` or `clear`.

### Neovim: merge conflicts

[git-conflict.nvim](https://github.com/akinsho/git-conflict.nvim) highlights conflicts in the buffer and resolves them with one key. These keys only exist in files that have conflicts:

| Keys | Action |
| --- | --- |
| `]x` / `[x` | Next / previous conflict |
| `co` / `ct` | Keep ours / theirs |
| `cb` / `c0` | Keep both / neither |
| `:GitConflictListQf` | List all conflicts in the repo (quickfix) |

LSP diagnostics are hidden while a file has conflict markers and come back once it's resolved.

For easier conflicts, make git also show the original code (the merge base) between both sides:

```sh
git config --global merge.conflictStyle zdiff3
```

### Neovim: debugger

[nvim-dap](https://github.com/mfussenegger/nvim-dap) with [nvim-dap-ui](https://github.com/rcarriga/nvim-dap-ui). Adapters are installed by Mason the first time nvim starts. `<leader>` is **Space**.

**Step-by-step guide for every language: [DEBUGGING.md](DEBUGGING.md).**

| Keys | Action |
| --- | --- |
| `<leader>db` / `<leader>dB` | Breakpoint / conditional breakpoint |
| `<leader>dc` or `F5` | Start / continue |
| `<leader>do` / `<leader>di` / `<leader>dO` | Step over / into / out |
| `<leader>dC` | Run to cursor |
| `<leader>de` | Evaluate expression under cursor (or selection) |
| `<leader>dl` | Run last session again |
| `<leader>dt` / `<leader>du` | Terminate / toggle UI |
| `<leader>dT` | Go: debug the test under the cursor |

The UI opens when a session starts and closes when the program ends. xfce4-terminal keeps `F1` for its help, so use `<leader>di` to step into.

| Language | Adapter | Notes |
| --- | --- | --- |
| Python | debugpy | Runs the current file; uses the active virtualenv. |
| JavaScript / TypeScript | js-debug-adapter | Runs the current file with Node (≥ 22.18 runs `.ts` directly), or attaches to `node --inspect`. |
| C / C++ / Rust | codelldb | Build with debug info (`gcc -g -O0`, `cargo build`); asks for the executable path. |
| C# | netcoredbg | Needs the .NET SDK (`sudo dnf install dotnet-sdk-8.0`). |
| Go | delve | Only enabled when `go` is installed (`sudo dnf install golang`); also enables the `gopls` language server. |

## Requirements

Fedora with i3, tmux ≥ 3.2, Neovim ≥ 0.10, plus: `rofi picom feh dunst xclip flameshot playerctl brightnessctl ripgrep fd-find`. `install.sh --packages` installs them all.

## Customizing

- **Wallpaper:** replace `i3/wallpaper.jpg` and press `Mod+Shift+r`.
- **Terminal:** change `set $term` in `i3/config`.
- **Neovim plugins:** add them in `nvim/lua/custom/plugins/`.
- **Network in the bar:** `i3status/config` uses `wireless _first_` and `ethernet _first_`, so it picks up whatever interfaces the machine has. To pin a specific one, replace `_first_` with its name (check with `ip -br link`).
