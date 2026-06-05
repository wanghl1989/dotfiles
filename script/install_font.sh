#!/usr/bin/env bash

os_kernel=$(uname -s)

if [ "$os_kernel" = "Darwin" ]; then
  FONTBASE="$HOME/Library/Fonts"
else
  FONTBASE="$HOME/.local/share/fonts"
fi

if [[ ! -e $FONTBASE ]]; then 
  mkdir -p $FONTBASE
fi 
# FONT_DIR="$FONTBASE/ComicShannsMono"
# if [[ ! -d "$FONT_DIR" ]]; then
#   echo "Installing Nerd Fonts. If the download fails, you can try deleting the directory $FONT_DIR and restarting zsh."
#   mkdir -p $FONT_DIR
#   curl -L "https://github.com/cap153/config/releases/download/%E6%88%91%E4%BD%BF%E7%94%A8%E7%9A%84%E5%AD%97%E4%BD%93/ComicShannsMono.tar.gz" -o /tmp/font.tar.gz
#   tar -zxvf /tmp/font.tar.gz -C $FONT_DIR
# fi
#
# FONT_DIR="$FONTBASE/LxgwWenKai-Screen"
# if [[ ! -d "$FONT_DIR" ]]; then
#   echo "Installing Chinese fonts. If the download fails, you can try deleting the directory $FONT_DIR and restarting zsh."
#   mkdir -p $FONT_DIR
#   curl -L "https://github.com/cap153/config/releases/download/%E6%88%91%E4%BD%BF%E7%94%A8%E7%9A%84%E5%AD%97%E4%BD%93/LxgwWenKai-Screen.tar.gz" -o /tmp/font.tar.gz
#   tar -zxvf /tmp/font.tar.gz -C $FONT_DIR
# fi
#
#

if command -v readlink &>/dev/null; then
  SCRIPT_PATH=$(readlink -f "$0")
else
  # 若系统没有readlink，使用其他方式获取绝对路径
  SCRIPT_PATH=$(cd "$(dirname "$0")" && pwd -P)/$(basename "$0")
fi

FONT_SRC="$(dirname $(dirname "$SCRIPT_PATH"))/font"
find "$FONT_SRC/" -mindepth 1 -maxdepth 1 -print0 | while LFS= read -r -d '' src; do {
   if [[ -d $src ]]; then 
       cp -r $src $FONTBASE
   fi

   if [[ -f $src ]]; then 
       cp  $src $FONTBASE
   fi
}
done
echo "✅ 成功安装字体"
