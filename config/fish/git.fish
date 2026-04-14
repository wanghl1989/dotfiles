# git.fish - fzf.fish 全部功能整合（无 keybindings）
#
# 调用方式（直接在 fish 中输入函数名）：
#   gl  - 模糊搜索 git log，选中后插入 commit hash
#   gs  - 模糊搜索 git status，选中后插入文件路径
#   gb  - 模糊搜索本地分支，按 Enter 切换分支
#   fp  - 模糊搜索进程，选中后插入 PID
#
# 预览窗口快捷键：
#   Ctrl+U  - 向上滚动半页
#   Ctrl+D  - 向下滚动半页
#
# 使用方法：在 config.fish 中加入：
#   source ~/.config/fish/git.fish

# ─────────────────────────────────────────────────────────────────────────────
# 内部辅助函数
# ─────────────────────────────────────────────────────────────────────────────

function _fzf_wrapper --description "执行 fzf 前设置必要的环境变量"
    set -f --export SHELL (command --search fish)

    set --query FZF_DEFAULT_OPTS FZF_DEFAULT_OPTS_FILE
    if test $status -eq 2
        set --export FZF_DEFAULT_OPTS '--cycle --layout=reverse --border --height=90% --preview-window=wrap --marker="*"'
    end

    fzf --bind="ctrl-u:preview-half-page-up,ctrl-d:preview-half-page-down" $argv
end

function _fzf_report_file_type --argument-names file_path file_type --description "说明文件类型（无法预览时）"
    set_color red
    echo "Cannot preview '$file_path': it is a $file_type."
    set_color normal
end

function _fzf_preview_file --description " 根据文件类型打印预览内容"
    set -f file_path $argv

    if test -L "$file_path"
        set -l target_path (realpath "$file_path")
        set_color yellow
        echo "'$file_path' is a symlink to '$target_path'."
        set_color normal
        _fzf_preview_file "$target_path"
    else if test -f "$file_path"
        if set --query fzf_preview_file_cmd
            eval "$fzf_preview_file_cmd '$file_path'"
        else
            bat --style=numbers --color=always "$file_path"
        end
    else if test -d "$file_path"
        if set --query fzf_preview_dir_cmd
            eval "$fzf_preview_dir_cmd '$file_path'"
        else
            command ls -A -F "$file_path"
        end
    else if test -c "$file_path"
        _fzf_report_file_type "$file_path" "character device file"
    else if test -b "$file_path"
        _fzf_report_file_type "$file_path" "block device file"
    else if test -S "$file_path"
        _fzf_report_file_type "$file_path" socket
    else if test -p "$file_path"
        _fzf_report_file_type "$file_path" "named pipe"
    else
        echo "$file_path doesn't exist." >&2
    end
end

function _fzf_report_diff_type --argument-names diff_type --description "打印带边框的彩色标题（用于 git diff 输出前）"
    set -f repeat_count (math 2 + (string length $diff_type))
    set -f line (string repeat --count $repeat_count ─)
    set_color yellow
    echo ╭$line╮
    echo "│ $diff_type │"
    echo ╰$line╯
    set_color normal
end

function _fzf_preview_changed_file --argument-names path_status --description "显示 git status 中指定文件的 diff"
    set -f path (string unescape (string sub --start 4 $path_status))
    set -f index_status (string sub --length 1 $path_status)
    set -f working_tree_status (string sub --start 2 --length 1 $path_status)
    set -f diff_opts --color=always

    if test $index_status = '?'
        _fzf_report_diff_type Untracked
        _fzf_preview_file $path
    else if contains {$index_status}$working_tree_status DD AU UD UA DU AA UU
        _fzf_report_diff_type Unmerged
        git diff $diff_opts -- $path
    else
        if test $index_status != ' '
            _fzf_report_diff_type Staged
            if test $index_status = R
                set -f orig_and_new_path (string split --max 1 -- ' -> ' $path)
                git diff --staged $diff_opts -- $orig_and_new_path[1] $orig_and_new_path[2]
                set path $orig_and_new_path[2]
            else
                git diff --staged $diff_opts -- $path
            end
        end
        if test $working_tree_status != ' '
            _fzf_report_diff_type Unstaged
            git diff $diff_opts -- $path
        end
    end
end

function _fzf_extract_var_info --argument-names variable_name set_show_output --description "从 set --show 输出中提取指定变量的信息"
    string match --regex "^\\\$$variable_name(?::|\[).*" <$set_show_output |
        string replace --regex "^\\\$$variable_name(?:: )?" '' |
        string replace --regex ": \|(.*)\|" ' $1'
end

# ─────────────────────────────────────────────────────────────────────────────
# 主功能函数
# ─────────────────────────────────────────────────────────────────────────────

function git_log --description "模糊搜索 git log，选中后将完整 commit hash 插入命令行"
    if not git rev-parse --git-dir >/dev/null 2>&1
        echo 'gl: Not in a git repository.' >&2
        return 1
    end

    if not set --query fzf_git_log_format
        set -f fzf_git_log_format '%C(bold blue)%h%C(reset) - %C(cyan)%ad%C(reset) %C(yellow)%d%C(reset) %C(normal)%s%C(reset)  %C(dim normal)[%an]%C(reset)'
    end

    set -f preview_cmd 'git show --color=always --stat --patch {1}'
    if set --query fzf_diff_highlighter
        set preview_cmd "$preview_cmd | $fzf_diff_highlighter"
    end

    set -f selected_log_lines (
        git log --no-show-signature --color=always --format=format:$fzf_git_log_format --date=short |
        _fzf_wrapper --ansi \
            --multi \
            --scheme=history \
            --prompt="Git Log> " \
            --preview=$preview_cmd \
            --query=(commandline --current-token) \
            $fzf_git_log_opts
    )
    if test $status -eq 0
        for line in $selected_log_lines
            set -f abbreviated_commit_hash (string split --field 1 " " $line)
            set -f full_commit_hash (git rev-parse $abbreviated_commit_hash)
            set -f --append commit_hashes $full_commit_hash
        end
        commandline --current-token --replace (string join ' ' $commit_hashes)
    end

    commandline --function repaint
end

function git_status --description "模糊搜索 git status，选中后将文件路径插入命令行"
    if not git rev-parse --git-dir >/dev/null 2>&1
        echo 'gs: Not in a git repository.' >&2
        return 1
    end

    set -f preview_cmd '_fzf_preview_changed_file {}'
    if set --query fzf_diff_highlighter
        set preview_cmd "$preview_cmd | $fzf_diff_highlighter"
    end

    set -f selected_paths (
        git -c color.status=always status --short |
        _fzf_wrapper --ansi \
            --multi \
            --prompt="Git Status> " \
            --query=(commandline --current-token) \
            --preview=$preview_cmd \
            --nth="2.." \
            $fzf_git_status_opts
    )
    if test $status -eq 0
        set -f cleaned_paths
        for path in $selected_paths
            if test (string sub --length 1 $path) = R
                set --append cleaned_paths (string split -- "-> " $path)[-1]
            else
                set --append cleaned_paths (string sub --start=4 $path)
            end
        end
        commandline --current-token --replace -- (string join ' ' $cleaned_paths)
    end

    commandline --function repaint
end

function git_branch --description "模糊搜索本地 git 分支，按 Enter 切换到选中分支"
    if not git rev-parse --git-dir >/dev/null 2>&1
        echo 'gb: Not in a git repository.' >&2
        return 1
    end

    # 当前分支名（用于在预览中高亮标注）
    set -f current_branch (git branch --show-current)

    set -f selected_branch (
        git branch --color=always |
        _fzf_wrapper --ansi \
            --prompt="Git Branch> " \
            --preview="git log --oneline --color=always --max-count=20 (string trim -- {} | string replace -r '^\* ' '')" \
            --preview-window="right:60%:wrap" \
            --header="current: $current_branch  |  Enter: checkout" \
            $fzf_git_branch_opts
    )

    if test $status -eq 0
        # 去掉前缀空格和 "* "（当前分支标记）
        set -f branch_name (string trim -- $selected_branch | string replace -r '^\* ' '')
        git checkout $branch_name
    end
end

function fp --description "模糊搜索运行中的进程，选中后将 PID 插入命令行"
    set -f ps_cmd (command -v ps || echo "ps")
    set -f ps_preview_fmt (string join ',' 'pid' 'ppid=PARENT' 'user' '%cpu' 'rss=RSS_IN_KB' 'start=START_TIME' 'command')

    set -f processes_selected (
        $ps_cmd -A -opid,command |
        _fzf_wrapper --multi \
            --prompt="Processes> " \
            --query (commandline --current-token) \
            --ansi \
            --header-lines=1 \
            --preview="$ps_cmd -o '$ps_preview_fmt' -p {1} || echo 'Cannot preview {1} because it exited.'" \
            --preview-window="bottom:4:wrap:border-rounded" \
            $fzf_processes_opts
    )

    if test $status -eq 0
        for process in $processes_selected
            set -f --append pids_selected (string split --no-empty --field=1 -- " " $process)
        end
        commandline --current-token --replace -- (string join ' ' $pids_selected)
    end

    commandline --function repaint
end

# ==============================================================================
# fs = 搜索【文件内容】（动态搜索 | 不匹配文件名 | 回车 nvim 跳转到匹配行）
# ==============================================================================
function fs --description "fzf 搜索文件内容，不匹配文件名，回车nvim跳转行"
    fd --type f --hidden --follow --exclude .git . 2>/dev/null | _fzf_wrapper \
        --ansi \
        --disabled \
        --prompt="Content Search > " \
        --preview-window="right:60%" \
        --preview="rg -n --color=always -C 3 '{q}' {} 2>/dev/null" \
        --bind="change:reload:rg -l '{q}' 2>/dev/null || true" \
        --bind="enter:execute(nvim +(rg -n '{q}' {} | head -n1 | cut -d: -f1) {})+abort"
end

# ==============================================================================
# ff = 搜索【文件名】（模糊匹配路径/文件名 | 回车 nvim 打开）
# ==============================================================================
function ff --description "fzf 搜索文件名，模糊匹配，回车nvim打开文件"
    fd --type f --hidden --follow --exclude .git . 2>/dev/null | _fzf_wrapper \
        --ansi \
        --prompt="File Search > " \
        --preview="bat --style=numbers --color=always {} 2>/dev/null || cat {}" \
        --bind="enter:execute(nvim {})+abort"
end
