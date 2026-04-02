#!/usr/bin/env bash
set -e

echo "[*] Installing core tools..."

if command -v dnf >/dev/null; then
  sudo dnf install -y git curl ripgrep neovim unzip nodejs npm
  sudo dnf install -y fd-find || true

  if ! command -v fd >/dev/null && command -v fdfind >/dev/null; then
    sudo ln -sf $(which fdfind) /usr/local/bin/fd
  fi
fi

# Install pnpm
if ! command -v pnpm >/dev/null; then
  corepack enable || true
  corepack prepare pnpm@latest --activate || curl -fsSL https://get.pnpm.io/install.sh | sh -
fi

# Install lazygit
if ! command -v lazygit >/dev/null; then
  VERSION=$(curl -s https://api.github.com/repos/jesseduffield/lazygit/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')
  curl -Lo lazygit.tar.gz https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${VERSION}_Linux_x86_64.tar.gz
  tar xf lazygit.tar.gz lazygit
  sudo install lazygit /usr/local/bin
  rm lazygit lazygit.tar.gz
fi

echo "[*] Setup complete"
