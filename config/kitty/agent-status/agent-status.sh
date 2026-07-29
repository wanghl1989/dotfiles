#!/usr/bin/env bash
# kitty-agent-status — tint the current kitty tab to reflect a coding agent's state.
#
#   agent-status.sh working      # agent is busy
#   agent-status.sh needs-input  # agent wants you (waiting / finished a turn)
#   agent-status.sh done         # back to idle — revert to the default tab color
#
# Colors are overridable via env (hex like #1f6feb, a kitty color name, or NONE):
#   KAS_WORKING_BG   KAS_WORKING_FG
#   KAS_ATTENTION_BG KAS_ATTENTION_FG
#
# Outside kitty this is a silent no-op, so it is safe to call from any hook.
set -u

[ -z "${KITTY_WINDOW_ID:-}" ] && exit 0   # not inside kitty: nothing to color

case "${1:-idle}" in
  working)
    BG="#7daea3"; FG="#1d2021"; IFG="#928374" ;;
  needs-input|attention)
    BG="#e78a4e"; FG="#1d2021"; IFG="#928374";
    kitten notify -u critical "Agent Need input." >/dev/null 2>&1 || true;;
  done)
    BG="None"; FG="None"; IFG="None";
    kitten notify -u critical "Agent job is done." >/dev/null 2>&1 || true;;
  idle|reset|*)
    BG="None"; FG="None" IFG="None";;

esac

# set-tab-color targets the tab that contains this window. inactive_* is set too
# so the state stays visible when the tab is not focused (the whole point).
kitten @ set-tab-color -m "window_id:${KITTY_WINDOW_ID}" \
  "active_bg=${BG}" "active_fg=${FG}" "inactive_bg=${BG}" "inactive_fg=${IFG}" \
  >/dev/null 2>&1 || true

# if [ ${1:-idle} = "done" ]; then
# fi


