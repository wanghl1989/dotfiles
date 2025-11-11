#!/bin/bash
if command -v readlink &>/dev/null; then
  SCRIPT_PATH=$(readlink -f "$0")
else
  # 若系统没有readlink，使用其他方式获取绝对路径
  SCRIPT_PATH=$(cd "$(dirname "$0")" && pwd -P)/$(basename "$0")
fi

# 提取脚本所在目录（即目标文件/文件夹的父目录）
SCRIPT_DIR=$(dirname $(dirname "$SCRIPT_PATH"))

# 定义软链接的目标目录（~/.config/）
DEST_DIR="$HOME"

ITEMS=(".zshrc_plugin" ".zshrc_alias")

ZSHRC_FILE="$HOME/.zshrc"

if [ ! -f "$ZSHRC_FILE" ]; then
  touch "$ZSHRC_FILE"
  echo "创建了新的.zshrc文件"
fi

echo -e "\n开始创建zsh软链接..."
for item in "${ITEMS[@]}"; do
  # 源文件/文件夹的绝对路径
  source_path="$SCRIPT_DIR/zsh/$item"
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

  source_line="source $link_path"

  if ! grep -Fxq "$source_line" "$ZSHRC_FILE"; then
    echo "$source_line" >>"$ZSHRC_FILE"
    echo "已添加: $source_line"
  else
    echo "已存在，跳过: $source_line"
  fi

done

# 使配置生效
echo "使用 source ~/.zshrc 重新加载zsh配置..."
echo "操作完成！"
