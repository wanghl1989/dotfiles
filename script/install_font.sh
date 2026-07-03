#!/usr/bin/env bash

os_kernel=$(uname -s)

if [ "$os_kernel" = "Darwin" ]; then
  FONTBASE="$HOME/Library/Fonts"
else
  FONTBASE="$HOME/.local/share/fonts"
fi

if [[ ! -e $FONTBASE ]]; then
  mkdir -p "$FONTBASE"
fi

if command -v readlink &>/dev/null; then
  SCRIPT_PATH=$(readlink -f "$0")
else
  # 若系统没有readlink，使用其他方式获取绝对路径
  SCRIPT_PATH=$(cd "$(dirname "$0")" && pwd -P)/$(basename "$0")
fi

FONT_SRC="$(dirname "$(dirname "$SCRIPT_PATH")")/font"

if [[ ! -d "$FONT_SRC" ]]; then
  echo "❌ 字体源目录不存在: $FONT_SRC"
  exit 1
fi

find "$FONT_SRC/" -mindepth 1 -maxdepth 1 -print0 | while IFS= read -r -d '' src; do
  basename=$(basename "$src")
  if [[ -d "$src" ]]; then
    cp -r "$src" "$FONTBASE/"
    echo "📁 复制字体目录: $basename"
  else
    cp "$src" "$FONTBASE/"
    echo "📄 复制字体文件: $basename"
  fi
done

# Linux 上刷新字体缓存
if [ "$os_kernel" != "Darwin" ] && command -v fc-cache &>/dev/null; then
  echo "🔄 刷新字体缓存..."
  fc-cache -f "$FONTBASE"
fi

echo "✅ 成功安装字体"
