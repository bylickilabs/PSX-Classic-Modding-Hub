param(
    [string]$PSClassicIP = "DEINE-PSx-CLASSIC-IP-HIER-EINTRAGEN",
    [string]$User = "root",
    [int]$TimeoutSeconds = 90,
    [string]$OutputDirectory = "$env:USERPROFILE\Desktop\PSX_Screenshots",
    [switch]$NoOpen
)

$ErrorActionPreference = "Stop"

$RemoteDirectory = "/media/bleemsync/screenshots"
$RemoteFile      = "$RemoteDirectory/wayland-screenshot.png"
$RemoteLink      = "/wayland-screenshot.png"
$RemoteHelper    = "/media/bleemsync/bin/psx_screenshot_trigger"
$RemoteLog       = "$RemoteDirectory/trigger.log"


$HelperBase64 = @'
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
'@

function Write-Step {
    param(
        [string]$Text,
        [ConsoleColor]$ForegroundColor = "Cyan"
    )

    Write-Host ""
    Write-Host "==> $Text" -ForegroundColor $ForegroundColor
}

function Require-Command {
    param([string]$Name)

    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "$Name wurde unter Windows nicht gefunden. Der Windows OpenSSH Client wird benoetigt."
    }
}

function Invoke-RemoteScript {
    param(
        [string]$Script,
        [switch]$IgnoreExitCode
    )

    $normalized = $Script -replace "`r", ""
    $normalized | & ssh -o ConnectTimeout=7 -o ServerAliveInterval=3 -o ServerAliveCountMax=2 "$User@$PSClassicIP" "sh -s"
    $code = $LASTEXITCODE

    if (-not $IgnoreExitCode -and $code -ne 0) {
        throw "SSH-Befehl fehlgeschlagen (Exit-Code $code)."
    }

    return $code
}
    Write-Host "" 
    Write-Host "====================================================" -ForegroundColor DarkYellow
Write-Host ""
Write-Host "    PS CLASSIC // AUTOMATIC WESTON SCREENSHOT V2" -ForegroundColor DarkYellow
Write-Host ""
Write-Host "              POWERED BY BYLICKILABS" -ForegroundColor Red
Write-Host ""
    Write-Host "====================================================" -ForegroundColor DarkYellow
Write-Host ""
Write-Host ""
Write-Host "Ziel: $User@$PSClassicIP"
Write-Host "Ausgabe: $OutputDirectory"

Require-Command "ssh"
Require-Command "scp"

Write-Host ""
Write-Host ""
    Write-Host "====================================================" -ForegroundColor DarkYellow
Write-Host ""
Write-Host "     	   Bereite Screenshot-Helfer vor" -ForegroundColor Red
Write-Host ""
    Write-Host "====================================================" -ForegroundColor DarkYellow
Write-Host ""
Write-Host ""

$tempHelper = Join-Path ([System.IO.Path]::GetTempPath()) "psx_screenshot_trigger_armv7"

try {
    $bytes = [Convert]::FromBase64String(($HelperBase64 -replace "\s", ""))
    [System.IO.File]::WriteAllBytes($tempHelper, $bytes)

    $hash = (Get-FileHash -Algorithm SHA256 -Path $tempHelper).Hash.ToLowerInvariant()
    if ($hash -ne "3b7445e107ebb7e2e5c13528bc78bac7578f43299b72a1d6d091b68ac6707f34") {
        throw "Die Pruefsumme des eingebetteten ARM-Helfers stimmt nicht."
    }
Write-Host ""
    Write-Host "ARM-Helfer V2 bereit (stabilisierter SUPER+S-Trigger)." -ForegroundColor DarkYellow
Write-Host ""
    Write-Step "Uebertrage Helfer zur PS Classic" -ForegroundColor Red
Write-Host ""
    & scp -q -o ConnectTimeout=7 $tempHelper "${User}@${PSClassicIP}:$RemoteHelper"
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Der ARM-Helfer konnte nicht zur PS Classic kopiert werden." -ForegroundColor Red
        throw "Der ARM-Helfer konnte nicht zur PS Classic kopiert werden."
    }

    Write-Step "Pruefe Weston und Screenshotpfad" -ForegroundColor White

    $setupScript = @'
REMOTE_DIR="__REMOTE_DIR__"
REMOTE_FILE="__REMOTE_FILE__"
REMOTE_LINK="__REMOTE_LINK__"
REMOTE_HELPER="__REMOTE_HELPER__"
REMOTE_LOG="__REMOTE_LOG__"

if [ ! -c /dev/uinput ]; then
    echo "ERROR: /dev/uinput ist nicht vorhanden."
    exit 20
fi

if [ ! -x /usr/libexec/weston-screenshooter ]; then
    echo "ERROR: /usr/libexec/weston-screenshooter fehlt."
    exit 21
fi

if ! pidof weston >/dev/null 2>&1; then
    echo "ERROR: Weston laeuft nicht."
    exit 22
fi

mkdir -p "$REMOTE_DIR" || exit 23
chmod 755 "$REMOTE_HELPER" || exit 24

expected="$REMOTE_FILE"
target="$(readlink "$REMOTE_LINK" 2>/dev/null || true)"
remounted=0

restore_root_ro() {
    if [ "$remounted" = "1" ]; then
        sync
        mount -o remount,ro / >/dev/null 2>&1 || true
    fi
}

trap restore_root_ro EXIT HUP INT TERM

if [ "$target" != "$expected" ]; then
    echo "Symlink wird vorbereitet..."
    mount -o remount,rw / || exit 25
    remounted=1

    rm -f "$REMOTE_LINK" || exit 26
    ln -s "$expected" "$REMOTE_LINK" || exit 27
    sync

    mount -o remount,ro / || exit 28
    remounted=0
fi

rm -f "$REMOTE_FILE"
rm -f "$REMOTE_LOG"

if [ "$(readlink "$REMOTE_LINK" 2>/dev/null)" != "$expected" ]; then
    echo "ERROR: Screenshot-Symlink ist nicht korrekt."
    exit 29
fi

echo "READY"
'@

    $setupScript = $setupScript.
        Replace("__REMOTE_DIR__", $RemoteDirectory).
        Replace("__REMOTE_FILE__", $RemoteFile).
        Replace("__REMOTE_LINK__", $RemoteLink).
        Replace("__REMOTE_HELPER__", $RemoteHelper).
        Replace("__REMOTE_LOG__", $RemoteLog)

    Invoke-RemoteScript -Script $setupScript | Out-Null

    Write-Host "Weston und Screenshotpfad sind bereit." -ForegroundColor Green

    Write-Step "Loese Screenshot automatisch aus"

    $triggerScript = @'
REMOTE_HELPER="__REMOTE_HELPER__"
REMOTE_LOG="__REMOTE_LOG__"

"$REMOTE_HELPER" >"$REMOTE_LOG" 2>&1
code=$?
cat "$REMOTE_LOG" 2>/dev/null || true
exit $code
'@

    $triggerScript = $triggerScript.
        Replace("__REMOTE_HELPER__", $RemoteHelper).
        Replace("__REMOTE_LOG__", $RemoteLog)

    $triggerCode = Invoke-RemoteScript -Script $triggerScript -IgnoreExitCode

    if ($triggerCode -eq 0) {
        Write-Host "SUPER+S wurde an Weston gesendet." -ForegroundColor Green
    }
    else {
        Write-Host "Die Trigger-SSH-Verbindung meldete Exit-Code $triggerCode." -ForegroundColor Yellow
        Write-Host "Das Skript prueft trotzdem, ob der Screenshot erzeugt wurde." -ForegroundColor Yellow
    }

    Write-Step "Warte auf Screenshot und uebertrage ihn"

    New-Item -ItemType Directory -Force -Path $OutputDirectory | Out-Null

    $timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
    $OutputFile = Join-Path $OutputDirectory "PSX_Homescreen_$timestamp.png"
    $remoteSource = "${User}@${PSClassicIP}:$RemoteFile"

    $deadline = (Get-Date).AddSeconds($TimeoutSeconds)
    $copied = $false

    while ((Get-Date) -lt $deadline) {
        & scp -q -o ConnectTimeout=5 $remoteSource $OutputFile 2>$null

        if ($LASTEXITCODE -eq 0 -and (Test-Path $OutputFile)) {
            $file = Get-Item $OutputFile
            if ($file.Length -gt 0) {
                $copied = $true
                break
            }
        }

        if (Test-Path $OutputFile) {
            Remove-Item -Force $OutputFile -ErrorAction SilentlyContinue
        }

        Write-Host "." -NoNewline
        Start-Sleep -Seconds 2
    }

    Write-Host ""

    if (-not $copied) {
        Write-Host "Kein Screenshot innerhalb von $TimeoutSeconds Sekunden empfangen." -ForegroundColor Red
        Write-Host ""
        Write-Host "Remote-Trigger-Log:" -ForegroundColor Yellow

        $logScript = @'
cat "__REMOTE_LOG__" 2>/dev/null || echo "Kein trigger.log vorhanden."
'@
        $logScript = $logScript.Replace("__REMOTE_LOG__", $RemoteLog)
        Invoke-RemoteScript -Script $logScript -IgnoreExitCode | Out-Host

        throw "Der automatische Screenshot konnte nicht abgeschlossen werden."
    }

    $file = Get-Item $OutputFile
	Write-Host ""
    Write-Host ""
    Write-Host "====================================================" 	-ForegroundColor DarkYellow
    Write-Host ""
    Write-Host "     	            ERFOLGREICH" -ForegroundColor Red
    Write-Host ""
    Write-Host "====================================================" -ForegroundColor DarkYellow
    Write-Host ""
    Write-Host "Screenshot: $OutputFile"
    Write-Host ("Dateigroesse: {0:N0} KB" -f ($file.Length / 1KB))
	Write-Host ""

    if (-not $NoOpen) {
        Start-Process $OutputFile
    }
}
finally {
    if (Test-Path $tempHelper) {
        Remove-Item -Force $tempHelper -ErrorAction SilentlyContinue
    }
}