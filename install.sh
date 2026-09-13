#!/usr/bin/env bash
# Hermes Pixel Office + Embedded View — one-command installer.
# Usage:  curl -fsSL https://raw.githubusercontent.com/<OWNER>/<REPO>/main/install.sh | bash
set -euo pipefail

REPO_URL="https://github.com/mistrysiddh/hermes-pixel-office-embedded"
RAW_BASE="https://raw.githubusercontent.com/mistrysiddh/hermes-pixel-office-embedded/main"

# Resolve Hermes home the same way Hermes itself does.
if [ -n "${HERMES_HOME:-}" ]; then
  HOME_DIR="$HERMES_HOME"
elif [ -d "$HOME/AppData/Local/hermes" ]; then
  HOME_DIR="$HOME/AppData/Local/hermes"
else
  HOME_DIR="$HOME/.hermes"
fi

echo "Installing into: $HOME_DIR"

PLUGIN_DIR="$HOME_DIR/plugins/pixel-office"
DESKTOP_PLUGIN_DIR="$HOME_DIR/desktop-plugins/pixel-office-view"

mkdir -p "$PLUGIN_DIR" "$DESKTOP_PLUGIN_DIR"

echo "→ Cloning backend plugin (pixel-office)..."
TMP_DIR=$(mktemp -d)
git clone --depth 1 "$REPO_URL" "$TMP_DIR" >/dev/null 2>&1

cp "$TMP_DIR/__init__.py" "$PLUGIN_DIR/"
cp "$TMP_DIR/plugin.yaml" "$PLUGIN_DIR/"
cp "$TMP_DIR/demo_feed.py" "$PLUGIN_DIR/"
cp "$TMP_DIR/LICENSE" "$PLUGIN_DIR/"
cp -r "$TMP_DIR/web" "$PLUGIN_DIR/"

echo "→ Installing desktop embedded pane (pixel-office-view)..."
cp "$TMP_DIR/desktop-plugins/pixel-office-view/plugin.js" "$DESKTOP_PLUGIN_DIR/"

rm -rf "$TMP_DIR"

echo "→ Enabling backend plugin in config.yaml..."
CONFIG="$HOME_DIR/config.yaml"
if [ -f "$CONFIG" ] && grep -q "pixel-office" "$CONFIG" 2>/dev/null; then
  echo "  pixel-office already referenced in config.yaml — skipping"
elif command -v hermes >/dev/null 2>&1; then
  hermes config set plugins.enabled '["pixel-office"]' 2>/dev/null || true
else
  echo "  NOTE: add this to $CONFIG manually if not already present:"
  echo "    plugins:"
  echo "      enabled:"
  echo "        - pixel-office"
fi

cat <<'EOF'

✅ Installed!

Next steps:
  1. Fully quit and relaunch the Hermes desktop app (plugins load at process start).
  2. Do anything in a session — the office starts serving once the first event fires.
  3. You'll see a "PIXEL OFFICE" pane docked in the app, live — no browser tab needed.
     (Standalone view is still available at http://127.0.0.1:8113 if you want it.)

Troubleshooting: hermes logs --level info | grep pixel-office
EOF
