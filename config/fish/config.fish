if status is-interactive
    # Commands to run in interactive sessions can go here
end

# basic
set -g fish_greeting ""
set -gx TERM xterm-256color
set -gx EDITOR nvim

# alias
alias lzg='lazygit'
alias lzd='lazydocker'
alias v="nvim"
alias nvimdiff="nvim -d"

alias rm_real="rm"
alias rm='trash'



alias ls="eza --icons=auto"
alias ll="eza --icons=auto --git -h -H -l"


# fzf
fzf --fish | source
set -gx FZF_DEFAULT_COMMAND 'fd --type f --strip-cwd-prefix --hidden --follow --exclude .git'
set -gx FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"

set -gx FZF_DEFAULT_OPTS "--height 40% --layout=reverse --border --preview 'bat --style=numbers --color=always --line-range :500 {}' --preview-window 'right,60%,border-left'"
set -gx FZF_CTRL_R_OPTS "--preview-window hidden"

# source files
if test -f $HOME/.config/fish/abbrs.fish
    source $HOME/.config/fish/abbrs.fish
end
if test -f $HOME/.config/fish/git.fish
    source $HOME/.config/fish/git.fish
end

# starship
starship init fish | source
# zoxide
zoxide init fish | source
# fnm
fnm completions --shell fish | source
