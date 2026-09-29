# SPDX-License-Identifier: Apache-2.0
#
# Espressif toolchain target selection — whole ESP32 family.
# Maps (ARCH, SOC series) → gcc triple, and locates it under
# ESPRESSIF_TOOLCHAIN_PATH.

zephyr_get(ESPRESSIF_TOOLCHAIN_PATH)
assert(    ESPRESSIF_TOOLCHAIN_PATH "ESPRESSIF_TOOLCHAIN_PATH is not set")

set(COMPILER gcc)
set(LINKER ld)
set(BINTOOLS gnu)

# --- family map: ${ARCH}_${CONFIG_SOC_SERIES} → triple ---
set(CROSS_COMPILE_TARGET_xtensa_esp32     xtensa-esp32-elf)
set(CROSS_COMPILE_TARGET_xtensa_esp32s2   xtensa-esp32s2-elf)
set(CROSS_COMPILE_TARGET_xtensa_esp32s3   xtensa-esp32s3-elf)
# RISC-V line (C3 / C6 / H2 / …) shares the riscv32-esp-elf toolchain
set(CROSS_COMPILE_TARGET_riscv_esp32c3    riscv32-esp-elf)
set(CROSS_COMPILE_TARGET_riscv_esp32c6    riscv32-esp-elf)
set(CROSS_COMPILE_TARGET_riscv_esp32h2    riscv32-esp-elf)
set(CROSS_COMPILE_TARGET_riscv_esp32c2    riscv32-esp-elf)
set(CROSS_COMPILE_TARGET_riscv_esp8684    riscv32-esp-elf)

set(_key ${ARCH}_${CONFIG_SOC_SERIES})
set(CROSS_COMPILE_TARGET ${CROSS_COMPILE_TARGET_${_key}})
set(SYSROOT_TARGET       ${CROSS_COMPILE_TARGET})

# Fallback: any available triple if the map misses a new series
if(NOT CROSS_COMPILE_TARGET)
  if(ARCH STREQUAL "riscv")
    set(CROSS_COMPILE_TARGET riscv32-esp-elf)
  else()
    set(CROSS_COMPILE_TARGET xtensa-esp-elf)
  endif()
  set(SYSROOT_TARGET ${CROSS_COMPILE_TARGET})
  message(WARNING "Espressif: no map for ${_key}, using ${CROSS_COMPILE_TARGET}")
endif()

# Layout A (preferred): <PATH>/<triple>/bin/<triple>-gcc
# Layout B (legacy):     <PATH>/bin/<triple>-gcc
if(ESPRESSIF_DEPRECATED_PATH)
  set(TOOLCHAIN_HOME ${ESPRESSIF_TOOLCHAIN_PATH})
else()
  set(TOOLCHAIN_HOME ${ESPRESSIF_TOOLCHAIN_PATH}/${CROSS_COMPILE_TARGET})
endif()

# If preferred layout missing, try the other one
if(NOT EXISTS "${TOOLCHAIN_HOME}/bin/${CROSS_COMPILE_TARGET}-gcc"
   AND NOT EXISTS "${TOOLCHAIN_HOME}/bin/${CROSS_COMPILE_TARGET}-gcc.exe")
  if(EXISTS "${ESPRESSIF_TOOLCHAIN_PATH}/bin/${CROSS_COMPILE_TARGET}-gcc"
     OR EXISTS "${ESPRESSIF_TOOLCHAIN_PATH}/bin/${CROSS_COMPILE_TARGET}-gcc.exe")
    set(ESPRESSIF_DEPRECATED_PATH TRUE)
    set(TOOLCHAIN_HOME ${ESPRESSIF_TOOLCHAIN_PATH})
  endif()
endif()

set(CROSS_COMPILE ${TOOLCHAIN_HOME}/bin/${CROSS_COMPILE_TARGET}-)
set(SYSROOT_DIR   ${TOOLCHAIN_HOME}/${SYSROOT_TARGET})

set(TOOLCHAIN_HAS_NEWLIB ON CACHE BOOL "True if toolchain supports newlib")

message(STATUS "Found toolchain: espressif (${ESPRESSIF_TOOLCHAIN_PATH}) triple=${CROSS_COMPILE_TARGET}")
