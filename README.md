# Hermes Pixel Office — Embedded

A pixel-art virtual office for [Hermes Agent](https://github.com/NousResearch/hermes-agent) —
every agent session and every `delegate_task` subagent becomes an animated
pixel character at a desk. This repo packages the original
[`teknium1/hermes-pixel-office`](https://github.com/teknium1/hermes-pixel-office)
backend **plus a desktop pane** that docks it live inside the Hermes app
itself — no separate browser tab required.

![office](screenshot.png)

## What you get

- **Backend plugin** (`plugins/pixel-office`) — the original hermes-pixel-office
  server: watches lifecycle hooks (tool calls, sessions, subagents, approvals)
  and serves a live office page + JSON state at `http://127.0.0.1:8113`.
- **Embedded desktop pane** (`desktop-plugins/pixel-office-view`) — docks that
  same live office directly inside the Hermes desktop app as a pane, plus a
  statusbar chip showing the live agent count. No demo data, no browser —
  just your real sessions.

## Install

### One command (macOS / Linux / WSL / git-bash on Windows)

```bash
curl -fsSL https://raw.githubusercontent.com/mistrysiddh/hermes-pixel-office-embedded/main/install.sh | bash
```

### One command (Windows PowerShell)

```powershell
iwr -useb https://raw.githubusercontent.com/mistrysiddh/hermes-pixel-office-embedded/main/install.ps1 | iex
```

Then:

1. **Fully quit and relaunch** the Hermes desktop app (plugins load at process
   start — an already-running session won't pick it up).
2. Do anything in a session. The office starts serving on the first event.
3. Look for the **"PIXEL OFFICE"** pane, docked live in the app.

## Manual install

```bash
# Backend
git clone https://github.com/mistrysiddh/hermes-pixel-office-embedded /tmp/pixel-office-src
cp -r /tmp/pixel-office-src/{__init__.py,plugin.yaml,demo_feed.py,LICENSE,web} \
  ~/.hermes/plugins/pixel-office/    # or $HERMES_HOME/plugins/pixel-office/

# Desktop pane
mkdir -p ~/.hermes/desktop-plugins/pixel-office-view
cp /tmp/pixel-office-src/desktop-plugins/pixel-office-view/plugin.js \
  ~/.hermes/desktop-plugins/pixel-office-view/

hermes config set plugins.enabled '["pixel-office"]'
```

Windows: same idea, Hermes home is usually `%LOCALAPPDATA%\hermes`.

## What you'll see

- One character per Hermes session (CLI, Telegram, Discord, cron, desktop, …) —
  characters walk in, sit at a desk, and walk out when the session ends.
- Gold-collared characters are `delegate_task` subagents, labeled by goal.
- Activity animations: typing (`write_file`/`patch`), reading (`read_file`/
  `search_files`), browsing (web tools), terminal work (green monitor
  flicker), delegating (pointing).
- Dangerous-command approvals: red "!" speech bubble + "needs input!" +
  header counter.
- Optional sound toggle (chime on approval-needed / subagent-finished).
- Sessions from ALL Hermes processes on the machine share one office.
- **This fork:** the same live office, docked as a native pane inside the
  desktop app — plus a statusbar chip with the live agent count.

Visual only: the plugin observes lifecycle hooks — it never blocks, vetoes,
or transforms anything, adds zero model-tool footprint, and does not touch
the prompt cache.

## Configuration (optional)

`~/.hermes/config.yaml`:

```yaml
plugins:
  enabled:
    - pixel-office
  entries:
    pixel-office:
      port: 8113        # change if something else owns 8113
```

## Uninstall

```bash
curl -fsSL https://raw.githubusercontent.com/mistrysiddh/hermes-pixel-office-embedded/main/uninstall.sh | bash
```

or manually:

```bash
rm -rf ~/.hermes/plugins/pixel-office ~/.hermes/desktop-plugins/pixel-office-view
# then remove "pixel-office" from plugins.enabled in config.yaml
```

## Credits

Backend plugin is [teknium1/hermes-pixel-office](https://github.com/teknium1/hermes-pixel-office),
MIT licensed. The embedded desktop pane is an addition on top of it.

## License

MIT
