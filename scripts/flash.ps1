# Flash zephyr.bin to COM port
# .\scripts\flash.ps1 -Port COM5 [-BuildDir build-esp32s3_devkitm-esp32s3-procpu]

param(
    [string]$Port = "COM5",
    [string]$BuildDir = "",
    [string]$Repo = ""
)

$ErrorActionPreference = "Stop"
if (-not $Repo) { $Repo = Resolve-Path (Join-Path $PSScriptRoot "..") }
if (-not $BuildDir) {
    $bin = Get-ChildItem -Path $Repo -Filter "zephyr.bin" -Recurse -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending | Select-Object -First 1
} else {
    $bin = Get-Item (Join-Path $BuildDir "zephyr\zephyr.bin")
}
if (-not $bin) { throw "zephyr.bin not found" }

$env:PYTHONIOENCODING = "utf-8"
Set-Location $Repo
& pio pkg exec -p tool-esptoolpy -- esptool.py -p $Port -b 921600 --after hard-reset write-flash 0x0 $bin.FullName
Write-Host "Flashed $($bin.FullName)"
