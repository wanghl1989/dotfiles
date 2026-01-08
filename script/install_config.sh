#!/bin/bash

set -euo pipefail

if command -v readlink &>/dev/null; then
  SCRIPT_PATH=$(readlink -f "$0")
else
  SCRIPT_PATH=$(cd "$(dirname "$0")" && pwd -P)/$(basename "$0")
fi

SCRIPT_DIR=$(dirname $(dirname "$SCRIPT_PATH"))

echo "✅ 已获取当前脚本所在目录：$SCRIPT_DIR"

os_kernel=$(uname -s)

# 在 ~/.config中的配置
ITEMS=("zed" "nvim" "kitty" "wezterm" "uv" "starship.toml" "tmux" "ghostty" "lazygit" "bat" "yazi" "btop" "lazydocker" "lsd" "zellij" "eza" "newsboat")
if [ "$os_kernel" = "Darwin" ]; then
  echo " 当前系统是 macOS"
  ITEMS+=("aerospace")
else
  echo " 当前系统是 Linux"
fi

DEST_DIR="$HOME/.config"

mkdir -p "$DEST_DIR"
echo '✅ 软链接目标目录：$DEST_DIR（已确保存在）'

echo -e "\n开始创建软链接..."
for item in "${ITEMS[@]}"; do
  source_path="$SCRIPT_DIR/$item"
  link_path="$DEST_DIR/$item"

  if [ ! -e "$source_path" ]; then
    echo "⚠️ 跳过, 源路径不存在 → $source_path"
    continue
  fi

  if [ -L "$link_path" ]; then
    rm -f "$link_path"
  elif [ -f "$link_path" ]; then
    rm -f "$link_path"
  elif [ -d "$link_path" ]; then
    rm -rf "$link_path"
  fi

  ln -sf "$source_path" "$link_path"
  echo "✅ 已创建软链接：$link_path → $source_path"
done

# Rime配置
RIME_PATH=("$HOME/Library/Rime", "$HOME/.local/share/fcitx5/rime")

if [ "$os_kernel" = "Darwin" ]; then
  RIME_PATH="$HOME/Library/Rime"
else
  RIME_PATH="$HOME/.local/share/fcitx5/rime"
fi

echo "🔄  Rime 配置文件路径为: $RIME_PATH"
if [ -d "$RIME_PATH" ]; then
  rm -rf "$RIME_PATH"
fi
RIME_SRC="$SCRIPT_DIR/Rime"
ln -sf "$RIME_SRC" "$RIME_PATH"
echo "✅ 已创建软链接：$RIME_PATH → $RIME_SRC"

# 在home目录下的配置
HOME_ITEMS=(".vimrc")

for item in "${HOME_ITEMS[@]}"; do
  source_path="$SCRIPT_DIR/$item"
  link_path="$HOME/$item"

  if [ ! -e "$source_path" ]; then
    echo "⚠️ 跳过, 源路径不存在 → $source_path"
    continue
  fi

  if [ -L "$link_path" ]; then
    rm -f "$link_path"
  elif [ -f "$link_path" ]; then
    rm -f "$link_path"
  elif [ -d "$link_path" ]; then
    rm -rf "$link_path"
  fi

  ln -sf "$source_path" "$link_path"
  echo "✅ 已创建软链接：$link_path → $source_path"
done

# bat 需要构建theme
if command -v bat &>/dev/null; then
  echo "构建batcat theme"
  bat cache --build
fi

echo -e "\n🎉 所有可处理的软链接创建完成！"
