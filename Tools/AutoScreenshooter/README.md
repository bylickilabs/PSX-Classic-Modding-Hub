# PSx Classic AutoScreenshooter

| Automatisierte Screenshot-Erstellung für eine modifizierte PlayStation Classic über SSH, Weston und SCP. |
|---|

> Der **PSx Classic AutoScreenshooter** ist ein PowerShell-basiertes Hilfswerkzeug für Windows, das den Screenshot-Workflow einer entsprechend vorbereiteten PlayStation Classic automatisiert.
  - Das Skript verbindet sich über SSH mit der Konsole, bereitet den benötigten Screenshot-Pfad vor, löst die Screenshot-Erstellung aus und überträgt das erzeugte PNG anschließend automatisch per SCP auf den Windows-PC.

> [!IMPORTANT]
> Dieses Tool wurde für eine konkrete BleemSync-/Weston-Umgebung auf der PlayStation Classic entwickelt und getestet. Es ist **kein universelles Screenshot-Tool für jede PlayStation Classic oder jede Modding-Distribution**. Andere Setups können Anpassungen erfordern.

<br>

---

<br>

## Funktionsübersicht

> Der AutoScreenshooter automatisiert den zuvor manuellen Ablauf zur Erstellung eines Screenshots des PSx-Classic-Hauptbildschirms.

> Je nach verwendeter Skriptversion übernimmt das Tool unter anderem:
  - [x] Prüfung der Erreichbarkeit der PlayStation Classic
  - [x] Aufbau einer SSH-Verbindung
  - [x] Prüfung der benötigten Screenshot-Verzeichnisse
  - [x] Vorbereitung des Weston-Screenshot-Ziels
  - [x] Prüfung bzw. Einrichtung des benötigten symbolischen Links
  - [x] Verwendung des Weston-Screenshooters
  - [x] automatisches Auslösen der Screenshot-Funktion
  - [x] Speicherung des erzeugten PNG auf dem BleemSync-Datenträger
  - [x] Übertragung des Screenshots per SCP auf den Windows-PC
  - [x] automatische Vergabe eines Dateinamens mit Zeitstempel
  - [x] optionales automatisches Öffnen des fertigen Screenshots

> [!NOTE]
> Der eigentliche Screenshot wird auf der PlayStation Classic erzeugt. Das PowerShell-Skript übernimmt die Steuerung und den Transfer zum PC.

<br>

---

<br>

## Getestete Umgebung

> Die Entwicklung und der bisherige Test erfolgten in folgender Umgebung.

### Windows-PC

- Windows 10 / Windows 11
- Windows PowerShell bzw. PowerShell
- Windows OpenSSH Client
- `ssh.exe`
- `scp.exe`
- Netzwerkzugriff auf die PlayStation Classic

### PlayStation Classic

- modifizierte PlayStation Classic
- BleemSync
- aktivierter SSH-Zugriff
- Root-Zugriff über SSH
- Weston / Wayland
- vorhandener Weston-Screenshooter
- `/dev/uinput`
- beschreibbarer BleemSync-USB-Datenträger
- funktionierende Netzwerkverbindung

- Relevante Pfade des getesteten Systems:

```text
/usr/libexec/weston-screenshooter
/dev/uinput
/media/bleemsync/
/media/bleemsync/bin/
/media/bleemsync/screenshots/
/wayland-screenshot.png
```

> Andere Modding-Umgebungen können eine abweichende Verzeichnisstruktur verwenden.

<br>

---

<br>

## Voraussetzungen

> Vor der Verwendung müssen folgende Voraussetzungen erfüllt sein.

### 1. SSH muss auf der PlayStation Classic funktionieren

> Vom Windows-PC muss eine Verbindung zur Konsole möglich sein.

Beispiel:

```powershell
ssh root@192.168.2.72
```

> Die Adresse `192.168.2.72` ist hierbei **nur ein Beispiel**.

### 2. SCP muss auf dem Windows-PC verfügbar sein

Prüfung:

```powershell
scp
```

> Windows 10 und Windows 11 können den OpenSSH Client als optionales Windows-Feature bereitstellen.

### 3. BleemSync und Netzwerkzugriff müssen korrekt eingerichtet sein

> Die PlayStation Classic muss über das Netzwerk erreichbar sein und SSH-Verbindungen akzeptieren.

### 4. Der Weston-Screenshooter muss vorhanden sein

> Auf dem getesteten System befindet er sich unter:

```text
/usr/libexec/weston-screenshooter
```

### 5. `/dev/uinput` muss vorhanden sein

Prüfung über SSH:

```bash
ls -l /dev/uinput
```

> Bei dem getesteten System war das Device bereits vorhanden.

<br>

---

<br>

## Netzwerk und SSID

> Die Netzwerkverbindung ist eine zentrale Voraussetzung für den AutoScreenshooter.

### PlayStation Classic und PC müssen sich im selben lokalen Netzwerk befinden

> Wenn **beide Geräte per WLAN verbunden sind**, sollten sie mit **demselben WLAN bzw. derselben SSID** verbunden sein.

  Beispiel:

```text
PC
└── WLAN: MEIN-NETZWERK

PlayStation Classic
└── WLAN: MEIN-NETZWERK
```

> Die Geräte müssen sich gegenseitig über das lokale Netzwerk erreichen können.

> [!WARNING]
> Ein Gäste-WLAN kann trotz funktionierender Internetverbindung den Zugriff zwischen Geräten blockieren. Funktionen wie **Client Isolation**, **AP Isolation**, **Guest Isolation** oder ähnliche Router-Einstellungen können dazu führen, dass Ping, SSH und SCP nicht funktionieren.

### PC über Ethernet

> Ist der Windows-PC per Netzwerkkabel verbunden, muss er nicht zwangsläufig eine WLAN-SSID verwenden. Entscheidend ist dann, dass sich PC und PlayStation Classic im **gleichen lokalen LAN bzw. erreichbaren IP-Netz** befinden und der Router die Kommunikation zwischen LAN und WLAN nicht blockiert.

  Beispiel:

```text
Windows-PC:        192.168.2.30
PlayStation Classic: 192.168.2.72
Router/Gateway:    192.168.2.1
```

### Verbindung testen

- Unter Windows:

```powershell
ping 192.168.2.72
```

- Anschließend:

```powershell
ssh root@192.168.2.72
```

> Erst wenn die SSH-Verbindung zuverlässig funktioniert, sollte der AutoScreenshooter verwendet werden.

<br>

---

<br>

## IP-Adresse der PlayStation Classic eintragen

> [!IMPORTANT]
> **Vor der ersten Verwendung muss im Skript die IP-Adresse der eigenen PlayStation Classic eingetragen bzw. überprüft werden.**

> Die im Skript enthaltene IP-Adresse stammt aus der Entwicklungs- und Testumgebung und ist **nicht automatisch für andere Netzwerke gültig**.

  - Im PowerShell-Skript befindet sich beispielsweise:

```powershell
[string]$PSClassicIP = "192.168.2.72"
```

> Diese Adresse muss durch die IP-Adresse der eigenen PlayStation Classic ersetzt werden.

Beispiel:

```powershell
[string]$PSClassicIP = "192.168.178.42"
```

### Warum ist das notwendig?

> IP-Adressen werden normalerweise vom Router über DHCP vergeben. Dadurch kann eine PlayStation Classic in einem anderen Netzwerk beispielsweise folgende Adresse besitzen:

```text
192.168.0.25
192.168.1.73
192.168.2.72
192.168.178.42
10.0.0.55
```

> Das Skript kann nur dann eine SSH-Verbindung herstellen, wenn die korrekte Adresse verwendet wird.

### Alternative: IP als Parameter übergeben

> Wenn die verwendete Skriptversion den Parameter `-PSClassicIP` unterstützt, kann die Adresse auch beim Start angegeben werden:

```powershell
.\AutoScreenshooter.ps1 -PSClassicIP "192.168.178.42"
```

> Dadurch muss die Skriptdatei selbst nicht bei jedem Wechsel der IP-Adresse bearbeitet werden.

<br>

---

<br>

## IP-Adresse der PlayStation Classic ermitteln

> Die genaue Vorgehensweise hängt von der verwendeten Modding-Umgebung und Netzwerkkonfiguration ab.

> Mögliche Wege sind:

1. Netzwerk- bzw. Systeminformationen der verwendeten Oberfläche öffnen.
2. Im Router nach den aktuell verbundenen Geräten suchen.
3. Die Netzwerkadresse über eine bereits funktionierende Konsolen- oder Netzwerkfunktion anzeigen lassen.

> Bei einer funktionierenden Verbindung kann die Adresse anschließend unter Windows getestet werden:

```powershell
ping IP-DER-PS-CLASSIC
```

Beispiel:

```powershell
ping 192.168.2.72
```

- Danach:

```powershell
ssh root@192.168.2.72
```

<br>

---

<br>

## Repository-Struktur

> Für eine eigenständige Verwendung ist folgende Struktur vorgesehen:

```text
AutoScreenshooter/
├── AutoScreenshooter.ps1
└── README.md
```

> Wird der AutoScreenshooter als Bestandteil eines größeren PlayStation-Classic-Repositories verwendet, kann er in einem eigenen Unterverzeichnis abgelegt werden:

```text
Repository/
├── README.md
├── AutoScreenshooter/
│   ├── AutoScreenshooter.ps1
│   └── README.md
└── ...
```

> Die separate `README.md` im Verzeichnis `AutoScreenshooter` enthält die vollständige Dokumentation des Tools.

<br>

---

<br>

## Installation

### 1. Dateien herunterladen

  - Benötigt werden mindestens:

```text
AutoScreenshooter.ps1
README.md
```

> Die Dateien können in einen beliebigen lokalen Ordner kopiert werden.

  Beispiel:

```text
C:\Users\<BENUTZER>\Desktop\PSX_AutoScreenshooter\
```

### 2. IP-Adresse prüfen

  - Vor dem ersten Start:

```powershell
[string]$PSClassicIP = "192.168.2.72"
```

> Die Beispieladresse muss durch die tatsächliche Adresse der eigenen Konsole ersetzt oder beim Start über den vorgesehenen Parameter übergeben werden.

### 3. Netzwerk prüfen

```powershell
ping 192.168.2.72
```

### 4. SSH testen

```powershell
ssh root@192.168.2.72
```

> Wenn die Verbindung erfolgreich aufgebaut werden kann, die SSH-Sitzung wieder mit folgendem Befehl verlassen:

```bash
exit
```

> Eine dauerhaft geöffnete manuelle SSH-Sitzung ist für den AutoScreenshooter nicht erforderlich.

<br>

---

<br>

## Ausführung

> PowerShell im Verzeichnis des Skripts öffnen.

  Beispiel:

```powershell
cd "$env:USERPROFILE\Desktop\PSX_AutoScreenshooter"
```

  - Skript starten:

```powershell
.\AutoScreenshooter.ps1
```

> Falls die Windows Execution Policy die Ausführung blockiert:

```powershell
powershell.exe -ExecutionPolicy Bypass -File ".\AutoScreenshooter.ps1"
```

### Andere IP-Adresse beim Start verwenden

> Sofern vom Skript unterstützt:

```powershell
.\AutoScreenshooter.ps1 -PSClassicIP "192.168.178.42"
```

### Screenshot nicht automatisch öffnen

> Sofern vom Skript unterstützt:

```powershell
.\AutoScreenshooter.ps1 -NoOpen
```

<br>

---

<br>

## Speicherort der Screenshots

> Auf der PlayStation Classic wird der Screenshot in der getesteten Umgebung unter folgendem Pfad gespeichert:

```text
/media/bleemsync/screenshots/wayland-screenshot.png
```

> Der Weston-Screenshooter verwendet:

```text
/wayland-screenshot.png
```

> Der AutoScreenshooter kann hierfür einen symbolischen Link verwenden:

```text
/wayland-screenshot.png
    ->
/media/bleemsync/screenshots/wayland-screenshot.png
```

> Dadurch wird die eigentliche PNG-Datei auf dem BleemSync-Datenträger gespeichert und nicht dauerhaft in das interne Root-Dateisystem geschrieben.

### Windows-Ausgabe

> Die aktuelle Skriptversion kann die Screenshots beispielsweise unter folgendem Ordner speichern:

```text
C:\Users\<BENUTZER>\Desktop\PSX_Screenshots\
```

  - Beispiel für einen erzeugten Dateinamen:

```text
PSX_Homescreen_2026-08-28_08-15-30.png
```

> Der Zeitstempel verhindert, dass bereits übertragene Screenshots automatisch überschrieben werden.

<br>

---

<br>

## Verwendete Komponenten

> Der Workflow verwendet mehrere vorhandene Systemkomponenten.

### SSH

> Wird für die Remote-Kommunikation mit der PlayStation Classic verwendet.

```text
Windows-PC -> SSH -> PlayStation Classic
```

### SCP

> Überträgt den fertigen Screenshot von der Konsole auf den PC.

```text
PlayStation Classic -> SCP -> Windows-PC
```

### Weston / Wayland

> Der Hauptbildschirm der getesteten PlayStation-Classic-Umgebung wird über Weston dargestellt.

> Der entsprechende Screenshooter befindet sich unter:

```text
/usr/libexec/weston-screenshooter
```

### `/dev/uinput`

> In der automatisierten Variante kann ein virtuelles Linux-Eingabegerät verwendet werden, um die für Weston benötigte Tastenkombination automatisiert auszulösen.

### PowerShell

> PowerShell übernimmt auf dem Windows-PC die gesamte Orchestrierung:

  - Verbindung
  - Prüfung
  - Remote-Aufrufe
  - Übertragung
  - Dateiverwaltung
  - Fehlerbehandlung

<br>

---

<br>

## Technischer Hintergrund

> Bei der Entwicklung wurde zunächst versucht, den sichtbaren Bildschirminhalt direkt aus dem Linux-Framebuffer auszulesen.
  - Ein vorhandener Framebuffer allein bedeutet jedoch nicht automatisch, dass dort der aktuell von Weston dargestellte Compositor-Inhalt verfügbar ist.
  - Die getestete Umgebung verwendet Weston / Wayland. Deshalb wird der Screenshot über den vorhandenen Weston-Screenshooter erzeugt.
    - Der Weston-Screenshooter erwartet in dieser Umgebung die Datei:

```text
wayland-screenshot.png
```

> [!IMPORTANT]
> Da das interne Root-Dateisystem der PlayStation Classic im Normalbetrieb schreibgeschützt eingebunden sein kann, wird der Screenshot auf den beschreibbaren BleemSync-Datenträger umgeleitet.

  Beispiel:

```text
/wayland-screenshot.png
        │
        │ symbolischer Link
        ▼
/media/bleemsync/screenshots/wayland-screenshot.png
```

> Die eigentliche Übertragung zum PC erfolgt anschließend über SCP.

<br>

---

<br>

## Sicherheits- und Systemhinweise

### Root-Zugriff

> [!CAUTION]
> Das Tool verwendet SSH mit Root-Rechten auf der modifizierten PlayStation Classic.

  Beispiel:

```text
root@IP-DER-PS-CLASSIC
```

> Root-Zugriff besitzt vollständige Systemrechte. Änderungen an Skript oder Befehlen sollten daher nur vorgenommen werden, wenn deren Auswirkungen verstanden werden.

### Root-Dateisystem

> [!WARNING]
> Das interne Root-Dateisystem kann als `read-only` eingebunden sein.

  Beispiel:

```text
/dev/mmcblk0p7 on / type ext4 (ro,...)
```

> Je nach Zustand kann das Skript das Dateisystem kurzzeitig beschreibbar einbinden, um den benötigten symbolischen Link anzulegen, und anschließend wieder auf `read-only` zurücksetzen.

> Dieser Vorgang sollte nicht manuell unterbrochen werden.

### SSH Host Keys

> Beim ersten Verbindungsaufbau kann Windows nach der Bestätigung des SSH-Host-Keys fragen.

  Beispiel:

```text
Are you sure you want to continue connecting (yes/no)?
```

> Der Fingerprint sollte vor einer dauerhaften Bestätigung nach Möglichkeit geprüft werden.

<br>

---

<br>

## Kompatibilität

### Getestet

| Komponente | Status |
|---|---|
| Windows 10 / 11 | Getestete Host-Plattform |
| Windows PowerShell | Unterstützt |
| Windows OpenSSH | Erforderlich |
| BleemSync | Getestete PS-Classic-Umgebung |
| SSH als root | Erforderlich |
| Weston / Wayland | Erforderlich |
| `weston-screenshooter` | Erforderlich |
| `/dev/uinput` | Für automatische Auslösung erforderlich |
| SCP | Erforderlich |

### Nicht offiziell getestet

> Folgende Umgebungen wurden mit diesem Tool nicht verbindlich getestet:

- AutoBleem
- Project Eris
- andere BleemSync-Versionen
- andere Weston-Versionen
- andere Wayland-Compositoren
- Linux als Host-System
- macOS als Host-System
- nicht modifizierte PlayStation Classic

> [!NOTE]
> Dass einzelne Komponenten dort ähnlich funktionieren, stellt **keine Kompatibilitätsgarantie** dar.

<br>

---

<br>

## Fehlerbehebung

### `Connection timed out`

  Beispiel:

```text
ssh: connect to host 192.168.2.72 port 22: Connection timed out
```

  - Mögliche Ursachen:

- falsche IP-Adresse
- PlayStation Classic nicht mit dem Netzwerk verbunden
- PC und PS Classic befinden sich nicht im selben erreichbaren Netzwerk
- Gäste-WLAN blockiert lokale Geräte
- Client/AP Isolation ist aktiviert
- SSH ist nicht aktiv
- IP-Adresse wurde durch DHCP geändert

> Prüfen:

```powershell
ping 192.168.2.72
```

  - Danach:

```powershell
ssh root@192.168.2.72
```

<br>

---

<br>

### IP-Adresse hat sich geändert

> DHCP kann nach Neustarts eine andere Adresse vergeben.

  - Lösung:

1. aktuelle IP der PS Classic ermitteln
2. neue Adresse im Skript eintragen

  - oder:

```powershell
.\AutoScreenshooter.ps1 -PSClassicIP "NEUE-IP"
```

<br>

---

<br>

### PowerShell findet das Skript nicht

  Beispiel:

```text
Die Benennung ".\AutoScreenshooter.ps1" wurde nicht als Name ...
```

  - Aktuelles Verzeichnis prüfen:

```powershell
Get-Location
```

  - Dateien anzeigen:

```powershell
dir *.ps1
```

  - Anschließend in den richtigen Ordner wechseln:

```powershell
cd "PFAD-ZUM-SKRIPT"
```

> Anschließend kann das Skript gestartet werden:

```powershell
.\AutoScreenshooter.ps1
```

<br>

---

<br>

### `.ps1` öffnet sich im Texteditor

> Ein Doppelklick auf eine `.ps1`-Datei kann diese abhängig von der Windows-Dateizuordnung im Editor öffnen.

> Das Skript stattdessen aus PowerShell starten:

```powershell
.\AutoScreenshooter.ps1
```

  - oder:

```powershell
powershell.exe -ExecutionPolicy Bypass -File ".\AutoScreenshooter.ps1"
```

<br>

---

<br>

### `scp` oder `ssh` wurde nicht gefunden

> Windows OpenSSH Client prüfen bzw. installieren.

  - In PowerShell:

```powershell
Get-Command ssh
Get-Command scp
```

> Beide Befehle müssen gefunden werden.

<br>

---

<br>

### Screenshot-Datei wird auf der PS Classic nicht erzeugt

> Prüfen:

```bash
ls -l /usr/libexec/weston-screenshooter
```

  - und:

```bash
ls -l /dev/uinput
```

  - Screenshot-Verzeichnis:

```bash
ls -lah /media/bleemsync/screenshots/
```

  - Symbolischer Link:

```bash
ls -l /wayland-screenshot.png
```

  - Erwartetes Ziel:

```text
/wayland-screenshot.png -> /media/bleemsync/screenshots/wayland-screenshot.png
```

<br>

---

<br>

### Screenshot hat einen weißen statt dunklen Hintergrund

> [!TIP]
> In der getesteten Umgebung wurde beobachtet, dass die PS-Classic-Oberfläche nach bestimmten Zustandswechseln bzw. Repaints korrekt aufgenommen wird, während ein nicht vollständig aktualisierter Compositor-Zustand zu einem weißen Hintergrund führen kann.

- Ein Wechsel innerhalb der Oberfläche und die anschließende Rückkehr zum Hauptbildschirm kann einen vollständigen UI-Refresh auslösen.
- Dieses Verhalten ist abhängig von der verwendeten Weston-/UI-Umgebung und stellt keine allgemeine Eigenschaft jeder PlayStation Classic dar.

<br>

---

<br>

### `Read-only file system`

> [!WARNING]
> Das Root-Dateisystem der PlayStation Classic kann absichtlich schreibgeschützt eingebunden sein.

  Beispiel:

```text
Read-only file system
```

> Das sollte nicht dauerhaft auf `read-write` umgestellt werden.

> Die getestete Lösung speichert den eigentlichen Screenshot auf dem BleemSync-Datenträger:

```text
/media/bleemsync/screenshots/
```

<br>

---

<br>

## Bekannte Einschränkungen

- Das Tool wurde nicht auf jeder Modding-Distribution getestet.
- Die verwendeten Pfade sind BleemSync-spezifisch.
- Die PS-Classic-IP kann sich durch DHCP ändern.
- SSH muss bereits funktionieren.
- Router- oder WLAN-Isolation kann den Zugriff verhindern.
- Die grafische Ausgabe ist abhängig von Weston und dessen aktuellem Compositor-Zustand.
- Andere Versionen des Weston-Screenshooters können sich anders verhalten.
- `/dev/uinput` ist nicht in jeder Umgebung zwingend vorhanden.
- Das Tool verändert keine Spielinhalte und dient ausschließlich der Screenshot-Automatisierung.

<br>

---

<br>

## Haftungsausschluss

> [!CAUTION]
> Dieses Projekt ist ein technisches Hilfswerkzeug für entsprechend modifizierte PlayStation-Classic-Systeme.

> **Die Verwendung erfolgt auf eigene Verantwortung.**

> Der Autor übernimmt keine Gewähr für:

  - Kompatibilität mit jeder Hardware- oder Softwarekonfiguration
  - Funktionsfähigkeit mit anderen Modding-Distributionen
  - Änderungen durch zukünftige System-, Router- oder Netzwerkupdates
  - Datenverlust durch eigenständig vorgenommene Änderungen am Skript
  - Schäden, die durch unsachgemäße Verwendung von Root-Rechten oder Systembefehlen entstehen

> Vor Änderungen an Systemdateien, Mount-Konfigurationen oder Boot-Komponenten sollte grundsätzlich eine geeignete Sicherung vorhanden sein.

> Das Tool dient ausschließlich der technischen Screenshot-Erstellung und Automatisierung auf Systemen, für deren Nutzung und Modifikation der jeweilige Anwender selbst verantwortlich ist.

