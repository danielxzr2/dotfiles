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

## Requirements

Fedora with i3, tmux ≥ 3.2, Neovim ≥ 0.10, plus: `rofi picom feh dunst xclip flameshot playerctl brightnessctl ripgrep fd-find`. `install.sh --packages` installs them all.

## Customizing

- **Wallpaper:** replace `i3/wallpaper.jpg` and press `Mod+Shift+r`.
- **Terminal:** change `set $term` in `i3/config`.
- **Neovim plugins:** add them in `nvim/lua/custom/plugins/`.
- **Network interface in the bar:** edit `wireless wlp2s0` in `i3status/config` (check yours with `ip -br link`).
