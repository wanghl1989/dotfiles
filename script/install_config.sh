#!/usr/bin/env bash

set -euo pipefail

# 创建软链接的函数
function create_symlink() {
  local _src="$1"
  local _dst="$2"

  if [ ! -e "$_src" ]; then
    echo "⚠️ 跳过, 源路径不存在 → $_src"
    return
  fi

  if [ -L "$_dst" ]; then
    rm -f "$_dst"
  elif [ -f "$_dst" ]; then
    rm -f "$_dst"
  elif [ -d "$_dst" ]; then
    rm -rf "$_dst"
  fi

  ln -sf "$_src" "$_dst"
  echo "✅ 已创建软链接：$_dst → $_src"
}

if command -v readlink &>/dev/null; then
  SCRIPT_PATH=$(readlink -f "$0")
else
  SCRIPT_PATH=$(cd "$(dirname "$0")" && pwd -P)/$(basename "$0")
fi

os_kernel=$(uname -s)

# 在 ~/.config中的配置
# macos linux通用
ITEMS=("zed" "nvim" "kitty" "uv" "ruff" "starship.toml" "tmux" "ghostty" "lazygit" "bat" "yazi" "btop" "lazydocker" "herdr" "eza" "newsboat" "pip" "fastfetch" "dict" "fish" "alacritty")
BASE_ROOT=$(dirname $(dirname "$SCRIPT_PATH"))

DEST_DIR="$HOME/.config"

mkdir -p "$DEST_DIR"
echo '✅ 软链接目标目录：$DEST_DIR（已确保存在）'

echo -e "\n开始创建软链接..."
for item in "${ITEMS[@]}"; do
  source_path="$BASE_ROOT/config/$item"
  link_path="$DEST_DIR/$item"

  create_symlink "$source_path" "$link_path"
done

# macos中的设置
if [ "$os_kernel" = "Darwin" ]; then
  MACOS_ITEMS=("aerospace")

  for item in "${MACOS_ITEMS[@]}"; do
    source_path="$BASE_ROOT/config/$item"
    link_path="$DEST_DIR/$item"

    create_symlink "$source_path" "$link_path"
  done
fi

# linux中的设置
if [ "$os_kernel" = "Linux" ]; then
  LINUX_ITEMS=("mpv" ".Xresources")

  for item in "${LINUX_ITEMS[@]}"; do
    source_path="$BASE_ROOT/config/$item"
    link_path="$DEST_DIR/$item"

    create_symlink "$source_path" "$link_path"
  done
fi

# Rime配置
if [ "$os_kernel" = "Darwin" ]; then
  RIME_PATH="$HOME/Library/Rime"
else
  RIME_PATH="$HOME/.local/share/fcitx5/rime"
fi

echo "🔄  Rime 配置文件路径为: $RIME_PATH"
create_symlink "$BASE_ROOT/Rime" "$RIME_PATH"

# 在home目录下的配置
HOME_ITEMS=(
  ".vimrc"             # vim config
  ".cargo/config.toml" # cargo
  ".condarc"
)

for item in "${HOME_ITEMS[@]}"; do
  source_path="$BASE_ROOT/$item"
  link_path="$HOME/$item"
  create_symlink "$source_path" "$link_path"
done

# bat 需要构建theme
if command -v bat &>/dev/null; then
  echo "构建batcat theme"
  bat cache --build &>/dev/null
fi

echo -e "\n🎉 已安装所有配置！"
