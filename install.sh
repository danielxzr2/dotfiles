#!/usr/bin/env bash
# Instala los dotfiles: crea symlinks, instala TPM + plugins y la Nerd Font.
# Uso: ./install.sh            (todo menos paquetes)
#      ./install.sh --packages (también instala paquetes con dnf, pide sudo)
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m==>\033[0m %s\n' "$*"; }

# link <origen en el repo> <destino>
link() {
  local src="$DOTFILES/$1" dst="$2"
  if [ -L "$dst" ] && [ "$(readlink -f "$dst")" = "$(readlink -f "$src")" ]; then
    info "ok      $dst"
    return
  fi
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    mkdir -p "$BACKUP"
    mv "$dst" "$BACKUP/"
    warn "backup  $dst -> $BACKUP/"
  fi
  mkdir -p "$(dirname "$dst")"
  ln -s "$src" "$dst"
  info "link    $dst -> $src"
}

# ─── Paquetes (opcional) ─────────────────────────────────
if [ "${1:-}" = "--packages" ]; then
  info "Instalando paquetes con dnf"
  sudo dnf install -y git neovim tmux i3 i3status i3lock xss-lock dex-autostart \
    rofi dmenu picom feh dunst xclip flameshot playerctl brightnessctl \
    network-manager-applet ripgrep fd-find gcc make unzip curl
fi

# ─── Symlinks ────────────────────────────────────────────
info "Creando symlinks"
link nvim        "$HOME/.config/nvim"
link .tmux.conf  "$HOME/.tmux.conf"
link i3          "$HOME/.config/i3"
link i3status    "$HOME/.config/i3status"

# ─── TPM + plugins de tmux ───────────────────────────────
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  info "Clonando TPM"
  git clone -q https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi
info "Instalando plugins de tmux"
"$HOME/.tmux/plugins/tpm/bin/install_plugins" >/dev/null

# ─── Nerd Font ───────────────────────────────────────────
FONT_DIR="$HOME/.local/share/fonts/JetBrainsMonoNerd"
if [ -z "$(fc-list 'JetBrainsMono Nerd Font')" ]; then
  info "Descargando JetBrainsMono Nerd Font"
  tmp="$(mktemp -d)"
  curl -fsSL -o "$tmp/font.tar.xz" \
    https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz
  mkdir -p "$FONT_DIR"
  tar -xJf "$tmp/font.tar.xz" -C "$FONT_DIR" --wildcards '*.ttf'
  rm -rf "$tmp"
  fc-cache -f "$FONT_DIR"
else
  info "ok      JetBrainsMono Nerd Font"
fi

# Fuente de xfce4-terminal (si existe)
if command -v xfconf-query >/dev/null; then
  xfconf-query -c xfce4-terminal -p /font-use-system -n -t bool -s false
  xfconf-query -c xfce4-terminal -p /font-name -n -t string -s "JetBrainsMono Nerd Font 11"
fi

# ─── Wallpaper ───────────────────────────────────────────
# Viene con el symlink de i3/; aquí solo se aplica ya si hay sesión gráfica.
WALLPAPER="$HOME/.config/i3/wallpaper.jpg"
if [ -n "${DISPLAY:-}" ] && command -v feh >/dev/null && [ -f "$WALLPAPER" ]; then
  feh --no-fehbg --bg-fill "$WALLPAPER" && info "ok      wallpaper aplicado"
else
  warn "wallpaper se aplicará al iniciar i3"
fi

info "Listo. Reinicia i3 (Mod+Shift+r) y abre nvim para instalar sus plugins."
