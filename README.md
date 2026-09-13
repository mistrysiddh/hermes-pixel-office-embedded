# Hermes Pixel Office — Embedded Desktop Pane

Docks the live [Hermes Pixel Office](https://github.com/teknium1/hermes-pixel-office)
inside the Hermes desktop app itself — as a real pane, no separate browser
tab. Also adds a statusbar chip showing the live agent count.

![office](screenshot.png)

This repo is **just the desktop pane**. It talks to the existing
`hermes-pixel-office` backend plugin (the one that watches lifecycle hooks
and serves `http://127.0.0.1:8113`) — install that first if you don't have
it yet.

## Prerequisite: the backend plugin

```bash
git clone https://github.com/teknium1/hermes-pixel-office ~/.hermes/plugins/pixel-office
hermes config set plugins.enabled '["pixel-office"]'
```

Windows: clone to `%LOCALAPPDATA%\hermes\plugins\pixel-office` instead.

## Install the desktop pane

### One command (macOS / Linux / WSL / git-bash on Windows)

```bash
curl -fsSL https://raw.githubusercontent.com/mistrysiddh/hermes-pixel-office-embedded/main/install.sh | bash
```

### One command (Windows PowerShell)

```powershell
iwr -useb https://raw.githubusercontent.com/mistrysiddh/hermes-pixel-office-embedded/main/install.ps1 | iex
```

The installer checks whether the backend plugin is already present and
tells you if it's missing — it only ever touches `desktop-plugins/`.

Then:

1. **Fully quit and relaunch** the Hermes desktop app (plugins load at
   process start — an already-running session won't pick it up).
2. Do anything in a session. The office starts serving on the first event.
3. Look for the **"PIXEL OFFICE"** pane, docked live in the app, plus an
   `office (N)` chip in the statusbar.

## Manual install

```bash
mkdir -p ~/.hermes/desktop-plugins/pixel-office-view
curl -fsSL https://raw.githubusercontent.com/mistrysiddh/hermes-pixel-office-embedded/main/desktop-plugins/pixel-office-view/plugin.js \
  -o ~/.hermes/desktop-plugins/pixel-office-view/plugin.js
```

Windows: same idea, Hermes home is usually `%LOCALAPPDATA%\hermes`.

## What you'll see

- Same live office as the standalone page — real sessions, real subagents,
  real activity animations (typing, reading, browsing, terminal, delegating),
  approval flags — just docked inside the app instead of a browser tab.
- A statusbar chip (`🟢 office (N)`) showing the live agent count; click it
  for a quick toast.

Visual only — the pane just embeds the existing office page via an iframe
and polls `/state` for the chip. It never blocks, vetoes, or transforms
anything Hermes does.

## Uninstall

```bash
curl -fsSL https://raw.githubusercontent.com/mistrysiddh/hermes-pixel-office-embedded/main/uninstall.sh | bash
```

or manually:

```bash
rm -rf ~/.hermes/desktop-plugins/pixel-office-view
```

This only removes the pane — the backend plugin is untouched.

## Credits

The office itself — backend, hook watching, sprite rendering — is
[teknium1/hermes-pixel-office](https://github.com/teknium1/hermes-pixel-office),
MIT licensed. This repo just adds a desktop pane that embeds it.

## License

MIT
