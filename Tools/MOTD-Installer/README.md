# PSx Classic Custom SSH MOTD

| Dynamischer SSH-Login-Banner für eine modifizierte PlayStation Classic.|
|---|

  - BleemSync
  - Root-Zugriff
  - Live-Systeminformationen.


> Der **PSx Classic Custom SSH MOTD** ersetzt den standardmäßigen BleemSync-Login-Banner durch eine individuell entwickelte, dynamische Systemanzeige für SSH-Sitzungen.

> Die Installation erfolgt vollständig über den offiziellen **BYLICKILABS Web Installer**.  
> Ein manueller Download der Installationsdateien aus dem GitHub-Repository ist nicht erforderlich.

> [!IMPORTANT]
> Dieses Projekt wurde für eine modifizierte **PlayStation Classic mit BleemSync** entwickelt und getestet.
>
> Andere Modding-Distributionen oder abweichende Systemstände können andere Voraussetzungen besitzen.

---

## Funktionsübersicht

> Beim Aufbau einer SSH-Verbindung werden aktuelle Systeminformationen direkt aus der laufenden Linux-Umgebung ausgelesen und innerhalb eines eigenen Terminal-Designs dargestellt.

  - [x] Benutzer und Hostname
  - [x] Betriebssystem und Kernel
  - [x] Prozessor
  - [x] RAM-Auslastung
  - [x] CPU-Auslastung
  - [x] CPU-Temperatur
  - [x] PMIC-Temperatur
  - [x] Speicherbelegung von Root, Data und Media
  - [x] Mod-Status
  - [x] SSH-Status
  - [x] Root-Status
  - [x] Verbindungsstatus
  - [x] BYLICKILABS Website und GitHub

> [!NOTE]
> Die angezeigten Werte werden beim Login dynamisch aus dem laufenden System gelesen und sind keine statischen Beispielwerte.

---

## Voraussetzungen

### Windows-PC

  - [x] Windows 10 oder Windows 11
  - [x] Windows PowerShell bzw. PowerShell
  - [x] Windows OpenSSH Client
  - [x] `ssh.exe`
  - [x] `scp.exe`
  - [x] Internetverbindung
  - [x] Netzwerkzugriff auf die PlayStation Classic

### PlayStation Classic

  - [x] modifizierte PlayStation Classic
  - [x] BleemSync
  - [x] aktivierter SSH-Zugriff
  - [x] Root-Zugriff
  - [x] Netzwerkverbindung zum Windows-PC

> Windows kann prüfen, ob `ssh` und `scp` verfügbar sind:

```powershell
Get-Command ssh
Get-Command scp
```

---

## Installation

| SYSTEM | INSTALLATION | METHODE |
|---|---|---|
| Windows 10 / 11 | [![Install MOTD](https://img.shields.io/badge/INSTALL-MOTD-0078D4?style=for-the-badge&logo=powershell&logoColor=white)](#installer-starten) | BYLICKILABS Web Installer v0.2 |

> Die benötigten Installationsdateien werden direkt aus dem offiziellen BYLICKILABS Webroot geladen.

> [!NOTE]
> Der **INSTALL MOTD** Button führt zum Installationsbefehl in dieser README.
>
> GitHub kann aus Sicherheitsgründen keine lokale PowerShell-Sitzung auf dem Computer des Benutzers automatisch starten.

---

## Installer starten

> Windows PowerShell öffnen und folgenden Befehl vollständig kopieren und ausführen:

```powershell
$h=@{"X-BYLICKILABS-Installer"="motd-installer"}; $f="$env:TEMP\motd_v0.2.ps1"; Invoke-WebRequest "https://www.bylickilabs.de/motd_v0.2.ps1" -Headers $h -OutFile $f; powershell.exe -NoProfile -ExecutionPolicy Bypass -File $f
```

> Der Startbefehl:
  - [x] setzt den benötigten BYLICKILABS Installer-Header
  - [x] lädt `motd_v0.2.ps1` direkt vom BYLICKILABS Webroot
  - [x] startet den Installer mit `-NoProfile`
  - [x] verwendet `ExecutionPolicy Bypass` nur für den gestarteten Installer-Prozess

> [!IMPORTANT]
> Es müssen keine `.ps1`- oder `.sh`-Dateien manuell aus diesem Repository heruntergeladen werden.

---

## Automatischer Installationsablauf

> Nach dem Start übernimmt der Installer den weiteren Ablauf automatisch.

  - [x] Abfrage der IP-Adresse der PlayStation Classic
  - [x] Prüfung der eingegebenen IPv4-Adresse
  - [x] Prüfung der SSH-Erreichbarkeit
  - [x] Abruf der benötigten `motd-bs.sh` aus dem BYLICKILABS Webroot
  - [x] Vorbereitung der Datei für die Linux-Umgebung
  - [x] Upload auf die PlayStation Classic
  - [x] Shell-Syntaxprüfung
  - [x] Installation der neuen MOTD
  - [x] Setzen der benötigten Dateiberechtigungen
  - [x] Verifikation der Installation
  - [x] Neustart der PlayStation Classic
  - [x] erneute Prüfung der SSH-Erreichbarkeit
  - [x] Verifikation der aktiven MOTD

> [!NOTE]
> Die IP-Adresse der PlayStation Classic ist nicht fest im Startbefehl hinterlegt.
>
> Sie wird während des Installer-Ablaufs abgefragt.

---

## Verwendete Webroot-Dateien

| DATEI | VERWENDUNG |
|---|---|
| `motd_v0.2.ps1` | Windows PowerShell Web Installer |
| `motd-bs.sh` | Custom SSH MOTD für die PlayStation Classic |

> Beide Dateien werden über den offiziellen BYLICKILABS Webroot bereitgestellt.

> [!IMPORTANT]
> Der vorgesehene Installationsweg ist ausschließlich der oben dokumentierte PowerShell-Befehl.

---


## Kompatibilität

### Getestet

| KOMPONENTE | STATUS |
|---|---|
| Windows 10 / 11 | Getestete Host-Plattform |
| Windows PowerShell | Unterstützt |
| Windows OpenSSH | Erforderlich |
| BleemSync | Getestete Mod-Umgebung |
| SSH | Erforderlich |
| SCP | Erforderlich |
| Root-Zugriff | Erforderlich |

### Nicht offiziell getestet

> Folgende Umgebungen wurden mit diesem Projekt bisher nicht verbindlich getestet:

  - AutoBleem [ISSUE](https://github.com/bylickilabs/PSX-Classic-Modding-Hub/issues/new?template=autobleem-compatibility.yml)
  - Project Eris [ISSUE](https://github.com/bylickilabs/PSX-Classic-Modding-Hub/issues/new?template=project-eris-compatibility.yml)
  - andere BleemSync-Versionen
  - andere Linux-Systemstände
  - nicht modifizierte PlayStation Classic

> [!NOTE]
> Eine ähnliche Systemstruktur stellt keine Kompatibilitätsgarantie dar.

---

## Sicherheit

> [!CAUTION]
> Das Projekt arbeitet während der Installation mit Root-Rechten auf einer modifizierten PlayStation Classic.

> Der Installer reduziert Risiken unter anderem durch:
  - Syntaxprüfung vor der Installation
  - kontrollierten Installationsablauf
  - Prüfung der übertragenen Datei
  - Verifikation nach der Installation
  - Verifikation nach dem Neustart

> [!IMPORTANT]
> `-ExecutionPolicy Bypass` wird ausschließlich für den gestarteten Installer-Prozess verwendet.
>
> Die systemweite PowerShell Execution Policy wird dadurch nicht dauerhaft verändert.

---

## Fehlerbehebung

### Web Installer kann nicht geladen werden

> Prüfen:
  - Internetverbindung des Windows-PCs
  - vollständige Übernahme des PowerShell-Befehls
  - PowerShell-Zugriff auf `https://www.bylickilabs.de`
  - lokale Firewall- oder Sicherheitsrichtlinien

> Den vollständigen Installationsbefehl erneut ausführen:

```powershell
$h=@{"X-BYLICKILABS-Installer"="motd-installer"}; $f="$env:TEMP\motd_v0.2.ps1"; Invoke-WebRequest "https://www.bylickilabs.de/motd_v0.2.ps1" -Headers $h -OutFile $f; powershell.exe -NoProfile -ExecutionPolicy Bypass -File $f
```

---

### SSH ist nicht erreichbar

> Mögliche Ursachen:
  - falsche IP-Adresse
  - PlayStation Classic nicht vollständig gestartet
  - Netzwerkverbindung nicht aktiv
  - PC und Konsole befinden sich nicht im selben erreichbaren Netzwerk
  - Gäste-WLAN oder Client Isolation blockiert die Verbindung
  - SSH ist nicht aktiv

> Verbindung testen:

```powershell
ping IP-DER-PS-CLASSIC
```

```powershell
ssh root@IP-DER-PS-CLASSIC
```

---

## Bekannte Einschränkungen

> Für die aktuelle Version gelten folgende Einschränkungen:
  - BleemSync wird als Mod-Umgebung vorausgesetzt
  - Root-Zugriff muss bereits verfügbar sein
  - SSH muss erreichbar sein
  - Netzwerkisolierung kann SSH und SCP verhindern
  - andere Modding-Distributionen können abweichende Systemstrukturen verwenden
  - für den Web Installer wird eine Internetverbindung auf dem Windows-PC benötigt
  - die Terminaldarstellung kann von Terminalbreite und Zeichencodierung abhängen

---

## Haftungsausschluss

> [!CAUTION]
> Dieses Projekt ist für entsprechend modifizierte PlayStation-Classic-Systeme vorgesehen.

> **Die Verwendung erfolgt auf eigene Verantwortung.**

> Der Autor übernimmt keine Gewähr für:
  - Kompatibilität mit jeder Hardware- oder Softwarekonfiguration
  - Funktionsfähigkeit mit anderen Modding-Distributionen
  - Änderungen durch zukünftige System- oder BleemSync-Versionen
  - Datenverlust durch eigenständig vorgenommene Änderungen
  - Schäden durch unsachgemäße Verwendung von Root-Rechten
  - Schäden durch fehlerhafte Systemoperationen

| ISSUES SIND ZU BEACHTEN |
|---|

> Das Projekt dient ausschließlich der technischen Anpassung und Automatisierung auf Systemen, für deren Nutzung und Modifikation der jeweilige Anwender selbst verantwortlich ist.

---

## BYLICKILABS

| PROJEKT | INFORMATION |
|---|---|
| Projekt | PSx Classic Custom SSH MOTD |
| Installer | Web Installer v0.2 |
| Plattform | PlayStation Classic / BleemSync |
| Website | https://www.bylickilabs.de/ |

> Entwickelt und bereitgestellt von **Thorsten Bylicki** | **BYLICKILABS**.
