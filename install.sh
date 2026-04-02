#!/usr/bin/env bash
set -euo pipefail

echo "[*] Starting DevPod dotfiles setup..."

have() {
  command -v "$1" >/dev/null 2>&1
}

install_pnpm() {
  if have pnpm; then
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

install_lazygit() {
  if have lazygit; then
    echo "[*] lazygit already installed"
    return
  fi

  version="$(curl -fsSL https://api.github.com/repos/jesseduffield/lazygit/releases/latest | grep '"tag_name"' | cut -d '"' -f 4 | sed 's/^v//')"
  cd /tmp
  curl -fsSLo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${version}_Linux_x86_64.tar.gz"
  tar xf lazygit.tar.gz lazygit
  sudo install lazygit /usr/local/bin/lazygit
  rm -f lazygit lazygit.tar.gz
}

if have apt-get; then
  echo "[*] Detected Debian/Ubuntu"
  sudo apt-get update
  sudo apt-get install -y curl git unzip ripgrep fd-find

  if ! have fd && have fdfind; then
    sudo ln -sf "$(command -v fdfind)" /usr/local/bin/fd
  fi
elif have dnf; then
  echo "[*] Detected RHEL/Fedora"
  sudo dnf install -y curl git unzip ripgrep fd-find || true

  if ! have fd && have fdfind; then
    sudo ln -sf "$(command -v fdfind)" /usr/local/bin/fd
  fi
else
  echo "[!] Unsupported distro"
  exit 1
fi

install_pnpm
install_lazygit

echo "[*] Installed versions:"
have nvim && nvim --version | head -n 1 || true
have pnpm && pnpm --version || true
have lazygit && lazygit --version || true
have rg && rg --version | head -n 1 || true
have fd && fd --version || true

echo "[*] DevPod dotfiles setup complete"
