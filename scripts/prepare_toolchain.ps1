# Prepare Zephyr ESPRESSIF toolchain tree for the whole ESP32 family
# Usage: .\scripts\prepare_toolchain.ps1 [-Root C:\Users\you\.platformio\packages]

param(
    [string]$Root = "C:\Users\26959\.platformio\packages",
    [string]$Dest = "C:\Users\26959\zephyr-esp-tc"
)

$ErrorActionPreference = "Stop"

function Link-Dir([string]$src, [string]$dst) {
    if (-not (Test-Path $src)) {
        Write-Host "  skip (missing): $src"
        return
    }
    if (Test-Path $dst) { return }
    New-Item -ItemType Junction -Path $dst -Target $src | Out-Null
    Write-Host "  link $dst -> $src"
}

# Xtensa unified toolchain (ESP32 / S2 / S3)
$xt = Join-Path $Root "toolchain-xtensa-esp-elf"
foreach ($name in @("xtensa-esp32-elf", "xtensa-esp32s2-elf", "xtensa-esp32s3-elf", "xtensa-esp-elf")) {
    $base = Join-Path $Dest $name
    New-Item -ItemType Directory -Force -Path $base | Out-Null
    Link-Dir (Join-Path $xt "bin") (Join-Path $base "bin")
    Link-Dir (Join-Path $xt "libexec") (Join-Path $base "libexec")
    Link-Dir (Join-Path $xt "lib") (Join-Path $base "lib")
    Link-Dir (Join-Path $xt "include") (Join-Path $base "include")
    Link-Dir (Join-Path $xt "share") (Join-Path $base "share")
    Link-Dir (Join-Path $xt "xtensa-esp-elf") (Join-Path $base "xtensa-esp-elf")
    Link-Dir (Join-Path $xt "xtensa-esp-elf") (Join-Path $base "xtensa-esp32s3-elf")
}

# RISC-V toolchain (C3 / C6 / H2)
$rvRoots = @(
    (Join-Path $Root "toolchain-riscv32-esp"),
    (Join-Path $Root "toolchain-riscv32-esp@12.2.0+20230208")
) | Where-Object { Test-Path $_ } | Select-Object -First 1

if ($rvRoots) {
    foreach ($name in @("riscv32-esp-elf", "riscv32-esp32-elf", "riscv32-esp32c3-elf")) {
        $base = Join-Path $Dest $name
        New-Item -ItemType Directory -Force -Path $base | Out-Null
        Link-Dir (Join-Path $rvRoots "bin") (Join-Path $base "bin")
        Link-Dir (Join-Path $rvRoots "libexec") (Join-Path $base "libexec")
        Link-Dir (Join-Path $rvRoots "lib") (Join-Path $base "lib")
        Link-Dir (Join-Path $rvRoots "include") (Join-Path $base "include")
        Link-Dir (Join-Path $rvRoots "riscv32-esp-elf") (Join-Path $base "riscv32-esp-elf")
    }
} else {
    Write-Host "WARN: riscv toolchain not found — C3/C6/H2 builds need toolchain-riscv32-esp"
}

Write-Host "Toolchain tree ready: $Dest"
Get-ChildItem $Dest | Select-Object Name
