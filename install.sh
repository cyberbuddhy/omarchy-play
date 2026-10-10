#!/bin/bash
# omarchy-play installer: play binary + Super+Space menu entries + provider choice.
#
# The bar widget + dropdown panel work with zero config after
# `omarchy plugin add https://github.com/cyberbuddhy/omarchy-play.git --enable`.
# Run this script for the rest: the `play` command itself, Super+Space
# (Omarchy menu) entries, and an interactive music-provider choice.
#
# Safe to re-run: menu entries merge, nothing else in your config is touched.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
BIN_DIR="$HOME/.local/bin"
MENU_FILE="$HOME/.config/omarchy/extensions/omarchy-menu.jsonc"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/play"

mkdir -p "$BIN_DIR" "$CONFIG_DIR" "$(dirname "$MENU_FILE")"
cp "$REPO_DIR/play" "$BIN_DIR/play"
chmod +x "$BIN_DIR/play"
echo "Installed: $BIN_DIR/play"

# Merge Super+Space entries without touching anything else in the file.
if command -v jq >/dev/null 2>&1; then
  [[ -f $MENU_FILE ]] || echo '{}' >"$MENU_FILE"
  if jq empty "$MENU_FILE" 2>/dev/null; then
    tmp=$(mktemp)
    jq '. * {"music.play": {"icon": "", "label": "Play music", "action": "play --prompt"},
               "music.stop": {"icon": "", "label": "Stop music", "action": "play --stop"}}' \
      "$MENU_FILE" >"$tmp"
    cat "$tmp" >"$MENU_FILE"
    rm -f "$tmp"
    echo "Menu entries added: Play music, Stop music (Super+Space)"
  else
    echo "Skipping menu merge: $MENU_FILE is not strict JSON (has comments?); add the entries from the README manually." >&2
  fi
else
  echo "jq not found; skipping Super+Space menu entries." >&2
fi

# Provider choice: free options first, paid second.
provider=""
if command -v gum >/dev/null 2>&1 && [[ -t 0 && -t 1 ]]; then
  provider=$(printf 'YouTube Music (free)\nSpotify (needs the app or a browser)\n' \
    | gum choose --header="Music provider?") || true
  case "${provider:-}" in
    Spotify*) provider=spotify ;;
    *) provider=ytmusic ;;
  esac
fi
if [[ -z $provider ]]; then
  printf 'Music provider [1 = YouTube Music, free (default) | 2 = Spotify]: '
  read -r choice || true
  if [[ ${choice:-1} == 2 ]]; then
    provider=spotify
  else
    provider=ytmusic
  fi
fi
printf '%s\n' "$provider" >"$CONFIG_DIR/provider"
echo "Provider: $provider (saved to $CONFIG_DIR/provider; change anytime in the bar panel)"

echo "Done. No restart needed."
