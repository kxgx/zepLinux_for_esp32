# SPDX-License-Identifier: Apache-2.0
#
# Espressif toolchain discovery for Zephyr / zepLinux — ESP32 family.
#
# Expected layout under ESPRESSIF_TOOLCHAIN_PATH:
#   <PATH>/<triple>/bin/<triple>-gcc
#   <PATH>/<triple>/<triple>            (sysroot, optional)
#
# Or legacy flat:  <PATH>/bin/<triple>-gcc
#
# Optional: -DESPRESSIF_CROSS_COMPILE=riscv32-esp-elf  (force one triple)

zephyr_get(ESPRESSIF_TOOLCHAIN_PATH)
assert(    ESPRESSIF_TOOLCHAIN_PATH "ESPRESSIF_TOOLCHAIN_PATH is not set")

set(TOOLCHAIN_HOME ${ESPRESSIF_TOOLCHAIN_PATH})

set(COMPILER gcc)
set(LINKER ld)
set(BINTOOLS gnu)

zephyr_get(ESPRESSIF_CROSS_COMPILE)

# Triples used by the ESP32 family (Xtensa + RISC-V)
set(_espressif_triples
  xtensa-esp-elf
  xtensa-esp32-elf
  xtensa-esp32s2-elf
  xtensa-esp32s3-elf
  riscv32-esp-elf
  riscv32-esp32-elf
  riscv32-esp32c3-elf
  riscv32-esp32c6-elf
  riscv32-esp32h2-elf
)

# Architecture hint (available after board/soc selection)
set(_prefer_riscv FALSE)
set(_prefer_xtensa FALSE)
if(CONFIG_RISCV OR CONFIG_SOC_SERIES_ESP32C3 OR CONFIG_SOC_SERIES_ESP32C6 OR CONFIG_SOC_SERIES_ESP32H2)
  set(_prefer_riscv TRUE)
elseif(CONFIG_XTENSA OR CONFIG_SOC_SERIES_ESP32 OR CONFIG_SOC_SERIES_ESP32S2 OR CONFIG_SOC_SERIES_ESP32S3)
  set(_prefer_xtensa TRUE)
endif()

set(_best_score -1)
set(_best_root "")
set(_best_name "")
set(_best_deprecated FALSE)

foreach(triple ${_espressif_triples})
  if(DEFINED ESPRESSIF_CROSS_COMPILE AND NOT "${ESPRESSIF_CROSS_COMPILE}" STREQUAL ""
     AND NOT "${triple}" STREQUAL "${ESPRESSIF_CROSS_COMPILE}")
    continue()
  endif()

  # New layout: <home>/<triple>/bin/<triple>-gcc
  set(_root "${TOOLCHAIN_HOME}/${triple}")
  set(_deprecated FALSE)
  set(_gcc "")
  if(EXISTS "${_root}/bin/${triple}-gcc" OR EXISTS "${_root}/bin/${triple}-gcc.exe")
    set(_gcc "${_root}/bin/${triple}-gcc")
  elseif(EXISTS "${TOOLCHAIN_HOME}/bin/${triple}-gcc" OR EXISTS "${TOOLCHAIN_HOME}/bin/${triple}-gcc.exe")
    # Legacy flat layout
    set(_root "${TOOLCHAIN_HOME}")
    set(_gcc "${TOOLCHAIN_HOME}/bin/${triple}-gcc")
    set(_deprecated TRUE)
  endif()
  if(_gcc STREQUAL "")
    continue()
  endif()

  set(_score 10)
  if(_prefer_riscv AND triple MATCHES "riscv")
    math(EXPR _score "${_score} + 50")
  elseif(_prefer_xtensa AND triple MATCHES "xtensa")
    math(EXPR _score "${_score} + 50")
  endif()
  # Prefer more specific triple names (xtensa-esp32s3-elf > xtensa-esp-elf)
  string(LENGTH "${triple}" _len)
  math(EXPR _score "${_score} + ${_len}")

  if(_score GREATER _best_score)
    set(_best_score ${_score})
    set(_best_root "${_root}")
    set(_best_name "${triple}")
    set(_best_deprecated ${_deprecated})
  endif()
endforeach()

if(_best_name STREQUAL "")
  message(FATAL_ERROR
    "No Espressif toolchain found under ${TOOLCHAIN_HOME}.\n"
    "Need e.g. ${TOOLCHAIN_HOME}/riscv32-esp-elf/bin/riscv32-esp-elf-gcc\n"
    "     or  ${TOOLCHAIN_HOME}/xtensa-esp-elf/bin/xtensa-esp-elf-gcc\n"
    "Run scripts/prepare_toolchain.ps1, or `west espressif install`.\n"
    "Optional: -DESPRESSIF_CROSS_COMPILE=<triple> to force a triple.")
endif()

set(CROSS_COMPILE_TARGET ${_best_name})
set(SYSROOT_TARGET       ${_best_name})

if(_best_deprecated)
  set(CROSS_COMPILE ${ESPRESSIF_TOOLCHAIN_PATH}/bin/${CROSS_COMPILE_TARGET}-)
  set(SYSROOT_DIR   ${ESPRESSIF_TOOLCHAIN_PATH}/${SYSROOT_TARGET})
else()
  set(CROSS_COMPILE ${_best_root}/bin/${CROSS_COMPILE_TARGET}-)
  set(SYSROOT_DIR   ${_best_root}/${SYSROOT_TARGET})
endif()

message(STATUS "Espressif toolchain: ${CROSS_COMPILE}gcc")

set(TOOLCHAIN_HAS_NEWLIB ON CACHE BOOL "True if toolchain supports newlib")
