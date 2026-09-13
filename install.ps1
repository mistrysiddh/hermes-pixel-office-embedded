# Hermes Pixel Office — Embedded Desktop Pane (Windows installer).
# Docks the live hermes-pixel-office office inside the Hermes desktop app.
# Requires the backend plugin (teknium1/hermes-pixel-office) to already be
# installed and enabled -- this script does NOT install that part.
#
# Usage (PowerShell):
#   iwr -useb https://raw.githubusercontent.com/mistrysiddh/hermes-pixel-office-embedded/main/install.ps1 | iex

$ErrorActionPreference = "Stop"

$RepoUrl = "https://github.com/mistrysiddh/hermes-pixel-office-embedded"

if ($env:HERMES_HOME) {
    $HomeDir = $env:HERMES_HOME
} else {
    $HomeDir = Join-Path $env:LOCALAPPDATA "hermes"
}

Write-Host "Hermes Pixel Office -- Embedded Desktop Pane"
Write-Host ""
Write-Host "This will install a desktop plugin into:"
Write-Host "  $HomeDir\desktop-plugins\pixel-office-view\"
Write-Host ""
Write-Host "It docks the live hermes-pixel-office office as a pane inside the"
Write-Host "Hermes desktop app. Requires the hermes-pixel-office backend plugin"
Write-Host "separately (the installer will tell you if it's missing)."
Write-Host ""

if (-not $env:PIXEL_OFFICE_YES -and [Environment]::UserInteractive -and -not ([Console]::IsInputRedirected)) {
    $Reply = Read-Host "Proceed with install? [Y/n]"
    if ($Reply -match '^[nN]') {
        Write-Host "Aborted -- nothing was installed."
        exit 0
    }
}

Write-Host "Installing into: $HomeDir"

$DesktopPluginDir = Join-Path $HomeDir "desktop-plugins\pixel-office-view"
New-Item -ItemType Directory -Force -Path $DesktopPluginDir | Out-Null

$TmpDir = Join-Path $env:TEMP ("pixel-office-view-" + [guid]::NewGuid())

Write-Host "-> Cloning desktop pane..."
$PrevEAP = $ErrorActionPreference
$ErrorActionPreference = "Continue"
git clone --depth 1 --quiet $RepoUrl $TmpDir 2>&1 | Out-Null
$ErrorActionPreference = $PrevEAP
if (-not (Test-Path "$TmpDir\desktop-plugins\pixel-office-view\plugin.js")) {
    Write-Error "git clone failed -- is git installed and on PATH?"
    exit 1
}
Copy-Item "$TmpDir\desktop-plugins\pixel-office-view\plugin.js" $DesktopPluginDir -Force
Remove-Item -Recurse -Force $TmpDir

Write-Host ""
if (Test-Path (Join-Path $HomeDir "plugins\pixel-office")) {
    Write-Host "Installed! Backend plugin already present -- you're all set." -ForegroundColor Green
} else {
    Write-Host "Backend not found. This pane needs the hermes-pixel-office backend" -ForegroundColor Yellow
    Write-Host "plugin (serves http://127.0.0.1:8113) -- install it first:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  git clone https://github.com/teknium1/hermes-pixel-office `"$HomeDir\plugins\pixel-office`""
    Write-Host "  hermes config set plugins.enabled '[""pixel-office""]'"
    Write-Host ""
    Write-Host "Desktop pane installed." -ForegroundColor Green
}

Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. Fully quit and relaunch the Hermes desktop app (plugins load at process start)."
Write-Host "  2. Do anything in a session -- the office starts serving once the first event fires."
Write-Host "  3. You'll see a 'PIXEL OFFICE' pane docked in the app, live."
Write-Host ""
Write-Host "Troubleshooting: hermes logs --level info | findstr pixel-office"
