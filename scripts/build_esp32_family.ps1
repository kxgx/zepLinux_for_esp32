# Build zepLinux for any ESP32-family board (generic).
#
# Examples:
#   .\scripts\build_esp32_family.ps1 -Board esp32s3_devkitm/esp32s3/procpu
#   .\scripts\build_esp32_family.ps1 -Board esp32_devkitc
#   .\scripts\build_esp32_family.ps1 -Board esp32c3_devkitc
#   .\scripts\build_esp32_family.ps1 -Board esp32s2_devkitc -Sample zephyr/samples/ansilic/esp32s3_zeplinux_tests

param(
    [Parameter(Mandatory = $true)][string]$Board,
    [string]$Sample = "zephyr/samples/ansilic/esp32s3_zeplinux_tests",
    [string]$BuildDir = "",
    [string]$Toolchain = "",
    [string]$Overlay = "",
    [switch]$Flash,
    [string]$Port = "COM5"
)

$ErrorActionPreference = "Stop"

# repo root = parent of scripts/
$repo = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path

# toolchain default: sibling prepare_toolchain.ps1 output
if (-not $Toolchain) {
    $Toolchain = Join-Path $env:USERPROFILE "zephyr-esp-tc"
    if (-not $env:USERPROFILE) { $Toolchain = Join-Path $HOME "zephyr-esp-tc" }
}
if (-not (Test-Path $Toolchain)) {
    Write-Host "Toolchain not found at $Toolchain — running prepare_toolchain.ps1..."
    & (Join-Path $PSScriptRoot "prepare_toolchain.ps1")
}

if (-not $BuildDir) {
    $tag = ($Board -replace '[/\\:]', '-')
    $BuildDir = Join-Path $repo "build-$tag"
}

$env:ZEPHYR_TOOLCHAIN_VARIANT = "espressif"
$env:ESPRESSIF_TOOLCHAIN_PATH = $Toolchain

# python/west on PATH if missing
foreach ($p in @(
    (Join-Path $env:USERPROFILE "AppData\Local\Programs\Python\Python314\Scripts"),
    (Join-Path $env:USERPROFILE ".platformio\penv\Scripts"),
    (Join-Path $HOME ".local/bin")
)) {
    if ((Test-Path $p) -and ($env:PATH -notlike "*$p*")) {
        $env:PATH = "$p;$env:PATH"
    }
}

$cmakeArgs = @("-DKCONFIG_WARNINGS_AS_ERRORS=n")
if ($Overlay) {
    if (-not [System.IO.Path]::IsPathRooted($Overlay)) {
        $Overlay = Join-Path $repo $Overlay
    }
    if (-not (Test-Path $Overlay)) { throw "Overlay not found: $Overlay" }
    $cmakeArgs = @("-DDTC_OVERLAY_FILE=$Overlay", "-DKCONFIG_WARNINGS_AS_ERRORS=n")
}

Write-Host "=== zepLinux ESP32 family build ==="
Write-Host "Board    : $Board"
Write-Host "Sample   : $Sample"
Write-Host "Build    : $BuildDir"
Write-Host "Toolchain: $Toolchain"
if ($Overlay) { Write-Host "Overlay  : $Overlay" }

Set-Location $repo
& west build -p always -b $Board -d $BuildDir $Sample -- @cmakeArgs
if ($LASTEXITCODE -ne 0) { throw "build failed" }

$bin = Join-Path $BuildDir "zephyr\zephyr.bin"
Write-Host ""
Write-Host "Image: $bin"

if ($Flash) {
    & (Join-Path $PSScriptRoot "flash.ps1") -Port $Port -BuildDir $BuildDir
}
