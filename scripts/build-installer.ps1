# Builds target/installer/release/winime_en.exe and dist/winime_en-Setup-[-<channel>-]<version>.exe
param(
    [string]$Version,
    [string]$Channel = ""
)

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

function Get-PackageVersion {
    $toml = Get-Content -Raw (Join-Path $root "Cargo.toml")
    if ($toml -match '(?m)^version\s*=\s*"([^"]+)"') {
        return $Matches[1]
    }
    throw "Could not read package version from Cargo.toml"
}

function Find-ISCC {
    $candidates = @(
        "${env:LOCALAPPDATA}\Programs\Inno Setup 6\ISCC.exe",
        "${env:ProgramFiles(x86)}\Inno Setup 6\ISCC.exe",
        "${env:ProgramFiles}\Inno Setup 6\ISCC.exe"
    )
    foreach ($path in $candidates) {
        if (Test-Path $path) {
            return $path
        }
    }
    $cmd = Get-Command ISCC.exe -ErrorAction SilentlyContinue
    if ($cmd) {
        return $cmd.Source
    }
    return $null
}

if (-not $Version) {
    $Version = Get-PackageVersion
}

Write-Host "Building winime_en $Version with the C runtime linked statically..."
$previousRustFlags = $env:RUSTFLAGS
try {
    $env:RUSTFLAGS = @($previousRustFlags, '-C target-feature=+crt-static') -join ' '
    cargo build --release --locked --target-dir target/installer
    if ($LASTEXITCODE -ne 0) {
        throw "cargo build failed"
    }
}
finally {
    $env:RUSTFLAGS = $previousRustFlags
}

$exe = Join-Path $root "target\installer\release\winime_en.exe"
if (-not (Test-Path $exe)) {
    throw "missing $exe"
}

$iscc = Find-ISCC
if (-not $iscc) {
    throw "Inno Setup compiler not found. Install with: winget install JRSoftware.InnoSetup"
}

$dist = Join-Path $root "dist"
New-Item -ItemType Directory -Force -Path $dist | Out-Null

Write-Host "Compiling installer with $iscc ..."
$isccArgs = @((Join-Path $root "installer\winime_en.iss"), "/DMyAppVersion=$Version")
if ($Channel) {
    $isccArgs += "/DMyAppChannel=$Channel"
}
& $iscc @isccArgs
if ($LASTEXITCODE -ne 0) {
    throw "ISCC failed"
}

$channelSuffix = if ($Channel) { "-$Channel" } else { "" }
$setup = Join-Path $dist "winime_en-Setup$channelSuffix-$Version.exe"
if (-not (Test-Path $setup)) {
    throw "installer output missing: $setup"
}

Write-Host "Installer: $setup"
Get-Item $setup | Select-Object FullName, Length, LastWriteTime
