import re

from kitty.clipboard import set_clipboard_string

# 匹配整行文本（忽略纯空白行，可根据需求删除 \S 保留空行）
RE_FULL_LINE = r"^.+\S.*$"


def mark(text, args, Mark, extra_cli_args, *a):
    # 遍历所有匹配的整行，生成标记
    idx = 0
    for m in re.finditer(RE_FULL_LINE, text, re.MULTILINE):
        start, end = m.span()
        # 去除行尾多余换行符，保留行内原有格式
        mark_text = text[start:end].replace("\n", "").replace("\0", "").strip()
        if not mark_text:
            continue
        # 传递行号和内容，方便后续扩展
        yield Mark(idx, start, end, mark_text, {"line_number": idx + 1})
        idx += 1


def handle_result(args, data, target_window_id, boss, extra_cli_args, *a):
    # 收集所有选中的行文本
    selected_lines = []
    for m, g in zip(data["match"], data["groupdicts"]):
        if m:
            selected_lines.append(m)
    # 多行用换行符连接，单行直接复制
    result = "\n".join(selected_lines)
    if result:
        set_clipboard_string(result)
