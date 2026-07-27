#!/usr/bin/env bash
# kitty-agent-status — Codex notify chain.
#
# Codex fires its `notify` program when a turn completes. Point it at this
# script to tint the kitty tab "needs-input" each time, then forward the exact
# arguments to whatever notify program you had before (so existing integrations
# keep working).
#
#   ~/.codex/config.toml:
#   notify = ["/path/to/kitty-agent-status/codex-notify.sh"]
#
# If you already had a notify program, keep it running by setting its path:
#   export CODEX_NOTIFY_FORWARD="/path/to/old/notify"
set -u

_dir="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" >/dev/null 2>&1 && pwd)"
"${KAS_BIN:-$_dir/agent-status.sh}" needs-input

FORWARD="${CODEX_NOTIFY_FORWARD:-}"
[ -n "$FORWARD" ] && [ -x "$FORWARD" ] && exec "$FORWARD" "$@"
exit 0
