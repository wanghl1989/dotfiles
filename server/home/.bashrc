# Minimal interactive Bash configuration for servers.
# It only uses Bash and Readline built-ins; no plugins or Git integration.

# Do nothing for non-interactive shells.
case $- in
  *i*) ;;
  *) return ;;
esac

# History
HISTCONTROL=ignoreboth:erasedups
HISTSIZE=10000
HISTFILESIZE=20000
shopt -s histappend
shopt -s checkwinsize
shopt -s cmdhist

# Keep long paths compact in the prompt.
PROMPT_DIRTRIM=3

# Material Deep Ocean inspired prompt. Fall back to plain text when colors are
# unavailable. \[ and \] keep Bash's cursor-position calculation correct.
if [[ ${TERM:-dumb} != dumb ]]; then
  _prompt_reset='\[\e[0m\]'
  _prompt_cyan='\[\e[38;5;117m\]'
  _prompt_blue='\[\e[38;5;111m\]'
  _prompt_green='\[\e[38;5;149m\]'
  PS1="${_prompt_cyan}\u@\h${_prompt_reset} ${_prompt_blue}\w${_prompt_green}\\$ ${_prompt_reset}"
else
  PS1='\u@\h \w\$ '
fi

# Built-in Readline completion:
#   Tab       select the next candidate
#   Shift-Tab select the previous candidate when supported by Readline
bind 'set completion-ignore-case on'
bind 'set completion-map-case on'
bind 'set show-all-if-ambiguous on'
bind 'set mark-directories on'
bind 'set colored-stats on' 2>/dev/null
bind 'set menu-complete-display-prefix on' 2>/dev/null
bind '"\t": menu-complete'
if bind -q menu-complete-backward >/dev/null 2>&1; then
  bind '"\e[Z": menu-complete-backward'
else
  # Older Readline versions can still cycle forward with Shift-Tab.
  bind '"\e[Z": menu-complete'
fi

# Small, portable conveniences. Color is enabled only when supported.
if ls --color=auto -d . >/dev/null 2>&1; then
  alias ls='ls --color=auto'
fi
if printf 'x\n' | grep --color=auto x >/dev/null 2>&1; then
  alias grep='grep --color=auto'
fi
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'


# ------------------------------
# 设置proxy
# ------------------------------
proxy() {
    case "$1" in
        # 开启全局终端代理（所有命令生效：curl/git/npm/brew等）
        on)
            if [ -z "${PROXY_URL}" ]; then
                echo "请设置PROXY_URL"
                echo "      Example： export PROXY_URL=127.0.0.1:7890"
                proxy off
                return 1
            fi
            export http_proxy=$PROXY_URL
            export https_proxy=$PROXY_URL
            export all_proxy=$PROXY_URL
            # 兼容大写环境变量（部分软件只识别大写）
            export HTTP_PROXY=$PROXY_URL
            export HTTPS_PROXY=$PROXY_URL
            export ALL_PROXY=$PROXY_URL
            echo "✅ 终端全局代理已开启：${PROXY_URL}"
            ;;

        # 关闭全局终端代理
        off)
            unset http_proxy https_proxy all_proxy
            unset HTTP_PROXY HTTPS_PROXY ALL_PROXY
            echo "❌ 终端全局代理已关闭"
            ;;

        # 查看当前代理状态
        show)
            echo "📌 当前终端代理配置："
            echo "http_proxy:  $http_proxy"
            echo "https_proxy: $https_proxy"
            echo "all_proxy:   $all_proxy"
            ;;

        # 帮助提示
        *)
            echo "用法：proxy [命令]"
            echo "  on    开启终端全局代理，需设置PROXY_URL"
            echo "  off   关闭终端全局代理"
            echo "  show  查看当前代理状态"
            ;;
    esac
}


# ------------------------------
# conda 手动启用
# ------------------------------
con() {
    # 检查CONDA_HOME
    if [ -z "${CONDA_HOME}" ] || [ ! -d "${CONDA_HOME}" ]; then
        echo "错误: 请先设置Conda安装路径"
        echo "示例: export CONDA_HOME=$HOME/miniconda3"
        return 1
    fi
    local current_shell=$(basename "$SHELL")

    local __conda_setup
    # 根据Shell类型执行对应Hook
    case "$current_shell" in
        bash)
            __conda_setup="$("${CONDA_HOME}/bin/conda" 'shell.bash' 'hook' 2>/dev/null)"
            ;;
        zsh)
            __conda_setup="$("${CONDA_HOME}/bin/conda" 'shell.zsh' 'hook' 2>/dev/null)"
            ;;
        *)
            echo "⚠️ 未适配 $current_shell，使用基础PATH模式"
            export PATH="${CONDA_HOME}/bin:$PATH"
            return 0
            ;;
    esac

    # 加载Conda环境（官方标准方式）
    if [ $? -eq 0 ]; then
        eval "$__conda_setup"
    else
        # 兼容旧版Conda
        if [ -f "${CONDA_HOME}/etc/profile.d/conda.sh" ]; then
            . "${CONDA_HOME}/etc/profile.d/conda.sh"
        else
            export PATH="${CONDA_HOME}/bin:$PATH"
        fi
    fi

    # 清理临时变量
    unset __conda_setup
    return 0
}

alias tl="tmux list-session"
alias ta="tmux attach -t"
alias tk="tmux kill-session -t"
alias tn="tmux new -s"

