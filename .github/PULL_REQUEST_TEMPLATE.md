# 🎮 RetroArch Controller / Device Contribution

Vielen Dank für deinen Beitrag zum PSX Classic Modding Hub.

> [!IMPORTANT]
> Alle nachfolgenden Angaben sind verpflichtend.
> Unvollständige Pull Requests können nicht geprüft oder übernommen werden.
>
> Falls zu einem Punkt keine Abweichung oder Information vorliegt, muss dies ausdrücklich mit `Keine bekannt` bzw. `Nicht bekannt` angegeben werden.
> Pflichtfelder dürfen nicht leer bleiben.

---

## 1. RetroArch-Gerätebezeichnung

**Genaue Gerätebezeichnung, wie sie von RetroArch erkannt wird:**

```text
GERÄTEBEZEICHNUNG HIER EINTRAGEN
```

---

## 2. Vendor-ID und Product-ID – Dezimal

**Vendor-ID (VID) in Dezimalform:**

```text
VID DEZIMAL HIER EINTRAGEN
```

**Product-ID (PID) in Dezimalform:**

```text
PID DEZIMAL HIER EINTRAGEN
```

---

## 3. VID:PID – Hexadezimal

**VID:PID in Hexadezimalform:**

```text
VID:PID HIER EINTRAGEN
```

Beispiel:

```text
054C:05C4
```

Falls nicht bekannt:

```text
Nicht bekannt
```

---

## 4. RetroArch-Eingabetreiber

**Verwendeter RetroArch-Eingabetreiber:**

```text
EINGABETREIBER HIER EINTRAGEN
```

---

## 5. Vollständige Tastenbelegung

Die komplette Tastenbelegung des Controllers muss dokumentiert werden.

| Funktion | Physische Taste / Eingabe | RetroArch-Zuordnung |
|---|---|---|
| D-Pad Up | EINTRAGEN | EINTRAGEN |
| D-Pad Down | EINTRAGEN | EINTRAGEN |
| D-Pad Left | EINTRAGEN | EINTRAGEN |
| D-Pad Right | EINTRAGEN | EINTRAGEN |
| A / Cross | EINTRAGEN | EINTRAGEN |
| B / Circle | EINTRAGEN | EINTRAGEN |
| X / Square | EINTRAGEN | EINTRAGEN |
| Y / Triangle | EINTRAGEN | EINTRAGEN |
| L1 | EINTRAGEN | EINTRAGEN |
| R1 | EINTRAGEN | EINTRAGEN |
| L2 | EINTRAGEN | EINTRAGEN |
| R2 | EINTRAGEN | EINTRAGEN |
| L3 | EINTRAGEN | EINTRAGEN |
| R3 | EINTRAGEN | EINTRAGEN |
| Select | EINTRAGEN | EINTRAGEN |
| Start | EINTRAGEN | EINTRAGEN |
| Left Analog X | EINTRAGEN | EINTRAGEN |
| Left Analog Y | EINTRAGEN | EINTRAGEN |
| Right Analog X | EINTRAGEN | EINTRAGEN |
| Right Analog Y | EINTRAGEN | EINTRAGEN |

**Weitere vorhandene Tasten, Achsen oder Eingaben:**

```text
WEITERE EINGABEN HIER EINTRAGEN
```

Falls keine vorhanden sind:

```text
Keine
```

---

## 6. Getestetes System

**System / Plattform, auf der der Controller getestet wurde:**

```text
SYSTEM HIER EINTRAGEN
```

---

## 7. Getesteter RetroArch-Core

**Verwendeter Core:**

```text
CORE HIER EINTRAGEN
```

---

## 8. Getestetes Spiel

Für den Funktionstest muss mindestens ein konkretes Spiel angegeben werden.

**Spiel:**

```text
SPIEL HIER EINTRAGEN
```

---

## 9. Funktionstest

Beschreibe das Ergebnis des Tests.

**Controller-Erkennung:**

```text
ERGEBNIS HIER EINTRAGEN
```

**Tastenbelegung vollständig getestet:**

```text
JA / NEIN
```

**Analogsticks getestet:**

```text
JA / NEIN / NICHT VORHANDEN
```

**Schultertasten getestet:**

```text
JA / NEIN / NICHT VORHANDEN
```

**Start / Select getestet:**

```text
JA / NEIN / NICHT VORHANDEN
```

---

## 10. Bekannte Abweichungen

Dokumentiere sämtliche bekannten Abweichungen, Besonderheiten oder Einschränkungen.

```text
ABWEICHUNGEN HIER EINTRAGEN
```

Falls keine bekannt sind:

```text
Keine bekannt
```

---

## 11. Hardware-Revision

**Hersteller:**

```text
HERSTELLER HIER EINTRAGEN
```

**Modellbezeichnung:**

```text
MODELL HIER EINTRAGEN
```

**Hardware-Revision / Version:**

```text
REVISION HIER EINTRAGEN
```

Falls keine Revision erkennbar oder bekannt ist:

```text
Nicht bekannt
```

---

## 12. Abweichende Hardware-Revisionen

Sind weitere Revisionen dieses Controllers bekannt, die sich hinsichtlich VID, PID, Tastenbelegung oder Verhalten unterscheiden?

```text
INFORMATIONEN HIER EINTRAGEN
```

Falls keine bekannt sind:

```text
Keine bekannt
```

---

# ✅ Pflichtprüfung vor dem Pull Request

Mit dem Einreichen dieses Pull Requests bestätige ich:

- [ ] Die genaue RetroArch-Gerätebezeichnung wurde angegeben.
- [ ] Vendor-ID und Product-ID wurden in Dezimalform angegeben.
- [ ] VID:PID wurde in Hexadezimalform angegeben oder ausdrücklich als `Nicht bekannt` gekennzeichnet.
- [ ] Der verwendete RetroArch-Eingabetreiber wurde angegeben.
- [ ] Die vollständige Tastenbelegung wurde dokumentiert.
- [ ] Das getestete System wurde angegeben.
- [ ] Der getestete RetroArch-Core wurde angegeben.
- [ ] Mindestens ein konkretes getestetes Spiel wurde angegeben.
- [ ] Der Funktionstest wurde dokumentiert.
- [ ] Bekannte Abweichungen wurden angegeben oder ausdrücklich mit `Keine bekannt` gekennzeichnet.
- [ ] Die Hardware-Revision wurde angegeben oder ausdrücklich als `Nicht bekannt` gekennzeichnet.
- [ ] Bekannte abweichende Hardware-Revisionen wurden dokumentiert oder ausdrücklich mit `Keine bekannt` gekennzeichnet.
- [ ] Alle Angaben wurden auf der tatsächlichen Hardware getestet.
- [ ] Kein Pflichtfeld dieser Vorlage wurde entfernt oder leer gelassen.

---

## Pull-Request-Regel

Pull Requests mit fehlenden, unvollständigen oder nicht nachvollziehbaren Pflichtangaben gelten als **unvollständig** und können bis zur Ergänzung nicht übernommen werden.
