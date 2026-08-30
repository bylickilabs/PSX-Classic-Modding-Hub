# SystemC.ps1

| <img width="1492" height="772" alt="screenshot systemc" src="https://github.com/user-attachments/assets/9cb550b9-f3b9-4880-a31b-6ef5e23880db" /> |
|---|


<p align="center">
  <strong>PSX Classic Maintenance & Diagnostic Toolkit</strong>
</p>

<p align="center">
  <img alt="PowerShell" src="https://img.shields.io/badge/PowerShell-5.1%2B-blue">
  <img alt="Platform" src="https://img.shields.io/badge/Platform-Windows-lightgrey">
  <img alt="Target" src="https://img.shields.io/badge/Target-PlayStation%20Classic-black">
  <img alt="Version" src="https://img.shields.io/badge/Version-1.0.0-informational">
  <img alt="Status" src="https://img.shields.io/badge/Status-Stable-brightgreen">
</p>

| BYLICKILABS // PSX CLASSIC MAINTENANCE & DIAGNOSTICS |
|---|

> **SystemC.ps1** ist ein PowerShell-basiertes Wartungs- und Diagnosewerkzeug für modifizierte **Sony PlayStation Classic** Systeme.
  - zentrale Diagnose über eine übersichtliche Menüoberfläche
  - Remote-Kommunikation über SSH
  - strukturierte Statusausgabe
  - lokale Speicherung von Diagnose-Reports
  - ausgelegt für Wartung, Analyse und Fehlersuche

> [!NOTE]
> Das Tool konzentriert sich auf strukturierte Systemprüfungen und verändert während der Diagnose keine Konfigurationsdateien auf der PlayStation Classic.

<br>

---

<br>

## 🚀 Über das Projekt

> **SystemC.ps1** wurde entwickelt, um häufig benötigte Prüfungen einer modifizierten PlayStation Classic in einem einzigen Werkzeug zusammenzuführen.

> Statt einzelne SSH-Befehle und Verzeichnisse manuell kontrollieren zu müssen, übernimmt das Toolkit die Abfrage und Auswertung zentral über Windows PowerShell.
  - Systeminformationen werden remote ausgelesen.
  - bekannte Modding-Umgebungen werden erkannt.
  - RetroArch-, BIOS- und Controller-Bereiche werden geprüft.
  - PlayStation-Spielbibliotheken können analysiert werden.
  - relevante Logdateien werden erfasst.
  - Prüfergebnisse werden lokal dokumentiert.

> [!IMPORTANT]
> Für die Nutzung wird eine PlayStation Classic benötigt, die über das Netzwerk per SSH erreichbar ist.

<br>

---

<br>

## 🧰 Funktionsumfang

> Der aktuelle Funktionsumfang umfasst die wichtigsten Diagnosebereiche des Systems:
  - [x] vollständige Systemdiagnose
  - [x] System- und Speicherprüfung
  - [x] Erkennung bekannter Modding-Umgebungen
  - [x] RetroArch-Prüfung
  - [x] BIOS-Prüfung
  - [x] Controller-Konfigurationsprüfung
  - [x] Analyse von PlayStation-Spielbibliotheken
  - [x] Prüfung von BIN/CUE-Strukturen
  - [x] Erfassung von CHD- und PBP-Dateien
  - [x] Suche nach relevanten Logdateien
  - [x] SSH-Verbindungstest
  - [x] lokale Report-Erstellung
  - [x] Rückkehr zum Hauptmenü nach abgeschlossenen Prüfungen

| Bereich | Aufgabe |
|---|---|
| **System** | Grundlegende Systeminformationen und Laufzeitdaten erfassen |
| **Speicher** | Arbeitsspeicher, Dateisysteme und Mountpoints prüfen |
| **Modding** | bekannte Modding-Umgebungen erkennen |
| **RetroArch** | Installationspfade, Konfigurationen und Cores untersuchen |
| **BIOS** | bekannte BIOS-Bereiche nach geeigneten Dateien durchsuchen |
| **Controller** | RetroArch-Autoconfigurationen und Controller-CFGs prüfen |
| **Games** | PlayStation-Bibliothek und Dateistrukturen analysieren |
| **Logs** | relevante Logdateien in bekannten Bereichen erfassen |
| **SSH** | Erreichbarkeit des Zielsystems kontrollieren |
| **Reports** | Ergebnisse lokal und nachvollziehbar speichern |

<br>

---

<br>

## 🖥️ Bedienung

> **SystemC.ps1** wird über ein textbasiertes Hauptmenü gesteuert.

| Auswahl | Funktion |
|---:|---|
| `1` | Vollständige Diagnose |
| `2` | System und Speicher |
| `3` | Mod-Umgebung erkennen |
| `4` | RetroArch und BIOS |
| `5` | Controller-Konfigurationen |
| `6` | PlayStation BIN/CUE-Bibliothek |
| `7` | Logdateien |
| `8` | SSH-Verbindung testen |
| `0` | Tool beenden |

> Nach Abschluss eines Diagnosebereichs kann über **Enter** direkt zum Hauptmenü zurückgekehrt werden.

> [!TIP]
> Dadurch lassen sich mehrere Prüfbereiche nacheinander ausführen, ohne das PowerShell-Skript neu starten zu müssen.

<br>

---

<br>

## 🔎 Unterstützte Umgebungen

> Das Toolkit berücksichtigt mehrere verbreitete Modding- und RetroArch-Strukturen der PlayStation Classic.

  - **BleemSync**
  - **Project Eris**
  - **AutoBleem**
  - **RetroArch**
  - **RetroBoot**

> [!NOTE]
> Die Erkennung basiert auf bekannten Verzeichnisstrukturen. Abweichend installierte oder individuell angepasste Umgebungen können zusätzliche Anpassungen im Skript erforderlich machen.

<br>

---

<br>

## 🎮 PlayStation-Bibliothek

> Die Spielebibliotheksprüfung ist auf typische PlayStation-Dateiformate ausgelegt.

| Format | Unterstützung |
|---|---:|
| **BIN** | ✅ |
| **CUE** | ✅ |
| **CHD** | ✅ |
| **PBP** | ✅ |

> Bei BIN/CUE-Strukturen werden vorhandene CUE-Dateien ausgewertet und referenzierte Dateien überprüft.
  - fehlende CUE-Referenzen können erkannt werden
  - BIN-Dateien ohne gleichnamige CUE-Datei können hervorgehoben werden
  - Multi-Track-Strukturen werden bei der Bewertung berücksichtigt

<br>

---

<br>

## 📊 Statussystem

> Die Diagnoseausgabe verwendet ein einheitliches Statussystem.

| Status | Bedeutung |
|---|---|
| `[OK]` | Prüfung erfolgreich abgeschlossen |
| `[WARNING]` | Hinweis oder Abweichung festgestellt |
| `[ERROR]` | Fehler erkannt |
| `[INFO]` | zusätzliche System- oder Diagnoseinformation |

> Nach einer Prüfung wird eine Zusammenfassung mit den ermittelten Statuswerten erstellt.

<br>

---

<br>

## 📝 Diagnose-Reports

> Ausgeführte Diagnosemodule können automatisch als lokale Textreports gespeichert werden.

> Die Reports werden standardmäßig im Verzeichnis `psx_reports` neben dem PowerShell-Skript abgelegt.
  - Zeitstempel im Dateinamen
  - Zielsystem und Prüfauftrag im Report
  - strukturierte Diagnoseausgabe
  - Statuszusammenfassung
  - getrennte Reports für einzelne Prüfbereiche
  - eigener Report für die vollständige Diagnose

> [!TIP]
> Die gespeicherten Reports können für spätere Vergleiche, Fehlersuche oder Dokumentation verwendet werden.

<br>

---

<br>

## ✅ Voraussetzungen

> Für die Verwendung des Toolkits werden folgende Komponenten benötigt:
  - [x] Windows 10 oder Windows 11
  - [x] Windows PowerShell 5.1 oder neuer
  - [x] alternativ PowerShell 7 oder neuer
  - [x] installierter OpenSSH Client
  - [x] Netzwerkverbindung zur PlayStation Classic
  - [x] aktivierter SSH-Zugriff auf der PlayStation Classic
  - [x] unterstützte beziehungsweise entsprechend eingerichtete Modding-Umgebung

> [!IMPORTANT]
> Der Windows OpenSSH Client muss verfügbar sein, da sämtliche Remote-Abfragen über SSH ausgeführt werden.

<br>

---

<br>

## ⚙️ Verbindungskonfiguration

> Die SSH-Verbindungsparameter können beim Start des Skripts beziehungsweise innerhalb der Konfiguration angepasst werden.

| Parameter | Dokumentationswert |
|---|---|
| **IP-Adresse** | `192.168.2.75` |
| **Benutzer** | `root` |
| **Port** | `22` |
| **Verbindungstimeout** | `5 Sekunden` |

> [!NOTE]
> Für die öffentliche Dokumentation wird die Adresse `192.168.2.75` verwendet.
>
> Die Zieladresse muss an die tatsächliche Netzwerkadresse der eigenen PlayStation Classic angepasst werden.

<br>

---

<br>

## 📦 Installation

> **SystemC.ps1** benötigt keine klassische Installation.
  - Repository herunterladen oder klonen
  - `SystemC.ps1` in einem lokalen Verzeichnis speichern
  - PowerShell in diesem Verzeichnis öffnen
  - SSH-Erreichbarkeit der PlayStation Classic sicherstellen
  - Skript starten

> [!NOTE]
> Zusätzliche externe PowerShell-Module werden für die grundlegende Ausführung nicht vorausgesetzt.

<br>

---

<br>

## ▶️ Start

> Das Toolkit wird direkt über PowerShell gestartet.

```powershell
.\SystemC.ps1
```

> Für einen vollständigen Diagnoselauf ohne Navigation durch das Hauptmenü kann der integrierte Parameter verwendet werden:

```powershell
.\SystemC.ps1 -Full
```

> Für einen reinen SSH-Verbindungstest steht ebenfalls ein eigener Startparameter zur Verfügung:

```powershell
.\SystemC.ps1 -Test
```

> Falls die lokale PowerShell-Ausführungsrichtlinie den Start verhindert:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
```

> [!NOTE]
> Diese Änderung gilt ausschließlich für das aktuell geöffnete PowerShell-Fenster.
>
> Beim Schließen der PowerShell-Sitzung wird die temporäre Änderung automatisch verworfen.
>
> Die systemweite Execution Policy wird dadurch nicht dauerhaft verändert.

<br>

---

<br>

## 🧩 Technisches Konzept

> Die Architektur folgt einem einfachen Client-Remote-Prinzip.

```text
Windows PC
    │
    │ PowerShell + OpenSSH
    │
    ▼
SystemC.ps1
    │
    │ SSH
    ▼
PlayStation Classic
    │
    ├── Linux-System
    ├── Speicher
    ├── Modding-Umgebung
    ├── RetroArch
    ├── BIOS
    ├── Controller-Konfigurationen
    ├── Spielebibliothek
    └── Logdateien
```

> Kleine und kompatible Shell-Kommandos werden auf der PlayStation Classic ausgeführt.
  - Die Remote-Ausgabe wird anschließend durch PowerShell verarbeitet.
  - Die Auswertung und Report-Erstellung erfolgt auf dem Windows-PC.
  - Dadurch bleibt die Belastung des Zielsystems gering.

<br>

---

<br>

## 🔐 Sicherheit

> Die Diagnosefunktionen sind überwiegend für **lesende Systemprüfungen** ausgelegt.

> Das Toolkit sollte ausschließlich auf eigenen Geräten oder auf Systemen verwendet werden, für die eine ausdrückliche Berechtigung vorliegt.

> [!WARNING]
> Vor manuellen Änderungen an Modding-, RetroArch-, BIOS- oder Controller-Konfigurationen sollten immer aktuelle Backups angelegt werden.

> [!CAUTION]
> Die Nutzung erfolgt auf eigene Verantwortung. Änderungen außerhalb der reinen Diagnosefunktionen können Auswirkungen auf eine modifizierte PlayStation Classic haben.

<br>

---

<br>

## 📈 Entwicklungsstatus

> **SystemC.ps1 v1.0.0** befindet sich im stabilen Entwicklungsstand.

| Komponente | Status |
|---|---|
| Hauptmenü | ✅ Funktioniert |
| Rückkehr zum Hauptmenü | ✅ Funktioniert |
| SSH-Verbindung | ✅ Funktioniert |
| Systemdiagnose | ✅ Implementiert |
| Speicherprüfung | ✅ Implementiert |
| Mod-Erkennung | ✅ Implementiert |
| RetroArch & BIOS | ✅ Implementiert |
| Controller-Prüfung | ✅ Implementiert |
| Spielebibliothek | ✅ Implementiert |
| Logdatei-Prüfung | ✅ Implementiert |
| Report-System | ✅ Implementiert |

<br>

---

<br>

## ⚠️ Disclaimer

> **SystemC.ps1** ist ein unabhängiges Community- und Entwicklungsprojekt von **BYLICKILABS**.

> Das Projekt steht in keiner Verbindung zu **Sony Interactive Entertainment** und wird von Sony weder unterstützt noch autorisiert.

> **PlayStation** und **PlayStation Classic** sind Marken beziehungsweise eingetragene Marken ihrer jeweiligen Rechteinhaber.

> [!CAUTION]
> Die Verwendung des Tools erfolgt auf eigene Verantwortung.

<br>

---

<br>

## 🌐 BYLICKILABS

| PROJEKTINFORMATION |
|---|

> **SystemC.ps1**  
> PSX Classic Maintenance & Diagnostic Toolkit  
> Version **1.0.0**

> Developed by **BYLICKILABS**

  - GitHub: https://github.com/bylickilabs
  - Website: https://bylickilabs.de

<br>

---

<br>

<p align="center">
  <strong>BYLICKILABS // PSX CLASSIC MODDING & DIAGNOSTICS</strong>
</p>
