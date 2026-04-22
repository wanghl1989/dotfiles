#!/bin/bash

echo "=========== 设置zsh ==============="
if command -v readlink &>/dev/null; then
  SCRIPT_PATH=$(readlink -f "$0")
else
  # 若系统没有readlink，使用其他方式获取绝对路径
  SCRIPT_PATH=$(cd "$(dirname "$0")" && pwd -P)/$(basename "$0")
fi

# 提取脚本所在目录（即目标文件/文件夹的父目录）
SCRIPT_DIR=$(dirname $(dirname "$SCRIPT_PATH"))
SOURCE_DIR="$SCRIPT_DIR/zsh"

LINK_PATH="$HOME/.zsh"

if [ -L "$LINK_PATH" ]; then
  rm -f "$LINK_PATH"
elif [ -f "$LINK_PATH" ]; then
  rm -f "$LINK_PATH"
elif [ -d "$LINK_PATH" ]; then
  rm -rf "$LINK_PATH"
fi

ITEMS=(".zshrc_plugin" ".zshrc_alias" ".zshrc_images" ".zshrc_utils")

ln -sf "$SOURCE_DIR" "$LINK_PATH"
echo "✅ 已创建软链接：$LINK_PATH → $SOURCE_DIR"

ZSHRC_FILE="$HOME/.zshrc"


SENTENCES=('eval "$(starship init zsh)"' 'eval "$(zoxide init zsh)"'  'eval "$(fnm env)"')


for sentence in "${SENTENCES[@]}"; do
  if ! grep -Fxq "$sentence" "$ZSHRC_FILE"; then
    echo "$sentence" >>"$ZSHRC_FILE"
    echo "已添加: $sentence"
  else
    echo "已存在 \" $sentence \"  语句, 跳过"
  fi
done

if [ ! -f "$ZSHRC_FILE" ]; then
  touch "$ZSHRC_FILE"
  echo "创建了新的.zshrc文件"
fi

for item in "${ITEMS[@]}"; do
  zsh_source="$LINK_PATH/$item"

  source_line="source $zsh_source"

  if ! grep -Fxq "$source_line" "$ZSHRC_FILE"; then
    echo "$source_line" >>"$ZSHRC_FILE"
    echo "已添加: $source_line"
  else
    echo "已存在 \" $source_line \"  语句, 跳过"
  fi

done

# 使配置生效
scripts操作完成！使用 source ~/.zshrc 重新加载zsh配置..."
