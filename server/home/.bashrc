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
eval "$(starship init bash)"
eval "$(zoxide init bash)"
eval "$(fnm env)"
source /Users/wanghl/.shell/.shell_alias
source /Users/wanghl/.shell/.shell_images
source /Users/wanghl/.shell/.shell_utils
