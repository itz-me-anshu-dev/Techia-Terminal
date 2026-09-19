<#
.SYNOPSIS
  One-command Techia installer for Windows (per-user, no admin needed).

.DESCRIPTION
  Downloads techia.exe + SHA256SUMS from a release base URL, verifies the
  checksum BEFORE running anything, then runs the exe's own `install`
  command (copies to %LOCALAPPDATA%\Techia\bin, adds user PATH, writes the
  install manifest). Nothing executes unverified.

.USAGE (PowerShell, normal users copy-paste one line):
  irm https://github.com/anshu20120000-pixel/techia-app/releases/download/v1.0.0/install.ps1 | iex

.USAGE (CMD):
  powershell -NoProfile -Command "irm https://github.com/anshu20120000-pixel/techia-app/releases/download/v1.0.0/install.ps1 | iex"

  Replace OWNER/REPO/v0.1.0 with the real release when publishing (see
  Techia Backend\deploy\RENDER.md or the release checklist). Parameters
  below allow installing from any base (including a local test folder).
#>
param(
    [string]$ReleaseBase = "https://github.com/anshu20120000-pixel/techia-app/releases/download/v1.0.0",
    [string]$FileName = "techia.exe"
)

$ErrorActionPreference = "Stop"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

if ($ReleaseBase -like "*OWNER/REPO*") {
    Write-Host "Techia installer: no release URL configured."
    Write-Host "Publish a release first (techia.exe + SHA256SUMS), then run:"
    Write-Host '  install.ps1 -ReleaseBase "https://github.com/OWNER/REPO/releases/download/vX.Y.Z"'
    exit 2
}

$tmp = Join-Path $env:TEMP ("techia-install-" + [Guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Path $tmp | Out-Null
try {
    Write-Host "[1/3] Downloading $FileName ..."
    $exePath = Join-Path $tmp $FileName
    $sumsPath = Join-Path $tmp "SHA256SUMS"
    Invoke-WebRequest -Uri "$ReleaseBase/$FileName" -OutFile $exePath -TimeoutSec 300
    Invoke-WebRequest -Uri "$ReleaseBase/SHA256SUMS" -OutFile $sumsPath -TimeoutSec 60

    Write-Host "[2/3] Verifying checksum ..."
    $actual = (Get-FileHash -LiteralPath $exePath -Algorithm SHA256).Hash.ToLower()
    $expected = $null
    foreach ($line in (Get-Content -LiteralPath $sumsPath)) {
        $parts = $line -split '\s+', 2
        if ($parts.Count -eq 2 -and $parts[1].Trim() -eq $FileName) { $expected = $parts[0].Trim().ToLower() }
    }
    if (-not $expected) { throw "SHA256SUMS has no entry for $FileName - refusing to install." }
    if ($actual -ne $expected) { throw "Checksum mismatch for $FileName - refusing to install." }
    Write-Host "        checksum ok."

    Write-Host "[3/3] Installing (per-user, no admin) ..."
    & $exePath install
    if ($LASTEXITCODE -ne 0) { throw "techia install failed (exit $LASTEXITCODE)." }

    Write-Host ""
    Write-Host "Done. IMPORTANT: close this terminal, open a new one, then run:"
    Write-Host "  techia doctor"
} finally {
    Remove-Item -Recurse -Force $tmp -ErrorAction SilentlyContinue
}



