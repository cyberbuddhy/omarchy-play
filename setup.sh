#!/bin/bash
# omarchy-play setup — run automatically by Service.qml on plugin load.
# Usage: setup.sh [plugin-dir]
#
# Idempotent: installs the `play` binary, merges the Super+Space menu
# entries, and writes the default provider only when missing. Safe to run
# any number of times; never touches anything else in the user's config.

set -euo pipefail

PLUGIN_DIR="${1:-$(cd "$(dirname "$0")" && pwd)}"
BIN_DIR="$HOME/.local/bin"
MENU_FILE="$HOME/.config/omarchy/extensions/omarchy-menu.jsonc"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/play"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/play"
LOG="$STATE_DIR/setup.log"

mkdir -p "$BIN_DIR" "$CONFIG_DIR" "$STATE_DIR" "$(dirname "$MENU_FILE")"
exec >>"$LOG" 2>&1
echo "--- setup $(date '+%F %T') plugin=$PLUGIN_DIR ---"

# 1. play binary.
if [[ -f $PLUGIN_DIR/play ]]; then
  cp "$PLUGIN_DIR/play" "$BIN_DIR/play"
  chmod +x "$BIN_DIR/play"
  echo "binary: $BIN_DIR/play"
fi

# 2. Default provider (free first). Never overwrites an existing choice.
if [[ ! -f $CONFIG_DIR/provider ]]; then
  printf 'ytmusic\n' >"$CONFIG_DIR/provider"
  echo "provider: ytmusic (default)"
else
  echo "provider: kept $(cat "$CONFIG_DIR/provider")"
fi

# 3. Super+Space menu entries. The menu file is JSONC (comments allowed),
# so merge textually: insert before the final closing brace, preserving
# every existing line. Skips when the entries already exist.
merge_menu() {
  [[ -f $MENU_FILE ]] || printf '{\n}\n' >"$MENU_FILE"
  grep -q '"music.play"' "$MENU_FILE" && { echo "menu: entries already present"; return 0; }
  python3 - "$MENU_FILE" <<'PYEOF'
import re
import sys

path = sys.argv[1]
with open(path, encoding="utf-8") as f:
    text = f.read()

entries = (
    '  "music": {"icon":"","label":"Music"},\n'
    '  "music.play": {"icon":"","label":"Play music","action":"play --prompt"},\n'
    '  "music.stop": {"icon":"","label":"Stop music","action":"play --stop"}\n'
)

# Strip full-line // comments to judge whether the object already has entries.
stripped = re.sub(r'(?m)^[ \t]*//.*$', '', text)
has_entries = re.search(r'"[^"]+"\s*:', stripped) is not None

lines = text.rstrip("\n").split("\n")
# Find the final closing brace of the root object.
idx = None
for i in range(len(lines) - 1, -1, -1):
    if re.match(r'^[ \t]*\}[ \t]*$', lines[i]):
        idx = i
        break
if idx is None:
    print("menu: no root closing brace found, skipped", flush=True)
    sys.exit(0)

if not has_entries:
    lines[idx:idx] = [entries.rstrip("\n")]
else:
    # Append a comma to the previous real content line when it lacks one.
    for j in range(idx - 1, -1, -1):
        s = lines[j].rstrip()
        if not s or s.lstrip().startswith("//"):
            continue
        if not s.endswith(("{", "[", ",")):
            lines[j] = s + ","
        break
    lines[idx:idx] = [entries.rstrip("\n")]

with open(path, "w", encoding="utf-8") as f:
    f.write("\n".join(lines) + "\n")
print("menu: entries added", flush=True)
PYEOF
}

if command -v python3 >/dev/null 2>&1; then
  merge_menu
elif command -v jq >/dev/null 2>&1 && jq empty "$MENU_FILE" 2>/dev/null; then
  tmp=$(mktemp)
  jq '. * {"music": {"icon":"","label":"Music"},
             "music.play": {"icon":"","label":"Play music","action":"play --prompt"},
             "music.stop": {"icon":"","label":"Stop music","action":"play --stop"}}' \
    "$MENU_FILE" >"$tmp"
  cat "$tmp" >"$MENU_FILE"
  rm -f "$tmp"
  echo "menu: entries added (jq)"
else
  echo "menu: skipped (need python3 or jq)"
fi

if command -v notify-send >/dev/null 2>&1; then
  notify-send -a "play" -i audio-x-generic "Play ready" "Super+Space, type Play music" 2>/dev/null || true
fi
echo "done"
