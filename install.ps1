# Hermes Pixel Office + Embedded View — one-command installer (Windows).
# Usage (PowerShell):
#   iwr -useb https://raw.githubusercontent.com/mistrysiddh/hermes-pixel-office-embedded/main/install.ps1 | iex

$ErrorActionPreference = "Stop"

$RepoUrl = "https://github.com/mistrysiddh/hermes-pixel-office-embedded"

if ($env:HERMES_HOME) {
    $HomeDir = $env:HERMES_HOME
} else {
    $HomeDir = Join-Path $env:LOCALAPPDATA "hermes"
}

Write-Host "Installing into: $HomeDir"

$PluginDir = Join-Path $HomeDir "plugins\pixel-office"
$DesktopPluginDir = Join-Path $HomeDir "desktop-plugins\pixel-office-view"

New-Item -ItemType Directory -Force -Path $PluginDir | Out-Null
New-Item -ItemType Directory -Force -Path $DesktopPluginDir | Out-Null

Write-Host "-> Cloning repo..."
$TmpDir = Join-Path $env:TEMP ("pixel-office-" + [guid]::NewGuid())
git clone --depth 1 $RepoUrl $TmpDir 2>$null | Out-Null

Copy-Item "$TmpDir\__init__.py" $PluginDir -Force
Copy-Item "$TmpDir\plugin.yaml" $PluginDir -Force
Copy-Item "$TmpDir\demo_feed.py" $PluginDir -Force
Copy-Item "$TmpDir\LICENSE" $PluginDir -Force
Copy-Item "$TmpDir\web" $PluginDir -Recurse -Force

Write-Host "-> Installing desktop embedded pane..."
Copy-Item "$TmpDir\desktop-plugins\pixel-office-view\plugin.js" $DesktopPluginDir -Force

Remove-Item -Recurse -Force $TmpDir

Write-Host "-> Enabling backend plugin in config.yaml..."
$Config = Join-Path $HomeDir "config.yaml"
$AlreadyThere = $false
if (Test-Path $Config) {
    $AlreadyThere = (Select-String -Path $Config -Pattern "pixel-office" -Quiet)
}
if ($AlreadyThere) {
    Write-Host "  pixel-office already referenced in config.yaml -- skipping"
} elseif (Get-Command hermes -ErrorAction SilentlyContinue) {
    hermes config set plugins.enabled '["pixel-office"]' 2>$null
} else {
    Write-Host "  NOTE: add this to $Config manually if not already present:"
    Write-Host "    plugins:"
    Write-Host "      enabled:"
    Write-Host "        - pixel-office"
}

Write-Host ""
Write-Host "Installed!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. Fully quit and relaunch the Hermes desktop app (plugins load at process start)."
Write-Host "  2. Do anything in a session -- the office starts serving once the first event fires."
Write-Host "  3. You'll see a 'PIXEL OFFICE' pane docked in the app, live -- no browser tab needed."
Write-Host "     (Standalone view still at http://127.0.0.1:8113 if you want it.)"
Write-Host ""
Write-Host "Troubleshooting: hermes logs --level info | findstr pixel-office"
