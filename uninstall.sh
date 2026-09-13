#!/usr/bin/env bash
set -euo pipefail

if [ -n "${HERMES_HOME:-}" ]; then
  HOME_DIR="$HERMES_HOME"
elif [ -d "$HOME/AppData/Local/hermes" ]; then
  HOME_DIR="$HOME/AppData/Local/hermes"
else
  HOME_DIR="$HOME/.hermes"
fi

echo "Removing from: $HOME_DIR"
rm -rf "$HOME_DIR/desktop-plugins/pixel-office-view"

echo "✅ Removed the desktop pane. The backend plugin (pixel-office), if installed, is untouched."
