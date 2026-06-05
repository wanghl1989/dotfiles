#!/usr/bin/env bash

names=("cn_dicts" "en_dicts" "opencc")
base_url="https://github.com/iDvel/rime-ice/releases/download/nightly"

# 循环处理每个压缩包
for name in "${names[@]}"; do
  # 构建完整的下载URL
  url="${base_url}/${name}.zip"
  # 定义本地保存的压缩包文件名
  zip_file="${name}.zip"

  echo "开始下载: $url"

  # 下载文件，使用curl，显示进度条，若失败则跳过当前文件
  if ! curl -L -# -o "$zip_file" "$url"; then
    echo "下载 $name 失败，跳过该文件"
    continue
  fi

  echo "下载完成，开始解压 $zip_file..."

  # 解压到当前目录，覆盖已有文件
  if ! unzip -o "$zip_file" -d .; then
    echo "解压 $zip_file 失败"
    # 即使解压失败也尝试删除压缩包
    rm -f "$zip_file"
    continue
  fi

  echo "解压完成，删除压缩包 $zip_file"
  # 删除已解压的压缩包
  rm -f "$zip_file"
done

echo "所有操作完成"
