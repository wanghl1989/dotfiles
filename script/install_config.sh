#!/bin/bash

# 确保脚本执行过程中遇到错误立即退出
set -euo pipefail

# --------------------------
# 1. 获取当前脚本的绝对路径及所在目录
# --------------------------
# 获取脚本自身的绝对路径（兼容不同系统）
if command -v readlink &>/dev/null; then
  SCRIPT_PATH=$(readlink -f "$0")
else
  # 若系统没有readlink，使用其他方式获取绝对路径
  SCRIPT_PATH=$(cd "$(dirname "$0")" && pwd -P)/$(basename "$0")
fi

# 提取脚本所在目录（即目标文件/文件夹的父目录）
SCRIPT_DIR=$(dirname $(dirname "$SCRIPT_PATH"))

echo "✅ 已获取当前脚本所在目录：$SCRIPT_DIR"

# --------------------------
# 2. 定义文件
# --------------------------

os_kernel=$(uname -s)

ITEMS=("zed" "nvim" "kitty" "wezterm" "uv" "starship.toml" "tmux" "ghostty" "lazygit" "bat" "yazi" "btop" "lazydocker" "lsd" "zellij" "eza" "newsboat")
if [ "$os_kernel" = "Darwin" ]; then
  echo " 当前系统是 macOS"
  ITEMS+=("aerospace")
else
  echo " 当前系统是 Linux"
fi

# 定义软链接的目标目录（~/.config/）
DEST_DIR="$HOME/.config"

# 确保目标目录存在（如果不存在则创建）
mkdir -p "$DEST_DIR"
echo '✅ 软链接目标目录：$DEST_DIR（已确保存在）'

# --------------------------
# 3. 循环创建软链接
# --------------------------
echo -e "\n开始创建软链接..."
for item in "${ITEMS[@]}"; do
  # 源文件/文件夹的绝对路径
  source_path="$SCRIPT_DIR/$item"
  # 软链接的路径（~/.config/item）
  link_path="$DEST_DIR/$item"

  # 检查源是否存在
  if [ ! -e "$source_path" ]; then
    echo "⚠️ 跳过, 源路径不存在 → $source_path"
    continue
  fi

  # 处理已存在的软链接/文件
  if [ -L "$link_path" ]; then
    rm -f "$link_path"
  elif [ -f "$link_path" ]; then
    rm -f "$link_path"
  elif [ -d "$link_path" ]; then
    rm -rf "$link_path"
  fi

  # 创建软链接
  ln -sf "$source_path" "$link_path"
  echo "✅ 已创建软链接：$link_path → $source_path"
done

RIME_PATH=("$HOME/Library/Rime", "$HOME/.local/share/fcitx5/rime")

for item in "$RIME_PATH[@]"; do
  if [ -d "$item" ]; then
    echo "🔄  Rime 配置文件路径为: $item"
    rm -rf "$item"
    source_path="$SCRIPT_DIR/Rime"
    ln -sf "$source_path" "$item"
    echo "✅ 已创建软链接：$item → $source_path"
  fi
done

if command -v fzf &>/dev/null; then
  echo "构建batcat theme"
  bat cache --build
fi

echo -e "\n🎉 所有可处理的软链接创建完成！"
