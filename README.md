# PSX Classic Controller Configs

- RetroArch-Autoconfig-Profile für ausgewählte SNES- und N64-Controller an der **Sony PlayStation Classic** mit **BleemSync + RetroArch**.

- Dieses Repository dokumentiert zwei Controller, die auf einem realen PS-Classic-System erkannt, eingerichtet und im Spielbetrieb getestet wurden. 
  - Ziel ist eine reproduzierbare Installation ohne unnötige Änderungen an der globalen `retroarch.cfg`.

| <img width="1280" height="640" alt="PSx (1)" src="https://github.com/user-attachments/assets/df64f716-08af-4140-bf81-66548df4edcf" /> |
|---|

<br>

## Enthaltene Controller

| System | Gerät | RetroArch-Erkennung | VID/PID | Status | Amazon |
|---|---|---|---|---|---|
| SNES | Miadore 2,4-GHz-SNES-Controller mit USB-Dongle | `Controller (121/294)` | `0079:0126` | getestet, funktioniert | [Link](https://www.amazon.de/dp/B07FTCWBSY?ref=ppx_yo2ov_dt_b_fed_asin_title) |
| N64 | Miadore / generischer N64-USB-Controller | `SWITCH CO.,LTD. Controller (3693/4381)` | `0E6D:111D` | getestet, funktioniert | [Link](https://www.amazon.de/dp/B073VL1C63?ref=ppx_yo2ov_dt_b_fed_asin_title) |

<br>

## Schnellinstallation

1. PlayStation Classic vollständig ausschalten.
2. BleemSync-USB-Stick am PC öffnen.
3. Den vorhandenen Ordner `autoconfig` vorsichtshalber sichern.
4. Die beiden `.cfg`-Dateien in den entsprechenden Ordner auf dem Stick kopieren.
5. Zielpfad auf dem USB-Stick:

```text
\bleemsync\opt\retroarch\.config\retroarch\autoconfig\
```

6. RetroArch neu starten.
7. Beim Anschließen sollte RetroArch den jeweiligen Controller als **konfiguriert** melden.

<br>

## Wichtige Dateinamen

> Die Dateinamen sollten unverändert übernommen werden:

```text
Controller.cfg
SWITCH CO.,LTD. Controller.cfg
```

<br>

## Empfohlene Anschluss- und Einrichtungsstrategie

> Bei der ersten Einrichtung empfiehlt sich:

```text
Linker Front-Port / Port 1  -> originaler PlayStation-Classic-Controller
Rechter Front-Port / Port 2 -> neuer SNES- oder N64-Controller
```

> So bleibt der originale Controller für die Navigation verfügbar. 
  - Anschließend kann der neue Controller in RetroArch logisch **Benutzer 1 / Port 1** zugeordnet werden. 
  - Die physische USB-Buchse und die logische RetroArch-Benutzerzuordnung sind nicht dasselbe.

> Für N64-Spiele wie Super Mario 64 muss der N64-Controller als **Benutzer 1** aktiv sein. 
  - Andernfalls wird das Profil zwar geladen, Eingaben wie `Start` erreichen aber nur Spieler **Benutzer 2**

<br>

## Warum keine globale retroarch.cfg enthalten ist

> Dieses Repository ersetzt bewusst **nicht** die globale `retroarch.cfg`. 
  - Diese Datei enthält viele systemspezifische Einstellungen und kann persönliche Anpassungen, Pfade, Video-, Audio- und Eingabewerte enthalten. 
  - Für die Controller-Unterstützung reichen die Autoconfig-Dateien aus.

| Für die automatische Erkennung sollten in RetroArch grundsätzlich folgende Einstellungen aktiv sein:|
|---|

```ini
input_autodetect_enable = "true"
input_joypad_driver = "udev"
```

| Die konkrete PS-Classic/BleemSync-Installation kann weitere Einstellungen enthalten.|
|---|

<br>

## Kompatibilität und Grenzen

> Die Profile sind für die hier dokumentierten Gerätekennungen ausgelegt. 
  - Besonders günstige Retro-Controller werden unter identischen oder ähnlichen Produktnamen mit unterschiedlichen USB-Chipsätzen verkauft. 
  
> Deshalb gilt:
  - Stimmen Gerätename und VID/PID überein, ist das Profil ein guter Kandidat.
  - Weicht die VID/PID ab, sollte das Mapping zuerst geprüft werden.
  - Bei N64-Clones können insbesondere C-Tasten je nach Hardware-Revision anders nummeriert sein.
  - Ein geladenes Profil bedeutet noch nicht automatisch, dass der Controller logisch Benutzer 1 ist.

<br>

## LiCENSE

[LICENSE](LICENSE)
