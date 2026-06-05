#!/usr/bin/env bash

echo "=========== 设置zsh和bash ==============="
if command -v readlink &>/dev/null; then
  SCRIPT_PATH=$(readlink -f "$0")
else
  # 若系统没有readlink，使用其他方式获取绝对路径
  SCRIPT_PATH=$(cd "$(dirname "$0")" && pwd -P)/$(basename "$0")
fi

# 提取脚本所在目录（即目标文件/文件夹的父目录）
SCRIPT_DIR=$(dirname $(dirname "$SCRIPT_PATH"))
SOURCE_DIR="$SCRIPT_DIR/shell"

LINK_PATH="$HOME/.shell"

if [ -L "$LINK_PATH" ]; then
  rm -f "$LINK_PATH"
elif [ -f "$LINK_PATH" ]; then
  rm -f "$LINK_PATH"
elif [ -d "$LINK_PATH" ]; then
  rm -rf "$LINK_PATH"
fi


ln -sf "$SOURCE_DIR" "$LINK_PATH"
echo "✅ 已创建软链接：$LINK_PATH → $SOURCE_DIR"

ZSHRC_FILE="$HOME/.zshrc"
BASHRC_FILE="$HOME/.bashrc"


if [ ! -f "$ZSHRC_FILE" ]; then
  touch "$ZSHRC_FILE"
  echo "创建了新的.zshrc文件"
fi


if [ ! -f "$BASHRC_FILE" ]; then
  touch "$BASHRC_FILE"
  echo "创建了新的.bashrc文件"
fi

ZSH_SENTENCES=('eval "$(starship init zsh)"' 'eval "$(zoxide init zsh)"'  'eval "$(fnm env)"')


for sentence in "${ZSH_SENTENCES[@]}"; do
  if ! grep -Fxq "$sentence" "$ZSHRC_FILE"; then
    echo "$sentence" >>"$ZSHRC_FILE"
    echo "[.zshrc] 已添加: $sentence"
  else
    echo "[.zshrc] 已存在 \" $sentence \"  语句, 跳过"
  fi
done

BASH_SENTENCES=('eval "$(starship init bash)"' 'eval "$(zoxide init bash)"'  'eval "$(fnm env)"')


for sentence in "${BASH_SENTENCES[@]}"; do
  if ! grep -Fxq "$sentence" "$BASHRC_FILE"; then
    echo "$sentence" >>"$BASHRC_FILE"
    echo "[.bashrc] 已添加: $sentence"
  else
    echo "[.bashrc] 已存在 \" $sentence \"  语句, 跳过"
  fi
done


ZSH_ITEMS=(".zshrc_plugin")

for item in "${ZSH_ITEMS[@]}"; do
  zsh_source="$LINK_PATH/$item"

  source_line="source $zsh_source"

  if ! grep -Fxq "$source_line" "$ZSHRC_FILE"; then
    echo "$source_line" >>"$ZSHRC_FILE"
    echo "[.zshrc] 已添加: $source_line"
  else
    echo "[.zshrc] 已存在 \" $source_line \"  语句, 跳过"
  fi
done

BASH_ITEMS=(".shell_alias" ".shell_images" ".shell_utils")

for item in "${BASH_ITEMS[@]}"; do
  zsh_source="$LINK_PATH/$item"

  source_line="source $zsh_source"

  if ! grep -Fxq "$source_line" "$ZSHRC_FILE"; then
    echo "$source_line" >>"$ZSHRC_FILE"
    echo "[.zshrc] 已添加: $source_line"
  else
    echo "[.zshrc] 已存在 \" $source_line \"  语句, 跳过"
  fi

  if ! grep -Fxq "$source_line" "$BASHRC_FILE"; then
    echo "$source_line" >>"$BASHRC_FILE"
    echo "[.bashrc] 已添加: $source_line"
  else
    echo "[.bashrc] 已存在 \" $source_line \"  语句, 跳过"
  fi
done


# 使配置生效
echo "scripts操作完成!"
