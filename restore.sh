#!/usr/bin/env bash
# Przywraca Google TV i wszystko, co wyłączył install.sh (także DEBLOAT=1). Launcher CleanYourTV zostaje odinstalowany.
# Użycie: ./restore.sh <IP_telewizora>
set -euo pipefail
cd "$(dirname "$0")"
IP="${1:?podaj IP telewizora}"; DEV="$IP:5555"
a() { adb -s "$DEV" "$@"; }
adb connect "$DEV" >/dev/null

a shell pm enable com.google.android.apps.tv.launcherx
a shell pm enable com.google.android.tungsten.setupwraith
grep -vE '^\s*(#|$)' packages-group-a.txt | while read -r p; do a shell pm enable "$p" >/dev/null 2>&1 || true; done
a shell "settings put secure enabled_accessibility_services ''; settings put secure accessibility_enabled 0"
a shell cmd package set-home-activity --user 0 com.google.android.apps.tv.launcherx/.home.HomeActivity >/dev/null 2>&1 || true
a uninstall com.gathin.tvhome || true
a shell input keyevent HOME
echo "Przywrócono Google TV."
