#!/bin/bash

from_to_pairs=(
  "192.168.1.1:192.168.1.254"           # 网段示例
  "/home/user/source:/home/user/target" # 路径示例
  "2026-01-01:2026-01-31"               # 日期范围示例
  "user1:user2"                         # 用户名示例
)

# 2. 遍历数组，拆分并处理每个 (from, to) 对
echo "===== 遍历 (from, to) 数据对 ====="
for pair in "${from_to_pairs[@]}"; do
  # 关键：使用 IFS 分隔符拆分字符串，提取 from 和 to
  # IFS=, 表示以逗号作为分隔符
  # read -r 避免反斜杠转义，保证数据原样读取
  IFS=: read -r from to <<<"$pair"

  # 3. 输出处理结果（可替换为你的业务逻辑）
  echo "from: ${from}"
  echo "to:   ${to}"
  echo "------------------------"
done
