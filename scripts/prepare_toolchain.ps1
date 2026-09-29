# Prepare Espressif toolchain tree for Zephyr (whole ESP32 family).
# Usage: .\scripts\prepare_toolchain.ps1 [-Root <platformio packages>] [-Dest <dir>]

param(
    [string]$Root = "",
    [string]$Dest = "",
    [switch]$Force
)

$ErrorActionPreference = "Stop"

if (-not $Root) {
    $candidates = @(
        (Join-Path $env:USERPROFILE ".platformio\packages"),
        (Join-Path $HOME ".platformio/packages")
    ) | Where-Object { $_ -and (Test-Path $_) }
    foreach ($c in $candidates) {
        if ((Test-Path (Join-Path $c "toolchain-xtensa-esp-elf")) -or
            (Test-Path (Join-Path $c "toolchain-riscv32-esp"))) {
            $Root = $c
            break
        }
    }
}
if (-not $Root) { throw "PlatformIO toolchains not found. Pass -Root or install PlatformIO packages." }

if (-not $Dest) {
    $Dest = Join-Path $env:USERPROFILE "zephyr-esp-tc"
    if (-not $env:USERPROFILE) { $Dest = Join-Path $HOME "zephyr-esp-tc" }
}

Write-Host "Root=$Root"
Write-Host "Dest=$Dest"

if ($Force -and (Test-Path $Dest)) {
    Get-ChildItem $Dest | ForEach-Object {
        if ($_.LinkType) { $_.Delete() } else { Remove-Item $_.FullName -Recurse -Force }
    }
}

function Link-Dir([string]$src, [string]$dst) {
    if (-not (Test-Path $src)) { return $false }
    if (Test-Path $dst) { return $true }
    try {
        New-Item -ItemType Junction -Path $dst -Target $src | Out-Null
    } catch {
        New-Item -ItemType SymbolicLink -Path $dst -Target $src -ErrorAction Stop | Out-Null
    }
    return $true
}

function Setup-Triple([string]$pkg, [string]$triple, [string[]]$sysroots) {
    if (-not (Test-Path $pkg)) {
        $hit = Get-ChildItem $Root -Directory -Filter (Split-Path $pkg -Leaf) -ErrorAction SilentlyContinue |
            Select-Object -First 1 -ExpandProperty FullName
        if ($hit) { $pkg = $hit }
    }
    if (-not (Test-Path $pkg)) {
        Write-Host "WARN: skip $triple (package missing)"
        return
    }
    $gcc = Join-Path $pkg "bin\$triple-gcc.exe"
    if (-not (Test-Path $gcc)) {
        $gcc = Join-Path $pkg "bin\$triple-gcc"
    }
    if (-not (Test-Path $gcc)) {
        Write-Host "WARN: skip $triple (no $triple-gcc in $pkg)"
        return
    }

    $base = Join-Path $Dest $triple
    New-Item -ItemType Directory -Force -Path $base | Out-Null
    Link-Dir (Join-Path $pkg "bin") (Join-Path $base "bin") | Out-Null
    Link-Dir (Join-Path $pkg "libexec") (Join-Path $base "libexec") | Out-Null
    Link-Dir (Join-Path $pkg "lib") (Join-Path $base "lib") | Out-Null
    Link-Dir (Join-Path $pkg "include") (Join-Path $base "include") | Out-Null
    Link-Dir (Join-Path $pkg "share") (Join-Path $base "share") | Out-Null

    # Nested sysroot name must end with -elf (Zephyr glob: *-esp*/*-elf)
    foreach ($sr in $sysroots) {
        $src = Join-Path $pkg $sr
        if (Test-Path $src) {
            Link-Dir $src (Join-Path $base $sr) | Out-Null
        }
    }
    Write-Host "OK  $triple"
}

$xtensa = Join-Path $Root "toolchain-xtensa-esp-elf"
$riscv  = Join-Path $Root "toolchain-riscv32-esp"

# Xtensa: ESP32 / S2 / S3
Setup-Triple $xtensa "xtensa-esp-elf"     @("xtensa-esp-elf")
Setup-Triple $xtensa "xtensa-esp32-elf"   @("xtensa-esp32-elf", "xtensa-esp-elf")
Setup-Triple $xtensa "xtensa-esp32s2-elf" @("xtensa-esp32s2-elf", "xtensa-esp-elf")
Setup-Triple $xtensa "xtensa-esp32s3-elf" @("xtensa-esp32s3-elf", "xtensa-esp-elf")

# RISC-V: C3 / C6 / H2
Setup-Triple $riscv "riscv32-esp-elf"     @("riscv32-esp-elf")
Setup-Triple $riscv "riscv32-esp32-elf"   @("riscv32-esp32-elf", "riscv32-esp-elf")
Setup-Triple $riscv "riscv32-esp32c3-elf" @("riscv32-esp32c3-elf", "riscv32-esp-elf")

Write-Host ""
Write-Host "Ready: $Dest"
Get-ChildItem $Dest | Select-Object -ExpandProperty Name
