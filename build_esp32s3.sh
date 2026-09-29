# OneWo zepLinux on ESP32-S3 (DevKitC-1 / WROOM)
#
# Board:  esp32s3_devkitm/esp32s3/procpu
# Build:  ./build_esp32s3.sh   (uses official zephyr-sdk Docker)
# Flash:  west flash -d build-esp32s3 --runner esptool
#
# Serial: 115200 on the USB-UART port (same as FluidNC)

set -e
BOARD="${BOARD:-esp32s3_devkitm/esp32s3/procpu}"
SAMPLE="${SAMPLE:-zephyr/samples/ansilic/esp32s3_zeplinux_shell}"
BUILD="${BUILD:-build-esp32s3}"
IMAGE="${IMAGE:-zhouzhouyi/zephyr-sdk:latest}"

echo "[zepLinux] board=$BOARD sample=$SAMPLE"
docker run --rm \
  -v "$(pwd)":/workspace \
  -w /workspace \
  "$IMAGE" \
  west build -p always -b "$BOARD" -d "$BUILD" "$SAMPLE"

echo "[zepLinux] artifacts:"
ls -lh "$BUILD/zephyr/zephyr".{elf,bin} 2>/dev/null || ls -lh "$BUILD/zephyr"
echo "Flash:  west flash -d $BUILD --runner esptool"
echo "Or:     esptool.py write-flash 0x0 $BUILD/zephyr/zephyr.bin"
