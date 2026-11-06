# CleanYourTV dla TCL Smart TV Pro (G03 / BeyondTV4): gotowy APK

Gotowy, zbudowany plik APK launchera [CleanYourTV](https://github.com/Gathin23/cleanyourtv) i skrypt instalacyjny
dla telewizorów **TCL Smart TV Pro** z **Google TV na Androidzie 11** (product `G03_4K_GB`, device `BeyondTV4`).
Nie trzeba instalować JDK, Android SDK ani Pythona. Wystarczy `adb`.

> Nieoficjalna kompilacja. Launcher jest autorstwa [Gathin23/cleanyourtv](https://github.com/Gathin23/cleanyourtv)
> (licencja MIT). APK zbudowano bez zmian w kodzie z commita
> [`3c122bc`](https://github.com/Gathin23/cleanyourtv/commit/3c122bc073f7a9a83de251621e6e31d90dd96109) (v3.4.0).

| | |
|---|---|
| Plik | `cleanyourtv-launcher-3.4.apk` (575 KB) |
| SHA-256 | `95af5c609592f0a006d50d04fa1aae7c37aade2437fe782d23b8cfa0fdb3f60e` |
| Podpis | klucz debug (`CN=Android Debug`, SHA-256 certyfikatu `235169f2…fba08e`) |
| Pakiet | `com.gathin.tvhome`, minSdk 26 |

Sam APK jest uniwersalny i działa na każdym Android TV / Google TV od wersji 8. Ustawienia pod TCL G03
są w `config.json` i w `install.sh`.

## Jak sprawdzić, czy masz ten model

```bash
adb connect <IP_TV>:5555
adb shell getprop ro.build.fingerprint
# TCL/G03_4K_GB/BeyondTV4:11/RP1A.200622.001/...
```

## Instalacja

1. Na TV: Ustawienia → System → Informacje → 7× kliknij **Kompilacja**. Następnie Opcje programisty → **Debugowanie USB** (wł.).
2. Na komputerze (Linux/macOS, potrzebne tylko `adb`):

```bash
git clone https://github.com/rybainformatyk/cleanyourtv-tcl-g03
cd cleanyourtv-tcl-g03
# APK jest już w repo (ten sam plik jest też w zakładce Releases)
./install.sh <IP_TV>              # launcher, konfiguracja, wyłączenie Google TV
DEBLOAT=1 ./install.sh <IP_TV>    # to samo + wyłączenie reklam i telemetrii TCL (packages-group-a.txt)
```

3. Na TV zaakceptuj okno „Zezwolić na debugowanie?”.

Co robi `install.sh`:
- instaluje launcher i sprawdza, czy startuje (jeśli nie, przerywa, zanim cokolwiek wyłączy),
- wgrywa `config.json`: Live TV w menu „Wejścia”, przyciski Netflix / YouTube / Prime Video / zębatka na pilocie,
  poprawka podwójnego skoku głośności,
- wyłącza (nie usuwa) launcher Google TV i kreator `setupwraith`, który na tym modelu przejmuje Home,
  o ile kreator nie jest właścicielem zapisanej sieci Wi-Fi,
- sprawdza, kto obsługuje Home, i jeśli coś poszło nie tak, przywraca Google TV,
- włącza usługę dostępności `HomeKeyService` (obsługuje przyciski aplikacji na pilocie).

## Cofnięcie

```bash
./restore.sh <IP_TV>
```

Włącza z powrotem Google TV, kreator i pakiety z `packages-group-a.txt` oraz odinstalowuje launcher.

## Uwagi

- Bez launchera Google TV nie działa panel Google Home (sterowanie oświetleniem) ani rekomendacje na ekranie głównym.
- APK jest podpisany kluczem debug. Jeśli później zechcesz zainstalować własną kompilację z oficjalnego repo, najpierw
  odinstaluj tę (`adb uninstall com.gathin.tvhome`), bo inaczej dostaniesz `INSTALL_FAILED_UPDATE_INCOMPATIBLE`.
- Po aktualizacji firmware TCL sprawdź `adb shell pm list packages -d`, bo aktualizacja może ponownie włączyć pakiety.
- `upstream-debloat-tcl-g03.txt` to pełna, przetestowana lista dla tego modelu z oryginalnego repo, z opisem każdego pakietu.

## Licencje

Kod launchera: MIT © 2026 Gathin, zobacz `licenses/LICENSE-CleanYourTV-MIT.txt`. Font Outfit: SIL OFL, ikony: Fluent Emoji (MIT).
Obie licencje są w `licenses/`. Skrypty z tego repo: MIT.

---

**EN:** Prebuilt, unmodified CleanYourTV launcher APK (v3.4.0, upstream commit `3c122bc`) plus an adb-only installer
for TCL Smart TV Pro G03_4K_GB / BeyondTV4 (Google TV 11). Unofficial build, not affiliated with the upstream project.
Run `./install.sh <TV_IP>` to install, `./restore.sh <TV_IP>` to undo.
