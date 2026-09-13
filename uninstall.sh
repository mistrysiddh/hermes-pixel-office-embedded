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
rm -rf "$HOME_DIR/plugins/pixel-office"
rm -rf "$HOME_DIR/desktop-plugins/pixel-office-view"

echo "✅ Removed. Remove 'pixel-office' from plugins.enabled in $HOME_DIR/config.yaml if present, then relaunch Hermes."
