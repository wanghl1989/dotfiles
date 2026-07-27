# kitty-agent-status — shell integration for bash and zsh.
# Tints the kitty tab while a coding agent runs as a foreground command, and
# reverts at the next prompt. Source this from your ~/.zshrc and/or ~/.bashrc.
#
# Which commands count as agents is a regex, override before sourcing to taste:
#   export KAS_AGENT_RE='^(codex|gemini|cursor-agent|my-agent)([[:space:]]|$)'
#
# Claude Code is intentionally NOT in the default list — its own hooks drive
# finer per-turn state. Add it here if you only use the shell integration.

[ -z "${KITTY_WINDOW_ID:-}" ] && return 0 2>/dev/null

# Locate agent-status.sh relative to this file (layout is preserved on install).
if [ -n "${ZSH_VERSION:-}" ]; then
  _kas_self="${(%):-%x}"
else
  _kas_self="${BASH_SOURCE[0]}"
fi
_kas_dir="$(cd "$(dirname "$_kas_self")/.." >/dev/null 2>&1 && pwd)"
: "${KAS_BIN:=$_kas_dir/agent-status.sh}"
: "${KAS_AGENT_RE:=^(codex|gemini|cursor-agent|aider|opencode|crush|goose)([[:space:]]|$)}"

if [ -n "${ZSH_VERSION:-}" ]; then
  autoload -Uz add-zsh-hook
  _kas_preexec() { [[ "$1" =~ $KAS_AGENT_RE ]] && { "$KAS_BIN" working; _kas_active=1; }; }
  _kas_precmd()  { [[ -n "${_kas_active:-}" ]] && { "$KAS_BIN" done; unset _kas_active; }; }
  add-zsh-hook preexec _kas_preexec
  add-zsh-hook precmd  _kas_precmd

elif [ -n "${BASH_VERSION:-}" ]; then
  _kas_preexec() {
    local cmd="$BASH_COMMAND"                     # capture first — it mutates as we run
    [ -n "${COMP_LINE:-}" ] && return             # ignore tab-completion
    case "$cmd" in _kas_*) return ;; esac
    if [[ "$cmd" =~ $KAS_AGENT_RE ]]; then
      "$KAS_BIN" working
      _kas_active=1
    fi
  }
  _kas_precmd() { [ -n "${_kas_active:-}" ] && { "$KAS_BIN" done; unset _kas_active; }; }
  trap '_kas_preexec' DEBUG
  case "${PROMPT_COMMAND:-}" in
    *_kas_precmd*) : ;;
    *) PROMPT_COMMAND="_kas_precmd${PROMPT_COMMAND:+; $PROMPT_COMMAND}" ;;
  esac
fi
