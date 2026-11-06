#!/usr/bin/env bash
# Instalacja launchera CleanYourTV na TCL Smart TV Pro (G03_4K_GB / BeyondTV4, Google TV 11)
# bez budowania i bez Pythona - tylko standardowe adb.
#
# Użycie:   ./install.sh <IP_telewizora>              # launcher + config + wyłączenie Google TV
#           DEBLOAT=1 ./install.sh <IP_telewizora>    # dodatkowo wyłącza reklamy/telemetrię TCL (packages-group-a.txt)
#
# Nic nie jest odinstalowywane (tylko pm disable-user). Cofnięcie: ./restore.sh <IP_telewizora>
set -euo pipefail
cd "$(dirname "$0")"

IP="${1:?podaj IP telewizora, np. ./install.sh 192.168.1.50}"
DEV="$IP:5555"
APK=cleanyourtv-launcher-3.4.apk
PKG=com.gathin.tvhome
STOCK=com.google.android.apps.tv.launcherx
WIZARD=com.google.android.tungsten.setupwraith
HOME_Q='cmd package resolve-activity --brief -a android.intent.action.MAIN -c android.intent.category.HOME'

a() { adb -s "$DEV" "$@"; }
home_now() { a shell "$HOME_Q" | tail -n 1 | tr -d '\r'; }

command -v adb >/dev/null || { echo "Brak adb (Linux: sudo apt install adb)"; exit 1; }
adb connect "$DEV" >/dev/null
echo "Jeśli na TV pojawi się 'Zezwolić na debugowanie?' - zaznacz 'Zawsze zezwalaj' i OK."
for _ in $(seq 1 30); do [ "$(a get-state 2>/dev/null)" = device ] && break; sleep 2; done
[ "$(a get-state 2>/dev/null)" = device ] || { echo "TV nie autoryzował połączenia ADB."; exit 1; }

echo "Model: $(a shell getprop ro.product.model | tr -d '\r') / $(a shell getprop ro.build.product | tr -d '\r'), SDK $(a shell getprop ro.build.version.sdk | tr -d '\r')"

if [ "${DEBLOAT:-0}" = 1 ]; then
  echo "== Wyłączanie reklam i telemetrii TCL (packages-group-a.txt)"
  grep -vE '^\s*(#|$)' packages-group-a.txt | while read -r p; do
    echo "  $p: $(a shell pm disable-user --user 0 "$p" 2>&1 | tr -d '\r')"
  done
fi

echo "== Instalacja launchera"
a install -r "$APK"

echo "== Test startu launchera (zanim cokolwiek zostanie wyłączone)"
OUT=$(a shell am start -W -a android.intent.action.MAIN -c android.intent.category.HOME -n $PKG/.MainActivity)
echo "$OUT" | grep -q 'Status: ok' || { echo "$OUT"; echo "Launcher nie wystartował - Google TV zostaje bez zmian."; exit 1; }

echo "== Konfiguracja (Live TV, przyciski pilota, głośność)"
a push config.json /data/local/tmp/cyt-config.json >/dev/null
a shell "content write --uri content://$PKG.theme/config.json < /data/local/tmp/cyt-config.json 2>/dev/null || { mkdir -p /sdcard/Android/data/$PKG/files; cp /data/local/tmp/cyt-config.json /sdcard/Android/data/$PKG/files/config.json; }; rm -f /data/local/tmp/cyt-config.json"

echo "== Przekazanie Home nowemu launcherowi"
a shell pm grant $PKG android.permission.ACCESS_FINE_LOCATION || true
a shell cmd package compile -m speed -f $PKG >/dev/null || true
a shell pm disable-user --user 0 $STOCK
# Na tym modelu kreator Google (setupwraith) przejmuje Home po wyłączeniu launcherx.
# Wyłączamy go tylko, jeśli nie jest właścicielem zapisanej sieci Wi-Fi (inaczej sieć by zniknęła).
if a shell dumpsys wifi | grep -q "cname=$WIZARD"; then
  echo "UWAGA: $WIZARD jest właścicielem zapisanej sieci Wi-Fi - pomijam. Zapomnij sieć i połącz się ponownie w Ustawieniach, potem uruchom skrypt jeszcze raz."
else
  a shell pm disable-user --user 0 $WIZARD
fi
a shell cmd package set-home-activity --user 0 $PKG/.MainActivity >/dev/null
sleep 2

H=$(home_now)
if [[ "$H" != $PKG/* ]]; then
  echo "Home wskazuje na '$H' zamiast nowego launchera - przywracam Google TV."
  a shell pm enable $STOCK; a shell pm enable $WIZARD
  exit 1
fi
echo "Home -> $H"

echo "== Pomocnik przycisków pilota (Netflix/YouTube/Prime/zębatka)"
a shell "cmd appops set $PKG AUTO_START allow 2>/dev/null; cmd appops set $PKG APP_AUTO_START allow 2>/dev/null; appops write-settings 2>/dev/null"
a shell "settings put secure enabled_accessibility_services ''; settings put secure accessibility_enabled 0"
sleep 2
a shell "settings put secure enabled_accessibility_services $PKG/.HomeKeyService; settings put secure accessibility_enabled 1"
sleep 2
a shell dumpsys accessibility | grep -q 'Bound services:{Service' && echo "Pomocnik pilota: OK" || echo "Pomocnik pilota nie podpiął się - uruchom skrypt ponownie albo zrestartuj TV."

a shell input keyevent HOME
echo "Gotowe. Naciśnij Home na pilocie."
