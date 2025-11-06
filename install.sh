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
SCRIPT_DIR=$(dirname "$SCRIPT_PATH")

echo "✅ 已获取当前脚本所在目录：$SCRIPT_DIR"

# --------------------------
# 2. 定义文件
# --------------------------
ITEMS=("zed" "nvim" "kitty" "wezterm" "uv" "starship.toml", "tmux", "ghostty")

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
  if [ -e "$link_path" ]; then
    # 如果是软链接，先删除旧链接
    if [ -L "$link_path" ]; then
      echo "🔄 替换旧软链接：$link_path"
      rm -f "$link_path"
    else
      # 如果是普通文件/目录，不覆盖（避免数据丢失）
      echo "❌ 跳过 $item：目标路径已存在且不是软链接 → $link_path"
      continue
    fi
  fi

  # 创建软链接
  ln -sf "$source_path" "$link_path"
  echo "✅ 已创建软链接：$link_path → $source_path"
done

#  #  tmux link
#  TMUX_SOURCE="$SCRIPT_DIR/tmux/tmux.conf"
#  TMUX_TARGET="$DEST_DIR/.tmux.conf"
#  if [ -e "$TMUX_TARGET" ]; then
#    echo "🔄 替换旧软链接：$TMUX_TARGET"
#    rm -f "$TMUX_TARGET"
#  fi
#  ln -sf "$SCRIPT_DIR" "$TMUX_TARGET"
#  echo "✅ 已创建软链接：$TMUX_TARGET → $TMUX_SOURCE"

echo -e "\n🎉 所有可处理的软链接创建完成！"n -sf ./starship.toml ~/.config/
