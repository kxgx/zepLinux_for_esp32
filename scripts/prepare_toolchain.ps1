# Prepare Espressif toolchain tree for Zephyr (ESP32 family)
# Works on Windows PowerShell; paths are auto-detected.
#
# Usage:
#   .\scripts\prepare_toolchain.ps1
#   .\scripts\prepare_toolchain.ps1 -Root <platformio_packages> -Dest <toolchain_dir>

param(
    [string]$Root = "",
    [string]$Dest = ""
)

$ErrorActionPreference = "Stop"

# --- locate PlatformIO packages (or pass -Root) ---
if (-not $Root) {
    $candidates = @(
        (Join-Path $env:USERPROFILE ".platformio\packages"),
        (Join-Path $env:USERPROFILE ".platformio\packages"),
        "/root/.platformio/packages",
        (Join-Path $HOME ".platformio/packages")
    )
    foreach ($c in $candidates) {
        if (Test-Path (Join-Path $c "toolchain-xtensa-esp-elf")) { $Root = $c; break }
        if (Test-Path (Join-Path $c "toolchain-riscv32-esp")) { $Root = $c; break }
    }
}
if (-not $Root) {
    throw "Cannot find PlatformIO packages. Install PlatformIO toolchains or pass -Root."
}
if (-not $Dest) {
    $Dest = Join-Path $env:USERPROFILE "zephyr-esp-tc"
    if (-not $env:USERPROFILE) { $Dest = Join-Path $HOME "zephyr-esp-tc" }
}

Write-Host "Root=$Root"
Write-Host "Dest=$Dest"

function Link-Dir([string]$src, [string]$dst) {
    if (-not (Test-Path $src)) { return }
    if (Test-Path $dst) { return }
    try {
        New-Item -ItemType Junction -Path $dst -Target $src -ErrorAction Stop | Out-Null
        Write-Host "  link $(Split-Path $dst -Leaf)"
    } catch {
        # fallback: copy is too heavy; try symlink
        New-Item -ItemType SymbolicLink -Path $dst -Target $src -ErrorAction SilentlyContinue | Out-Null
    }
}

function Ensure-Toolchain([string]$pkgName, [string[]]$elfNames) {
    $pkg = Join-Path $Root $pkgName
    # PlatformIO may store multiple versions: package@ver
    if (-not (Test-Path $pkg)) {
        $pkg = Get-ChildItem $Root -Directory -Filter "$pkgName*" -ErrorAction SilentlyContinue |
            Select-Object -First 1 -ExpandProperty FullName
    }
    if (-not $pkg) {
        Write-Host "WARN: package not found: $pkgName"
        return
    }
    Write-Host "Using $pkg"
    foreach ($elf in $elfNames) {
        $base = Join-Path $Dest $elf
        New-Item -ItemType Directory -Force -Path $base | Out-Null
        Link-Dir (Join-Path $pkg "bin") (Join-Path $base "bin")
        Link-Dir (Join-Path $pkg "libexec") (Join-Path $base "libexec")
        Link-Dir (Join-Path $pkg "lib") (Join-Path $base "lib")
        Link-Dir (Join-Path $pkg "include") (Join-Path $base "include")
        Link-Dir (Join-Path $pkg "share") (Join-Path $base "share")
        # sysroot dir names vary
        foreach ($sr in @("xtensa-esp-elf", "xtensa-esp32-elf", "xtensa-esp32s2-elf", "xtensa-esp32s3-elf",
                          "riscv32-esp-elf", "riscv32-esp32-elf", "riscv32-esp32c3-elf")) {
            $src = Join-Path $pkg $sr
            if (Test-Path $src) {
                Link-Dir $src (Join-Path $base $sr)
            }
        }
    }
}

# Xtensa: ESP32 / S2 / S3
Ensure-Toolchain "toolchain-xtensa-esp-elf" @(
    "xtensa-esp32-elf",
    "xtensa-esp32s2-elf",
    "xtensa-esp32s3-elf",
    "xtensa-esp-elf"
)

# RISC-V: C3 / C6 / H2
Ensure-Toolchain "toolchain-riscv32-esp" @(
    "riscv32-esp-elf",
    "riscv32-esp32-elf",
    "riscv32-esp32c3-elf"
)

Write-Host ""
Write-Host "Toolchain tree ready: $Dest"
Write-Host "Set ESPRESSIF_TOOLCHAIN_PATH=$Dest when building."
Get-ChildItem $Dest -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Name
