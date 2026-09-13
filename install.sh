#!/usr/bin/env bash
# Hermes Pixel Office — Embedded Desktop Pane. One-command installer.
# Docks the live hermes-pixel-office office inside the Hermes desktop app.
# Requires the backend plugin (teknium1/hermes-pixel-office) to already be
# installed and enabled — this script does NOT install that part.
#
# Usage:  curl -fsSL https://raw.githubusercontent.com/mistrysiddh/hermes-pixel-office-embedded/main/install.sh | bash
set -euo pipefail

REPO_URL="https://github.com/mistrysiddh/hermes-pixel-office-embedded"

if [ -n "${HERMES_HOME:-}" ]; then
  HOME_DIR="$HERMES_HOME"
elif [ -d "$HOME/AppData/Local/hermes" ]; then
  HOME_DIR="$HOME/AppData/Local/hermes"
else
  HOME_DIR="$HOME/.hermes"
fi

echo "Hermes Pixel Office — Embedded Desktop Pane"
echo ""
echo "This will install a desktop plugin into:"
echo "  $HOME_DIR/desktop-plugins/pixel-office-view/"
echo ""
echo "It docks the live hermes-pixel-office office as a pane inside the"
echo "Hermes desktop app. Requires the hermes-pixel-office backend plugin"
echo "separately (the installer will tell you if it's missing)."
echo ""

# Prompt when a real terminal is attached to /dev/tty (works even through
# `curl | bash`, where stdin is the piped script, not the user's keyboard).
# Skips automatically in non-interactive contexts (CI, scripts), with
# PIXEL_OFFICE_YES=1 set, or when /dev/tty exists but can't actually be
# opened (seen on some git-bash/MSYS builds on Windows).
if [ -z "${PIXEL_OFFICE_YES:-}" ] && { exec 3<>/dev/tty; } 2>/dev/null; then
  read -r -p "Proceed with install? [Y/n] " REPLY <&3
  exec 3<&-
  case "$REPLY" in
    [nN]*)
      echo "Aborted — nothing was installed."
      exit 0
      ;;
  esac
fi

echo "Installing into: $HOME_DIR"

DESKTOP_PLUGIN_DIR="$HOME_DIR/desktop-plugins/pixel-office-view"
mkdir -p "$DESKTOP_PLUGIN_DIR"

if [ -n "${LOCALAPPDATA:-}" ]; then
  TMP_DIR="$LOCALAPPDATA/Temp/pixel-office-view-install-$$"
else
  TMP_DIR=$(mktemp -d)
fi
rm -rf "$TMP_DIR"

echo "→ Cloning desktop pane..."
git clone --depth 1 "$REPO_URL" "$TMP_DIR" >/dev/null 2>&1
cp "$TMP_DIR/desktop-plugins/pixel-office-view/plugin.js" "$DESKTOP_PLUGIN_DIR/"
rm -rf "$TMP_DIR"

echo ""
if [ -d "$HOME_DIR/plugins/pixel-office" ]; then
  echo "✅ Installed! Backend plugin already present — you're all set."
else
  cat <<'EOF'
⚠️  Backend not found. This pane needs the hermes-pixel-office backend
   plugin (serves http://127.0.0.1:8113) — install it first:

     git clone https://github.com/teknium1/hermes-pixel-office ~/.hermes/plugins/pixel-office
     hermes config set plugins.enabled '["pixel-office"]'

   (Windows: clone to %LOCALAPPDATA%\hermes\plugins\pixel-office)

✅ Desktop pane installed.
EOF
fi

cat <<'EOF'

Next steps:
  1. Fully quit and relaunch the Hermes desktop app (plugins load at process start).
  2. Do anything in a session — the office starts serving once the first event fires.
  3. You'll see a "PIXEL OFFICE" pane docked in the app, live.

Troubleshooting: hermes logs --level info | grep pixel-office
EOF
