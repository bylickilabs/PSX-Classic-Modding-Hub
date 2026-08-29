[CmdletBinding()]
param(
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$PSXIP = 'DEINE-PSx-CLASSIC-IP-HIER-EINTRAGEN',

    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$PSXUser = 'root',

    [Parameter()]
    [ValidateRange(1, 65535)]
    [int]$PSXPort = 22,

    [Parameter()]
    [ValidateRange(1, 60)]
    [int]$ConnectTimeout = 5,

    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$ReportDir = (Join-Path -Path $PSScriptRoot -ChildPath 'psx_reports'),

    [Parameter()]
    [switch]$Full,

    [Parameter()]
    [switch]$Test
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'

$ToolName = 'PSX Classic Maintenance Toolkit'
$Version = '1.0.0'
$Vendor = 'BYLICKILABS'
$Target = '{0}@{1}:{2}' -f $PSXUser, $PSXIP, $PSXPort
$script:CurrentReport = $null
$script:SSHCommand = $null
$script:Stats = [ordered]@{ OK = 0; Warning = 0; Error = 0; Info = 0 }

$KnownModPaths = @(
    @{ Name = 'BleemSync';      Path = '/media/bleemsync' },
    @{ Name = 'BleemSync';      Path = '/media/BleemSync' },
    @{ Name = 'Project Eris';   Path = '/media/project_eris' },
    @{ Name = 'Project Eris';   Path = '/media/Project_Eris' },
    @{ Name = 'Project Eris';   Path = '/media/ProjectEris' },
    @{ Name = 'AutoBleem';      Path = '/media/Autobleem' },
    @{ Name = 'AutoBleem';      Path = '/media/AutoBleem' },
    @{ Name = 'AutoBleem';      Path = '/media/autobleem' },
    @{ Name = 'RetroArch';      Path = '/media/retroarch' },
    @{ Name = 'RetroArch';      Path = '/media/RetroArch' },
    @{ Name = 'RetroBoot';      Path = '/media/retroboot' },
    @{ Name = 'RetroBoot';      Path = '/media/RetroBoot' }
)

$RetroArchRoots = @(
    '/media/retroarch',
    '/media/RetroArch',
    '/media/Autobleem/retroarch',
    '/media/AutoBleem/retroarch',
    '/media/autobleem/retroarch',
    '/media/project_eris/opt/retroarch',
    '/media/bleemsync/opt/retroarch',
    '/media/retroboot/retroarch'
)

$RetroArchConfigs = @(
    '/media/retroarch/retroarch.cfg',
    '/media/RetroArch/retroarch.cfg',
    '/media/Autobleem/retroarch/retroarch.cfg',
    '/media/AutoBleem/retroarch/retroarch.cfg',
    '/media/autobleem/retroarch/retroarch.cfg',
    '/media/project_eris/opt/retroarch/config/retroarch.cfg',
    '/media/bleemsync/opt/retroarch/config/retroarch.cfg'
)

$BiosRoots = @(
    '/media/retroarch/system',
    '/media/RetroArch/system',
    '/media/Autobleem/retroarch/system',
    '/media/AutoBleem/retroarch/system',
    '/media/autobleem/retroarch/system',
    '/media/project_eris/opt/retroarch/system',
    '/media/bleemsync/opt/retroarch/system'
)

$GameRoots = @(
    '/media/Games',
    '/media/games',
    '/media/roms',
    '/media/ROMS',
    '/media/RetroArch/roms',
    '/media/retroarch/roms',
    '/media/Autobleem/Games',
    '/media/AutoBleem/Games',
    '/media/autobleem/Games'
)

$LogRoots = @(
    '/media/bleemsync',
    '/media/project_eris',
    '/media/Autobleem',
    '/media/AutoBleem',
    '/media/autobleem',
    '/media/retroarch',
    '/media/RetroArch'
)

function Write-Banner {
    Clear-Host
    Write-Host '============================================================' -ForegroundColor Cyan
    Write-Host ("{0} v{1}" -f $ToolName, $Version) -ForegroundColor Cyan
    Write-Host $Vendor
    Write-Host ("Target: {0}" -f $Target)
    Write-Host '============================================================' -ForegroundColor Cyan
}

function Reset-RunStats {
    $script:Stats = [ordered]@{ OK = 0; Warning = 0; Error = 0; Info = 0 }
}

function Write-Diag {
    param(
        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string]$Text,

        [Parameter()]
        [ValidateSet('Normal', 'OK', 'Warning', 'Error', 'Info', 'Section')]
        [string]$Kind = 'Normal'
    )

    $line = $Text
    switch ($Kind) {
        'OK' {
            $script:Stats.OK++
            $line = '[OK]      ' + $Text
            Write-Host $line -ForegroundColor Green
        }
        'Warning' {
            $script:Stats.Warning++
            $line = '[WARNING] ' + $Text
            Write-Host $line -ForegroundColor Yellow
        }
        'Error' {
            $script:Stats.Error++
            $line = '[ERROR]   ' + $Text
            Write-Host $line -ForegroundColor Red
        }
        'Info' {
            $script:Stats.Info++
            $line = '[INFO]    ' + $Text
            Write-Host $line
        }
        'Section' {
            Write-Host ''
            Write-Host ('=' * 68) -ForegroundColor DarkGray
            Write-Host ('  ' + $Text) -ForegroundColor Cyan
            Write-Host ('=' * 68) -ForegroundColor DarkGray
            if ($script:CurrentReport) {
                Add-Content -LiteralPath $script:CurrentReport -Value '' -Encoding UTF8
                Add-Content -LiteralPath $script:CurrentReport -Value ('=' * 68) -Encoding UTF8
                Add-Content -LiteralPath $script:CurrentReport -Value ('  ' + $Text) -Encoding UTF8
                Add-Content -LiteralPath $script:CurrentReport -Value ('=' * 68) -Encoding UTF8
            }
            return
        }
        default { Write-Host $line }
    }

    if ($script:CurrentReport) {
        Add-Content -LiteralPath $script:CurrentReport -Value $line -Encoding UTF8
    }
}

function Write-KeyValue {
    param(
        [Parameter(Mandatory)][string]$Label,
        [Parameter(Mandatory)][AllowEmptyString()][string]$Value
    )

    $line = '  {0,-22} : {1}' -f $Label, $Value
    Write-Host $line
    if ($script:CurrentReport) {
        Add-Content -LiteralPath $script:CurrentReport -Value $line -Encoding UTF8
    }
}

function Write-RunSummary {
    param([Parameter(Mandatory)][string]$ReportFile)

    Write-Host ''
    Write-Host ('=' * 68) -ForegroundColor DarkGray
    Write-Host '  ERGEBNIS-ZUSAMMENFASSUNG' -ForegroundColor Cyan
    Write-Host ('=' * 68) -ForegroundColor DarkGray

    Write-Host ('  OK        : {0}' -f $script:Stats.OK) -ForegroundColor Green
    Write-Host ('  WARNUNGEN : {0}' -f $script:Stats.Warning) -ForegroundColor Yellow
    Write-Host ('  FEHLER    : {0}' -f $script:Stats.Error) -ForegroundColor Red

    if ($script:Stats.Error -gt 0) {
        Write-Host '  STATUS    : FEHLER GEFUNDEN' -ForegroundColor Red
    }
    elseif ($script:Stats.Warning -gt 0) {
        Write-Host '  STATUS    : PRUEFUNG MIT HINWEISEN ABGESCHLOSSEN' -ForegroundColor Yellow
    }
    else {
        Write-Host '  STATUS    : PRUEFUNG ERFOLGREICH ABGESCHLOSSEN' -ForegroundColor Green
    }

    Write-Host ('  REPORT    : {0}' -f $ReportFile)

    if ($script:CurrentReport) {
        Add-Content -LiteralPath $script:CurrentReport -Value '' -Encoding UTF8
        Add-Content -LiteralPath $script:CurrentReport -Value ('=' * 68) -Encoding UTF8
        Add-Content -LiteralPath $script:CurrentReport -Value '  ERGEBNIS-ZUSAMMENFASSUNG' -Encoding UTF8
        Add-Content -LiteralPath $script:CurrentReport -Value ('=' * 68) -Encoding UTF8
        Add-Content -LiteralPath $script:CurrentReport -Value ('  OK        : {0}' -f $script:Stats.OK) -Encoding UTF8
        Add-Content -LiteralPath $script:CurrentReport -Value ('  WARNUNGEN : {0}' -f $script:Stats.Warning) -Encoding UTF8
        Add-Content -LiteralPath $script:CurrentReport -Value ('  FEHLER    : {0}' -f $script:Stats.Error) -Encoding UTF8
        Add-Content -LiteralPath $script:CurrentReport -Value ('  REPORT    : {0}' -f $ReportFile) -Encoding UTF8
    }
}

function Test-HostRequirements {
    $ssh = Get-Command 'ssh.exe' -ErrorAction SilentlyContinue
    if (-not $ssh) {
        $ssh = Get-Command 'ssh' -ErrorAction SilentlyContinue
    }

    if (-not $ssh) {
        Write-Host '[ERROR] OpenSSH Client wurde unter Windows nicht gefunden.' -ForegroundColor Red
        Write-Host 'Aktiviere unter Windows das optionale Feature "OpenSSH Client".'
        return $false
    }

    $script:SSHCommand = $ssh.Source
    return $true
}

function Get-SSHArguments {
    return @(
        '-n',
        '-p', [string]$PSXPort,
        '-o', ("ConnectTimeout={0}" -f $ConnectTimeout),
        '-o', 'ServerAliveInterval=5',
        '-o', 'ServerAliveCountMax=2',
        '-o', 'StrictHostKeyChecking=accept-new'
    )
}

function ConvertTo-RemoteQuotedPath {
    param([Parameter(Mandatory)][string]$Value)

    $escaped = $Value.Replace('\', '\\')
    $escaped = $escaped.Replace('"', '\"')
    $escaped = $escaped.Replace('$', '\$')
    $escaped = $escaped.Replace('`', '\`')
    return '"' + $escaped + '"'
}

function Invoke-PSXCommand {
    param(
        [Parameter(Mandatory)]
        [string]$Command,

        [Parameter()]
        [switch]$AllowFailure
    )

    $sshArgs = Get-SSHArguments
    $remoteTarget = '{0}@{1}' -f $PSXUser, $PSXIP

    $output = @()
    try {
        $output = @(& $script:SSHCommand @sshArgs $remoteTarget $Command 2>&1 | ForEach-Object { [string]$_ })
        $exitCode = $LASTEXITCODE
    }
    catch {
        if ($AllowFailure) {
            return [pscustomobject]@{ ExitCode = 255; Output = @($_.Exception.Message) }
        }
        throw
    }

    if (($exitCode -ne 0) -and (-not $AllowFailure)) {
        $detail = ($output -join [Environment]::NewLine)
        if ([string]::IsNullOrWhiteSpace($detail)) {
            $detail = 'Kein zusaetzlicher SSH-Fehlertext.'
        }
        throw ("SSH-Befehl fehlgeschlagen (ExitCode {0}): {1}" -f $exitCode, $detail)
    }

    return [pscustomobject]@{
        ExitCode = $exitCode
        Output   = $output
    }
}

function Test-PSXConnection {
    Write-Host -NoNewline ("Pruefe SSH-Verbindung zu {0} ... " -f $PSXIP)

    $result = Invoke-PSXCommand -Command 'printf connected' -AllowFailure
    if (($result.ExitCode -eq 0) -and (($result.Output -join '') -eq 'connected')) {
        Write-Host 'OK' -ForegroundColor Green
        return $true
    }

    Write-Host 'FEHLGESCHLAGEN' -ForegroundColor Red
    Write-Host ("Keine SSH-Verbindung zu {0} moeglich." -f $Target) -ForegroundColor Red
    if ($result.Output.Count -gt 0) {
        $result.Output | ForEach-Object { Write-Host ("[SSH] {0}" -f $_) }
    }
    return $false
}

function Test-RemoteDirectory {
    param([Parameter(Mandatory)][string]$Path)
    $quoted = ConvertTo-RemoteQuotedPath $Path
    $r = Invoke-PSXCommand -Command ("test -d {0}" -f $quoted) -AllowFailure
    return ($r.ExitCode -eq 0)
}

function Test-RemoteFile {
    param([Parameter(Mandatory)][string]$Path)
    $quoted = ConvertTo-RemoteQuotedPath $Path
    $r = Invoke-PSXCommand -Command ("test -f {0}" -f $quoted) -AllowFailure
    return ($r.ExitCode -eq 0)
}

function Get-RemoteFileList {
    param([Parameter(Mandatory)][string]$Root)
    $quoted = ConvertTo-RemoteQuotedPath $Root
    $r = Invoke-PSXCommand -Command ("find {0} -type f 2>/dev/null" -f $quoted) -AllowFailure
    if ($r.ExitCode -ne 0) { return @() }
    return @($r.Output | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
}

function Invoke-SystemCheck {
    Write-Diag -Text 'SYSTEM UND SPEICHER' -Kind Section

    $checks = @(
        @{ Label = 'Hostname'; Command = 'hostname 2>/dev/null' },
        @{ Label = 'Kernel'; Command = 'uname -a 2>/dev/null' },
        @{ Label = 'Systemzeit'; Command = 'date 2>/dev/null' },
        @{ Label = 'Uptime'; Command = 'uptime 2>/dev/null' }
    )

    foreach ($check in $checks) {
        $r = Invoke-PSXCommand -Command $check.Command -AllowFailure
        if (($r.ExitCode -eq 0) -and ($r.Output.Count -gt 0)) {
            Write-KeyValue -Label $check.Label -Value ($r.Output -join ' ')
        }
        else {
            Write-Diag -Text ("{0} konnte nicht ausgelesen werden." -f $check.Label) -Kind Warning
        }
    }

    $yearResult = Invoke-PSXCommand -Command 'date +%Y 2>/dev/null' -AllowFailure
    if (($yearResult.ExitCode -eq 0) -and ($yearResult.Output.Count -gt 0)) {
        $remoteYear = 0
        if ([int]::TryParse(($yearResult.Output[0]).Trim(), [ref]$remoteYear)) {
            $localYear = (Get-Date).Year
            if ([math]::Abs($localYear - $remoteYear) -gt 1) {
                Write-Diag -Text ("Systemzeit der PSX Classic wirkt falsch: Konsolenjahr {0}, PC-Jahr {1}." -f $remoteYear, $localYear) -Kind Warning
            }
        }
    }

    Write-Diag -Text 'ARBEITSSPEICHER' -Kind Section
    $mem = Invoke-PSXCommand -Command 'cat /proc/meminfo 2>/dev/null' -AllowFailure
    if ($mem.ExitCode -eq 0) {
        $wanted = @($mem.Output | Where-Object { $_ -match '^(MemTotal|MemFree|MemAvailable|Buffers|Cached):' })
        if ($wanted.Count -gt 0) {
            foreach ($line in $wanted) {
                if ($line -match '^([^:]+):\s*(.*)$') {
                    Write-KeyValue -Label $Matches[1] -Value $Matches[2]
                }
                else {
                    Write-Diag -Text $line -Kind Info
                }
            }
        }
        else {
            Write-Diag -Text '/proc/meminfo liefert keine erwarteten Werte.' -Kind Warning
        }
    }

    Write-Diag -Text 'EINGEHAENGTE SPEICHER' -Kind Section
    $df = Invoke-PSXCommand -Command 'df -h 2>/dev/null' -AllowFailure
    if ($df.ExitCode -ne 0) {
        $df = Invoke-PSXCommand -Command 'df 2>/dev/null' -AllowFailure
    }
    if ($df.Output.Count -gt 0) {
        $tableHeader = '  {0,-18} {1,8} {2,8} {3,10} {4,7}  {5}' -f 'DATEISYSTEM', 'GROESSE', 'BELEGT', 'FREI', 'NUTZUNG', 'MOUNT'
        Write-Host $tableHeader -ForegroundColor DarkGray
        if ($script:CurrentReport) { Add-Content -LiteralPath $script:CurrentReport -Value $tableHeader -Encoding UTF8 }

        foreach ($line in $df.Output) {
            if ([string]::IsNullOrWhiteSpace($line) -or $line -match '^Filesystem') { continue }
            $parts = @($line.Trim() -split '\s+')
            if ($parts.Count -ge 6) {
                $mount = ($parts[5..($parts.Count - 1)] -join ' ')
                $formatted = '  {0,-18} {1,8} {2,8} {3,10} {4,7}  {5}' -f $parts[0], $parts[1], $parts[2], $parts[3], $parts[4], $mount
                Write-Diag -Text $formatted
            }
            else {
                Write-Diag -Text ('  ' + $line)
            }
        }
    }
    else {
        Write-Diag -Text 'Speicherinformationen konnten nicht ermittelt werden.' -Kind Warning
    }

    if (Test-RemoteDirectory '/media') {
        Write-Diag -Text '/media ist vorhanden und erreichbar.' -Kind OK
    }
    else {
        Write-Diag -Text '/media wurde nicht gefunden.' -Kind Warning
    }

    Write-Diag -Text 'NETZWERK' -Kind Section
    $net = Invoke-PSXCommand -Command 'ifconfig 2>/dev/null' -AllowFailure
    if ($net.ExitCode -ne 0) {
        $net = Invoke-PSXCommand -Command 'ip addr 2>/dev/null' -AllowFailure
    }
    if ($net.Output.Count -gt 0) {
        $interesting = @($net.Output | Where-Object {
            $_ -match '^[A-Za-z0-9_.:-]+\s' -or
            $_ -match '(?i)inet (addr:)?[0-9]' -or
            $_ -match '(?i)(HWaddr|ether)\s'
        })

        if ($interesting.Count -gt 0) {
            foreach ($line in $interesting) {
                Write-Diag -Text ('  ' + $line.Trim())
            }
        }
        else {
            $net.Output | Select-Object -First 12 | ForEach-Object { Write-Diag -Text ('  ' + $_) }
        }
    }
    else {
        Write-Diag -Text 'Weder ifconfig noch ip addr lieferte Daten.' -Kind Warning
    }
}

function Invoke-ModCheck {
    Write-Diag -Text 'MOD-UMGEBUNG ERKENNEN' -Kind Section

    Write-KeyValue -Label 'Suchbasis' -Value '/media und bekannte Mod-Pfade'

    $found = 0
    $seen = @{}
    foreach ($entry in $KnownModPaths) {
        if (Test-RemoteDirectory $entry.Path) {
            $key = $entry.Name + '|' + $entry.Path
            if (-not $seen.ContainsKey($key)) {
                Write-Diag -Text ("{0} erkannt: {1}" -f $entry.Name, $entry.Path) -Kind OK
                $seen[$key] = $true
                $found++
            }
        }
    }

    if ($found -eq 0) {
        Write-Diag -Text 'Keine bekannte Mod-Umgebung in den Standardpfaden erkannt.' -Kind Warning
    }
}

function Invoke-RetroArchCheck {
    Write-Diag -Text 'RETROARCH UND BIOS' -Kind Section

    Write-KeyValue -Label 'Status' -Value 'Suche nach RetroArch-Installationen'

    $existingRoots = @()
    foreach ($root in $RetroArchRoots) {
        if (Test-RemoteDirectory $root) {
            $existingRoots += $root
            Write-Diag -Text ("RetroArch-Verzeichnis: {0}" -f $root) -Kind OK
        }
    }

    if ($existingRoots.Count -eq 0) {
        Write-Diag -Text 'Kein RetroArch-Verzeichnis in den bekannten Pfaden gefunden.' -Kind Warning
    }

    $configFound = $false
    foreach ($cfg in $RetroArchConfigs) {
        if (Test-RemoteFile $cfg) {
            Write-Diag -Text ("retroarch.cfg gefunden: {0}" -f $cfg) -Kind OK
            $configFound = $true
        }
    }
    if (-not $configFound) {
        Write-Diag -Text 'retroarch.cfg wurde in den bekannten Pfaden nicht gefunden.' -Kind Warning
    }

    $allCores = New-Object System.Collections.Generic.List[string]
    foreach ($root in $existingRoots) {
        $quoted = ConvertTo-RemoteQuotedPath $root
        $coreResult = Invoke-PSXCommand -Command ("find {0} -type f -name '*.so' 2>/dev/null" -f $quoted) -AllowFailure
        if ($coreResult.ExitCode -eq 0) {
            foreach ($item in $coreResult.Output) {
                if (-not [string]::IsNullOrWhiteSpace($item)) { [void]$allCores.Add($item) }
            }
        }
    }
    Write-KeyValue -Label 'Core-Dateien (*.so)' -Value ([string]$allCores.Count)

    Write-Diag -Text 'BIOS-PRUEFUNG' -Kind Section
    $biosFound = 0
    foreach ($biosRoot in $BiosRoots) {
        if (-not (Test-RemoteDirectory $biosRoot)) { continue }
        $files = Get-RemoteFileList -Root $biosRoot
        $biosFiles = @($files | Where-Object {
            $leaf = ($_ -replace '^.*/', '')
            $leaf -match '(?i)^(scph|ps[-_]?xonpsp|bios).*(\.bin|\.rom)$'
        })
        if ($biosFiles.Count -gt 0) {
            Write-Diag -Text ("BIOS-Kandidaten in {0}: {1}" -f $biosRoot, $biosFiles.Count) -Kind OK
            $biosFiles | ForEach-Object { Write-Diag -Text ("  {0}" -f $_) }
            $biosFound += $biosFiles.Count
        }
    }

    if ($biosFound -eq 0) {
        Write-Diag -Text 'Kein PlayStation-BIOS-Kandidat in den bekannten RetroArch-Systemverzeichnissen gefunden.' -Kind Warning
    }
}

function Invoke-ControllerCheck {
    Write-Diag -Text 'CONTROLLER-KONFIGURATIONEN' -Kind Section

    Write-KeyValue -Label 'Pruefung' -Value 'RetroArch autoconfig / Controller-CFGs'

    $cfgFiles = New-Object System.Collections.Generic.List[string]
    $autoconfigDirs = New-Object System.Collections.Generic.List[string]

    foreach ($root in $RetroArchRoots) {
        if (-not (Test-RemoteDirectory $root)) { continue }
        $quoted = ConvertTo-RemoteQuotedPath $root
        $result = Invoke-PSXCommand -Command ("find {0} -type f -name '*.cfg' 2>/dev/null" -f $quoted) -AllowFailure
        if ($result.ExitCode -ne 0) { continue }

        foreach ($file in $result.Output) {
            if ([string]::IsNullOrWhiteSpace($file)) { continue }
            if ($file -match '(?i)/autoconfig/') {
                [void]$cfgFiles.Add($file)
                $dir = $file.Substring(0, $file.LastIndexOf('/'))
                if (-not $autoconfigDirs.Contains($dir)) { [void]$autoconfigDirs.Add($dir) }
            }
        }
    }

    if ($autoconfigDirs.Count -eq 0) {
        Write-Diag -Text 'Kein RetroArch-autoconfig-Verzeichnis mit CFG-Dateien gefunden.' -Kind Warning
    }
    else {
        foreach ($dir in $autoconfigDirs) {
            $count = @($cfgFiles | Where-Object { $_.StartsWith($dir + '/', [System.StringComparison]::OrdinalIgnoreCase) }).Count
            Write-Diag -Text ("Autoconfig: {0} ({1} CFG-Dateien)" -f $dir, $count) -Kind Info
        }
        Write-Diag -Text ("Controller-CFG-Dateien insgesamt: {0}" -f $cfgFiles.Count) -Kind OK
    }

    Write-Diag -Text 'DOPPELTE CFG-DATEINAMEN' -Kind Section
    $groups = @($cfgFiles | Group-Object { ($_ -replace '^.*/', '').ToLowerInvariant() } | Where-Object { $_.Count -gt 1 })
    if ($groups.Count -eq 0) {
        Write-Diag -Text 'Keine doppelten Controller-CFG-Dateinamen erkannt.' -Kind OK
    }
    else {
        foreach ($group in $groups) {
            Write-Diag -Text ("Doppelter Dateiname: {0} ({1}x)" -f $group.Name, $group.Count) -Kind Warning
            $group.Group | ForEach-Object { Write-Diag -Text ("  {0}" -f $_) }
        }
    }
}

function Invoke-GameCheck {
    Write-Diag -Text 'PLAYSTATION BIN/CUE-BIBLIOTHEK' -Kind Section

    $rootsFound = 0
    foreach ($root in $GameRoots) {
        if (-not (Test-RemoteDirectory $root)) { continue }
        $rootsFound++
        Write-Diag -Text ("Spielverzeichnis erkannt: {0}" -f $root) -Kind OK
        Write-KeyValue -Label 'Verzeichnis' -Value $root

        $files = Get-RemoteFileList -Root $root
        if ($files.Count -eq 0) {
            Write-Diag -Text ("Keine Dateien unter {0} gefunden oder find konnte nicht ausgefuehrt werden." -f $root) -Kind Warning
            continue
        }

        $cueFiles = @($files | Where-Object { $_ -match '(?i)\.cue$' })
        $binFiles = @($files | Where-Object { $_ -match '(?i)\.bin$' })
        $chdFiles = @($files | Where-Object { $_ -match '(?i)\.chd$' })
        $pbpFiles = @($files | Where-Object { $_ -match '(?i)\.pbp$' })

        Write-KeyValue -Label 'CUE-Dateien' -Value ([string]$cueFiles.Count)
        Write-KeyValue -Label 'BIN-Dateien' -Value ([string]$binFiles.Count)
        Write-KeyValue -Label 'CHD-Dateien' -Value ([string]$chdFiles.Count)
        Write-KeyValue -Label 'PBP-Dateien' -Value ([string]$pbpFiles.Count)

        $broken = 0
        foreach ($cue in $cueFiles) {
            $cueQuoted = ConvertTo-RemoteQuotedPath $cue
            $cat = Invoke-PSXCommand -Command ("cat {0} 2>/dev/null" -f $cueQuoted) -AllowFailure
            if ($cat.ExitCode -ne 0) {
                Write-Diag -Text ("CUE konnte nicht gelesen werden: {0}" -f $cue) -Kind Warning
                continue
            }

            $lastSlash = $cue.LastIndexOf('/')
            if ($lastSlash -ge 0) { $cueDir = $cue.Substring(0, $lastSlash) } else { $cueDir = '.' }

            foreach ($cueLine in $cat.Output) {
                if ($cueLine -match '(?i)^\s*FILE\s+(?:"([^"]+)"|(\S+))') {
                    if (-not [string]::IsNullOrEmpty($Matches[1])) { $ref = $Matches[1] } else { $ref = $Matches[2] }
                    if ($ref.StartsWith('/')) { $refPath = $ref } else { $refPath = $cueDir.TrimEnd('/') + '/' + $ref }
                    if (-not (Test-RemoteFile $refPath)) {
                        Write-Diag -Text ("Defekter CUE-Verweis: {0} -> {1}" -f $cue, $ref) -Kind Error
                        $broken++
                    }
                }
            }
        }

        if ($broken -eq 0) {
            Write-Diag -Text 'Alle ausgewerteten CUE-FILE-Verweise zeigen auf vorhandene Dateien.' -Kind OK
        }
        else {
            Write-Diag -Text ("Defekte CUE-FILE-Verweise: {0}" -f $broken) -Kind Error
        }

        $cueLookup = @{}
        foreach ($cue in $cueFiles) { $cueLookup[$cue.ToLowerInvariant()] = $true }
        $orphans = New-Object System.Collections.Generic.List[string]
        foreach ($bin in $binFiles) {
            $base = $bin.Substring(0, $bin.Length - 4)
            $sameCue = ($base + '.cue').ToLowerInvariant()
            if (-not $cueLookup.ContainsKey($sameCue)) { [void]$orphans.Add($bin) }
        }

        if ($orphans.Count -eq 0) {
            Write-Diag -Text 'Jede BIN-Datei besitzt eine gleichnamige CUE-Datei.' -Kind OK
        }
        else {
            Write-Diag -Text ("{0} BIN-Datei(en) ohne gleichnamige CUE. Bei Multi-Track-Sets kann das legitim sein." -f $orphans.Count) -Kind Warning
            $orphans | ForEach-Object { Write-Diag -Text ("  {0}" -f $_) }
        }
    }

    if ($rootsFound -eq 0) {
        Write-Diag -Text 'Keines der bekannten Spielverzeichnisse wurde gefunden.' -Kind Warning
    }
}

function Invoke-LogCheck {
    Write-Diag -Text 'LOGDATEIEN' -Kind Section

    Write-KeyValue -Label 'Dateitypen' -Value '*.log / *log.txt'
    Write-KeyValue -Label 'Suchmethode' -Value 'Gezielte Suche in typischen Log-Verzeichnissen'

    $logs = New-Object System.Collections.Generic.List[string]
    $existingRoots = New-Object System.Collections.Generic.List[string]

    foreach ($root in $LogRoots) {
        if (-not (Test-RemoteDirectory $root)) { continue }
        if (-not $existingRoots.Contains($root)) {
            [void]$existingRoots.Add($root)
        }
    }

    if ($existingRoots.Count -eq 0) {
        Write-Diag -Text 'Keiner der bekannten Mod-/RetroArch-Pfade wurde gefunden.' -Kind Info
        return
    }

    $index = 0
    foreach ($root in $existingRoots) {
        $index++
        Write-Host ("  Suche [{0}/{1}] {2}" -f $index, $existingRoots.Count, $root) -ForegroundColor DarkGray

        $quoted = ConvertTo-RemoteQuotedPath $root
        $command = @(
            'for f in',
            ("{0}/*.log" -f $quoted),
            ("{0}/*log.txt" -f $quoted),
            ("{0}/log/*.log" -f $quoted),
            ("{0}/log/*log.txt" -f $quoted),
            ("{0}/logs/*.log" -f $quoted),
            ("{0}/logs/*log.txt" -f $quoted),
            ("{0}/config/*.log" -f $quoted),
            ("{0}/config/*log.txt" -f $quoted),
            ("{0}/retroarch/*.log" -f $quoted),
            ("{0}/retroarch/*log.txt" -f $quoted),
            ("{0}/retroarch/logs/*.log" -f $quoted),
            ("{0}/retroarch/logs/*log.txt" -f $quoted),
            '; do [ -f "$f" ] && printf "%s\\n" "$f"; done'
        ) -join ' '

        $result = Invoke-PSXCommand -Command $command -AllowFailure
        if ($result.ExitCode -ne 0) {
            Write-Diag -Text ("Logsuche in {0} konnte nicht vollstaendig ausgefuehrt werden." -f $root) -Kind Warning
            continue
        }

        foreach ($file in $result.Output) {
            if ([string]::IsNullOrWhiteSpace($file)) { continue }
            if (-not $logs.Contains($file)) { [void]$logs.Add($file) }
        }
    }

    Write-Host ''
    if ($logs.Count -eq 0) {
        Write-Diag -Text 'Keine typischen Logdateien innerhalb der begrenzten Suchtiefe gefunden.' -Kind Info
    }
    else {
        Write-Diag -Text ("Gefundene Logdateien: {0}" -f $logs.Count) -Kind OK
        $logs | Sort-Object | ForEach-Object { Write-Diag -Text ("- {0}" -f $_) -Kind Info }
    }
}

function Invoke-FullDiagnostic {
    Invoke-SystemCheck
    Invoke-ModCheck
    Invoke-RetroArchCheck
    Invoke-ControllerCheck
    Invoke-GameCheck
    Invoke-LogCheck
    Write-Diag -Text 'DIAGNOSE-ZUSAMMENFASSUNG' -Kind Section
    Write-Diag -Text 'Diagnoselauf abgeschlossen. Das Toolkit hat keine Konfigurationsdateien veraendert.' -Kind OK
}

function Invoke-CheckAndSave {
    param(
        [Parameter(Mandatory)]
        [ValidateSet('full', 'system', 'mods', 'retroarch', 'controllers', 'games', 'logs')]
        [string]$Mode,

        [Parameter(Mandatory)]
        [string]$Label
    )

    Reset-RunStats

    if (-not (Test-PSXConnection)) {
        Write-Host ''
        Write-Host '[ERROR] Pruefung abgebrochen: keine SSH-Verbindung.' -ForegroundColor Red
        return
    }

    if (-not (Test-Path -LiteralPath $ReportDir)) {
        New-Item -Path $ReportDir -ItemType Directory -Force | Out-Null
    }

    $timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
    if ($Mode -eq 'full') {
        $reportFile = Join-Path $ReportDir ("psx_diagnostics_{0}.txt" -f $timestamp)
    }
    else {
        $reportFile = Join-Path $ReportDir ("psx_{0}_{1}.txt" -f $Mode, $timestamp)
    }

    $script:CurrentReport = $reportFile
    $header = @(
        ("{0} v{1}" -f $ToolName, $Version),
        $Vendor,
        ("Target: {0}" -f $Target),
        ("Host timestamp: {0}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss K')),
        ("Requested check: {0}" -f $Label),
        'Remote strategy: individual SSH commands / local PowerShell parsing',
        ''
    )
    $header | Set-Content -LiteralPath $reportFile -Encoding UTF8

    Write-Host ''
    Write-Host ('=' * 68) -ForegroundColor DarkGray
    Write-Host '  PRUEFAUFTRAG' -ForegroundColor Cyan
    Write-Host ('=' * 68) -ForegroundColor DarkGray
    Write-KeyValue -Label 'Pruefung' -Value $Label
    Write-KeyValue -Label 'Zielsystem' -Value $Target
    Write-KeyValue -Label 'PC-Zeit' -Value (Get-Date -Format 'yyyy-MM-dd HH:mm:ss K')
    Write-KeyValue -Label 'Report' -Value $reportFile

    try {
        switch ($Mode) {
            'system'      { Invoke-SystemCheck }
            'mods'        { Invoke-ModCheck }
            'retroarch'   { Invoke-RetroArchCheck }
            'controllers' { Invoke-ControllerCheck }
            'games'       { Invoke-GameCheck }
            'logs'        { Invoke-LogCheck }
            'full'        { Invoke-FullDiagnostic }
        }
        Write-RunSummary -ReportFile $reportFile
    }
    catch {
        $message = $_.Exception.Message
        Write-Diag -Text $message -Kind Error
        Write-RunSummary -ReportFile $reportFile
    }
    finally {
        $script:CurrentReport = $null
    }
}

function Pause-Toolkit {
    Write-Host ''
    Write-Host '  [ENTER] Zurueck zum Hauptmenue' -ForegroundColor Cyan
    Write-Host ''

    [void](Read-Host)
    Write-Host '  Rueckkehr zum Hauptmenue ...' -ForegroundColor DarkGray
}


function Show-Menu {
    while ($true) {
        Write-Banner
        Write-Host ''
        Write-Host '  DIAGNOSE' -ForegroundColor Cyan
        Write-Host '  --------'
        Write-Host '  1) Vollstaendige Diagnose'
        Write-Host '  2) System und Speicher'
        Write-Host '  3) Mod-Umgebung erkennen'
        Write-Host '  4) RetroArch und BIOS'
        Write-Host '  5) Controller-Konfigurationen'
        Write-Host '  6) PlayStation BIN/CUE-Bibliothek'
        Write-Host '  7) Logdateien'
        Write-Host ''
        Write-Host '  VERBINDUNG' -ForegroundColor Cyan
        Write-Host '  ----------'
        Write-Host '  8) SSH-Verbindung testen'
        Write-Host ''
        Write-Host '  0) Beenden'
        Write-Host ''

        $choice = Read-Host 'Auswahl'
        switch ($choice) {
            '1' { Invoke-CheckAndSave -Mode 'full' -Label 'Vollstaendige Diagnose'; Pause-Toolkit; continue }
            '2' { Invoke-CheckAndSave -Mode 'system' -Label 'System und Speicher'; Pause-Toolkit; continue }
            '3' { Invoke-CheckAndSave -Mode 'mods' -Label 'Mod-Umgebung erkennen'; Pause-Toolkit; continue }
            '4' { Invoke-CheckAndSave -Mode 'retroarch' -Label 'RetroArch und BIOS'; Pause-Toolkit; continue }
            '5' { Invoke-CheckAndSave -Mode 'controllers' -Label 'Controller-Konfigurationen'; Pause-Toolkit; continue }
            '6' { Invoke-CheckAndSave -Mode 'games' -Label 'PlayStation BIN/CUE-Bibliothek'; Pause-Toolkit; continue }
            '7' { Invoke-CheckAndSave -Mode 'logs' -Label 'Logdateien'; Pause-Toolkit; continue }
            '8' { [void](Test-PSXConnection); Pause-Toolkit; continue }
            '0' { return }
            default { Write-Host 'Ungueltige Auswahl.' -ForegroundColor Yellow; Pause-Toolkit; continue }
        }
    }
}

if (-not (Test-HostRequirements)) { exit 1 }

Write-Banner

if ($Test) {
    if (Test-PSXConnection) { exit 0 } else { exit 1 }
}

if ($Full) {
    Invoke-CheckAndSave -Mode 'full' -Label 'Vollstaendige Diagnose'
    exit 0
}

Show-Menu