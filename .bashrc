HISTCONTROL=ignoredups:ignorespace
HISTSIZE=100000
HISTFILESIZE=2000000
shopt -s histappend

export TERM=xterm-256color

txtgrn='\[\e[0;32m\]' # Green
txtpur='\[\e[0;35m\]' # Purple
txtwht='\[\e[0;37m\]' # White

# Prompt colours
atC="${txtpur}"
nameC="${txtpur}"
hostC="${txtpur}"
pathC="${txtgrn}"
gitC="${txtpur}"
pointerC="${txtgrn}"
normalC="${txtwht}"

function gitPrompt {
  command -v __git_ps1 >/dev/null && __git_ps1 " (%s)"
}

# Patent Pending Prompt
export PS1="${nameC}\u${atC}@${hostC}\h:${pathC}\w${gitC}\$(gitPrompt)${pointerC}▶${normalC} "

if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
  . /etc/bash_completion
fi
