#!/usr/bin/env bash

set -euo pipefail


if [ $# -lt 1 ]; then
    echo -e "\033[31m错误：请传入远程客户端地址 \033[0m"
    echo -e "用法：bash $0 user@0.0.0.0:/home/user"
    echo -e "用法：bash $0 user@0.0.0.0:/home/user <port>"
    exit 1
fi

SERVER=$1
if [ $# -gt 1 ]; then
  PORT=$2
else
  PORT=22
fi
  
SCRIPT_PATH=$(cd "$(dirname "$0")" && pwd -P)/$(basename "$0")
BASE_ROOT=$(dirname "$SCRIPT_PATH")
echo -e "-> Install config to server ${SERVER} on port ${PORT}"
echo -e "$BASE_ROOT"

CONFIG_ITEMS=("pip" "tmux" "uv")
DEST_DIR="$SERVER/.config"
for item in "${CONFIG_ITEMS[@]}"; do
  source_path="$BASE_ROOT/config/$item"
  link_path="$DEST_DIR/$item"
  scp -r -P "${PORT}" "${source_path}" "${link_path}"
done


CONFIG_ITEMS=(".condarc" ".vimrc")
DEST_DIR="$SERVER"
for item in "${CONFIG_ITEMS[@]}"; do
  source_path="$BASE_ROOT/home/$item"
  link_path="$DEST_DIR/$item"
  scp -r -P $PORT $source_path  $link_path
done
