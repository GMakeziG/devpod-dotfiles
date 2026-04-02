#!/usr/bin/env bash
set -euo pipefail

echo "[*] Starting DevPod dotfiles setup..."

have() {
  command -v "$1" >/dev/null 2>&1
}

install_lazygit() {
  if have lazygit; then
    echo "[*] lazygit already installed"
    return
  fi

  local version
  version="$(curl -fsSL https://api.github.com/repos/jesseduffield/lazygit/releases/latest | grep '"tag_name"' | cut -d '"' -f 4 | sed 's/^v//')"

  cd /tmp
  curl -fsSLo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${version}_Linux_x86_64.tar.gz"
  tar xf lazygit.tar.gz lazygit
  sudo install lazygit /usr/local/bin/lazygit
  rm -f lazygit lazygit.tar.gz
}

install_pnpm() {
  if command -v pnpm >/dev/null 2>&1; then
    echo "[*] pnpm already installed"
    return
  fi

  echo "[*] Installing pnpm via user-local installer"
  curl -fsSL https://get.pnpm.io/install.sh | env SHELL=/bin/bash sh -

  export PNPM_HOME="$HOME/.local/share/pnpm"
  case ":$PATH:" in
    *":$PNPM_HOME:"*) ;;
    *) export PATH="$PNPM_HOME:$PATH" ;;
  esac

  if ! grep -q 'PNPM_HOME' "$HOME/.bashrc" 2>/dev/null; then
    cat >> "$HOME/.bashrc" <<'EOF'

export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
EOF
  fi
}

install_pnpm
install_lazygit

mkdir -p "$HOME/.config/nvim"

if [ -f "$PWD/.bashrc" ]; then
  cp "$PWD/.bashrc" "$HOME/.bashrc"
fi

if [ -f "$PWD/.gitconfig" ]; then
  cp "$PWD/.gitconfig" "$HOME/.gitconfig"
fi

if [ -f "$PWD/nvim/init.lua" ]; then
  mkdir -p "$HOME/.config/nvim"
  cp "$PWD/nvim/init.lua" "$HOME/.config/nvim/init.lua"
fi

echo "[*] Installed versions:"
have nvim && nvim --version | head -n 1 || true
have fd && fd --version || true
have rg && rg --version | head -n 1 || true
have pnpm && pnpm --version || true
have lazygit && lazygit --version || true

echo "[*] DevPod dotfiles setup complete"
