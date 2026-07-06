#!/usr/bin/env bash

set -euo pipefail

os_kernel=$(uname -s)

# ---------- Helper functions ----------

# Check if a command exists
has_cmd() {
  command -v "$1" &>/dev/null
}

# Check if a line exists in a file (exact match)
line_in_file() {
  grep -qxF "$2" "$1" 2>/dev/null
}

# Append a line to a file only if it doesn't already exist
append_once() {
  local file="$1" line="$2"
  touch "$file"
  if ! line_in_file "$file" "$line"; then
    echo "$line" >>"$file"
    echo "  [+] Added to $(basename "$file"): $line"
  else
    echo "  [skip] Already in $(basename "$file"): $line"
  fi
}

# ---------- Homebrew ----------

echo ">>>>>>>>>> Install homebrew"

if has_cmd brew; then
  echo "  Homebrew already installed: $(command -v brew)"
else
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  echo "  Homebrew installed successfully"
fi

# Configure Homebrew environment variables
# On macOS (Apple Silicon), brew is at /opt/homebrew/bin
# On Linux, brew is at /home/linuxbrew/.linuxbrew/bin
# We need to make brew available in the current script AND persist it to .zshrc

if [ "$os_kernel" = "Darwin" ]; then
  echo "  当前系统是 macOS"
  BREW_PREFIX="/opt/homebrew"
  # On macOS Intel, brew is already in PATH; on Apple Silicon we need to set it up
  if [ -d "$BREW_PREFIX" ]; then
    eval "$("$BREW_PREFIX/bin/brew" shellenv)"
    append_once ~/.zshrc 'eval "$(/opt/homebrew/bin/brew shellenv)"'
  fi
else
  echo "  当前系统是 Linux"
  BREW_PREFIX="/home/linuxbrew/.linuxbrew"
  if [ -d "$BREW_PREFIX" ]; then
    eval "$("$BREW_PREFIX/bin/brew" shellenv)"
    append_once ~/.zshrc 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"'
  fi
fi

# Verify brew is now available
if ! has_cmd brew; then
  echo "ERROR: brew command not found after installation and PATH setup!" >&2
  exit 1
fi
echo "  brew path: $(command -v brew)"

# ---------- Brew packages ----------

# zoxide: https://github.com/ajeetdsouza/zoxide
echo ">>>>>>>>>> Install zoxide"
brew install zoxide

# ripgrep: https://github.com/BurntSushi/ripgrep
echo ">>>>>>>>>> Install ripgrep"
brew install ripgrep

# fd-find: https://github.com/sharkdp/fd#installation
echo ">>>>>>>>>> Install fd"
brew install fd

# yazi: https://yazi-rs.github.io/docs/installation
echo ">>>>>>>>>> Install yazi"
brew install yazi ffmpeg sevenzip jq poppler fd ripgrep fzf zoxide resvg imagemagick font-symbols-only-nerd-font
append_once ~/.zshrc 'source <(fzf --zsh)'

# lazygit: https://github.com/jesseduffield/lazygit
echo ">>>>>>>>>> Install lazygit"
brew install lazygit

# lsd: https://github.com/lsd-rs/lsd
# echo ">>>>>>>>>> Install lsd"
# brew install lsd

echo ">>>>>>>>>> Install eza"
brew install eza

# bat: https://github.com/sharkdp/bat
echo ">>>>>>>>>> Install bat"
brew install bat

# dust: https://github.com/bootandy/dust
echo ">>>>>>>>>> Install dust"
brew install dust

# duf: https://github.com/muesli/duf
echo ">>>>>>>>>> Install duf"
brew install duf

# lazydocker: https://github.com/jesseduffield/lazydocker
echo ">>>>>>>>>> Install lazydocker"
brew install jesseduffield/lazydocker/lazydocker

# lazyssh: https://github.com/Adembc/lazyssh
# brew install Adembc/homebrew-tap/lazyssh

# others
echo ">>>>>>>>>> Install tmux"
brew install tmux

echo ">>>>>>>>>> Install other packages"
brew install neovim btop trash-cli

# ---------- Starship ----------

echo ">>>>>>>>>> Install starship"
if has_cmd starship; then
  echo "  starship already installed: $(command -v starship)"
else
  curl -sS https://starship.rs/install.sh | sh
fi
append_once ~/.zshrc 'eval "$(starship init zsh)"'
append_once ~/.bashrc 'eval "$(starship init bash)"'

echo ">>>>>>>>>> Installing Finish ✅"
