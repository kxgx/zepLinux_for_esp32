#!/usr/bin/env bash
# Generic zepLinux build for any ESP32-family board (Linux/macOS).
# Usage: ./scripts/build_esp32_family.sh esp32s3_devkitm/esp32s3/procpu
#        ./scripts/build_esp32_family.sh esp32c3_devkitc
set -euo pipefail

BOARD="${1:?board required, e.g. esp32s3_devkitm/esp32s3/procpu}"
SAMPLE="${2:-zephyr/samples/ansilic/esp32s3_zeplinux_tests}"
REPO="$(cd "$(dirname "$0")/.." && pwd)"
TOOLCHAIN="${ESPRESSIF_TOOLCHAIN_PATH:-$HOME/zephyr-esp-tc}"
BUILD="$REPO/build-$(echo "$BOARD" | tr '/\\:' '---')"
OVERLAY="${OVERLAY:-}"

if [ ! -d "$TOOLCHAIN" ]; then
  echo "Toolchain missing: $TOOLCHAIN (run prepare_toolchain.ps1 / install west espressif)"
  exit 1
fi

export ZEPHYR_TOOLCHAIN_VARIANT=espressif
export ESPRESSIF_TOOLCHAIN_PATH="$TOOLCHAIN"

EXTRA=(-DKCONFIG_WARNINGS_AS_ERRORS=n)
if [ -n "$OVERLAY" ]; then
  EXTRA=(-DDTC_OVERLAY_FILE="$OVERLAY" -DKCONFIG_WARNINGS_AS_ERRORS=n)
fi

echo "Board=$BOARD Sample=$SAMPLE Build=$BUILD Toolchain=$TOOLCHAIN"
cd "$REPO"
west build -p always -b "$BOARD" -d "$BUILD" "$SAMPLE" -- "${EXTRA[@]}"
echo "Image: $BUILD/zephyr/zephyr.bin"
