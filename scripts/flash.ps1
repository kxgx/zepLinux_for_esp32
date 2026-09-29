# Flash zephyr.bin to any ESP32-family board.
# Usage:
#   .\scripts\flash.ps1 -Port COM5
#   .\scripts\flash.ps1 -Port /dev/ttyUSB0 -BuildDir build-esp32s3_devkitm-esp32s3-procpu

param(
    [string]$Port = "",
    [string]$BuildDir = "",
    [string]$Baud = "921600"
)

$ErrorActionPreference = "Stop"
$repo = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path

if (-not $Port) {
    # auto-pick a serial port
    if ($IsWindows -or $env:OS -eq "Windows_NT") {
        $Port = [System.IO.Ports.SerialPort]::GetPortNames() | Select-Object -First 1
    } else {
        $Port = "/dev/ttyUSB0"
    }
}
if (-not $Port) { throw "No serial port found. Pass -Port." }

$bin = $null
if ($BuildDir) {
    $bin = Join-Path $BuildDir "zephyr\zephyr.bin"
    if (-not (Test-Path $bin)) { $bin = Join-Path $BuildDir "zephyr/zephyr.bin" }
} else {
    $bin = Get-ChildItem -Path $repo -Filter "zephyr.bin" -Recurse -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending | Select-Object -First 1 -ExpandProperty FullName
}
if (-not $bin -or -not (Test-Path $bin)) { throw "zephyr.bin not found" }

Write-Host "Port=$Port  Baud=$Baud  Image=$bin"

# esptool via pio if available, else esptool.py / esptool
$env:PYTHONIOENCODING = "utf-8"
Set-Location $repo

$esptoolArgs = @("-p", $Port, "-b", $Baud, "--after", "hard-reset", "write-flash", "0x0", $bin)

if (Get-Command pio -ErrorAction SilentlyContinue) {
    & pio pkg exec -p tool-esptoolpy -- esptool.py @esptoolArgs
} elseif (Get-Command esptool.py -ErrorAction SilentlyContinue) {
    & esptool.py @esptoolArgs
} elseif (Get-Command esptool -ErrorAction SilentlyContinue) {
    & esptool @esptoolArgs
} else {
    throw "esptool not found (pio / esptool.py)"
}

Write-Host "Flashed $bin"
