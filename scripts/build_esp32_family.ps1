# Build zepLinux for an ESP32-family board
# Examples:
#   .\scripts\build_esp32_family.ps1 -Board esp32s3_devkitm/esp32s3/procpu
#   .\scripts\build_esp32_family.ps1 -Board esp32_devkitc/esp32/procpu
#   .\scripts\build_esp32_family.ps1 -Board esp32c3_devkitc/esp32c3/cpuapp

param(
    [Parameter(Mandatory = $true)][string]$Board,
    [string]$Sample = "zephyr/samples/ansilic/esp32s3_zeplinux_tests",
    [string]$BuildDir = "",
    [string]$Toolchain = "C:\Users\26959\zephyr-esp-tc",
    [string]$Overlay = ""
)

$ErrorActionPreference = "Stop"
$repo = Resolve-Path (Join-Path $PSScriptRoot "..")
if (-not $BuildDir) {
    $BuildDir = Join-Path $repo "build-$($Board -replace '[/\\]','-')"
}

$env:ZEPHYR_TOOLCHAIN_VARIANT = "espressif"
$env:ESPRESSIF_TOOLCHAIN_PATH = $Toolchain
$env:PATH = "C:\Users\26959\AppData\Local\Programs\Python\Python314\Scripts;$env:PATH"

$extra = @()
if ($Overlay -and (Test-Path $Overlay)) {
    $extra += "--"
    $extra += "-DDTC_OVERLAY_FILE=$Overlay"
    $extra += "-DKCONFIG_WARNINGS_AS_ERRORS=n"
}

Write-Host "Board=$Board Sample=$Sample Build=$BuildDir"
Set-Location $repo
& west build -p always -b $Board -d $BuildDir $Sample @extra
Write-Host "Done. Image: $BuildDir\zephyr\zephyr.bin"
