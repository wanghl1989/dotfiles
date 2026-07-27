#!/usr/bin/env bash
set -euo pipefail

REPO="https://raw.githubusercontent.com/oleg-koval/kitty-agent-status/main"
DEST="${KAS_HOME:-$HOME/.config/kitty/agent-status}"
DO_CLAUDE=1
for a in "$@"; do [ "$a" = "--no-claude" ] && DO_CLAUDE=0; done

command -v kitten >/dev/null 2>&1 || echo "  (warning: 'kitten' not on PATH — colors only show inside kitty)"

if [ "$DO_CLAUDE" = 1 ]; then
  SETTINGS="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/settings.json"
  if command -v python3 >/dev/null 2>&1; then
    echo "→ wiring Claude Code hooks in $SETTINGS"
    python3 - "$DEST/agent-status.sh" "$SETTINGS" <<'PY'
import json, os, sys
script, settings = sys.argv[1], sys.argv[2]
os.makedirs(os.path.dirname(settings), exist_ok=True)
cfg = {}
if os.path.exists(settings):
    try:
        cfg = json.load(open(settings))
    except Exception:
        os.replace(settings, settings + ".bak")
        print(f"  (existing settings.json was invalid; backed up to {settings}.bak)")
h = cfg.setdefault("hooks", {})
def wire(event, arg, matcher=None):
    grps = h.setdefault(event, [])
    for g in grps:
        for hk in g.get("hooks", []):
            if hk.get("command", "").startswith(script):
                return
    grp = {"hooks": [{"type": "command", "command": f"{script} {arg}"}]}
    if matcher:
        grp["matcher"] = matcher
    grps.append(grp)
wire("UserPromptSubmit", "working")
wire("Notification", "needs-input", "permission_prompt")  # amber only for blocking prompts, not idle
wire("Stop", "done")
json.dump(cfg, open(settings, "w"), indent=2); open(settings, "a").write("\n")
PY
  else
    echo "  (python3 not found — skipping Claude hooks; see README to add them by hand)"
  fi
fi

echo "✓ kitty-agent-status installed."
