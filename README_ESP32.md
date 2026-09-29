# zepLinux for ESP32 family

把 **OneWo-zepLinux**（Zephyr + Linux API 兼容层）移植到 **ESP32 全系列**。

| 芯片 | 架构 | 板级示例 | 状态 |
|------|------|----------|------|
| ESP32 | Xtensa | `esp32_devkitc` / `esp_wrover_kit` | 支持 |
| ESP32-S2 | Xtensa | `esp32s2_devkitc` / `esp32s2_saola` | 支持 |
| ESP32-S3 | Xtensa | `esp32s3_devkitm` / `esp32s3_devkitc` | **已实测** |
| ESP32-C3 | RISC-V | `esp32c3_devkitc` / `esp32c3_devkitm` | 支持 |
| ESP32-C6 | RISC-V | `esp32c6_devkitc` | 支持 |
| ESP32-H2 | RISC-V | `esp32h2_devkitm` | 支持 |

## 功能

- Zephyr 4.x + zepLinux 进程模型（`CONFIG_PROCESS_MODEL`）
- Linux 风格调度 / POSIX 接口（上游）
- 示例：`zephyr/samples/ansilic/esp32s3_zeplinux_tests`（进程 / 线程测试）
- 示例：`zephyr/samples/ansilic/esp32s3_zeplinux_shell`（进程 shell）

## 工具链

推荐 Espressif 统一工具链（PlatformIO 包或 `west espressif install`）：

```
toolchain-xtensa-esp-elf/     # ESP32 / S2 / S3
toolchain-riscv32-esp/        # C3 / C6 / H2
```

构建前准备 `zephyr-esp-tc`（见 `scripts/prepare_toolchain.ps1`）。

## 快速开始

```powershell
# 1) 准备工具链（默认用 PlatformIO 路径）
.\scripts\prepare_toolchain.ps1

# 2) 编译某一板型
.\scripts\build_esp32_family.ps1 -Board esp32s3_devkitm/esp32s3/procpu
.\scripts\build_esp32_family.ps1 -Board esp32_devkitc/esp32/procpu
.\scripts\build_esp32_family.ps1 -Board esp32c3_devkitc/esp32c3/cpuapp

# 3) 烧录
.\scripts\flash.ps1 -Port COM5
```

### TWAI / CAN

ESP32 片上 TWAI 驱动可用（`espressif,esp32-twai`）。CAN 相关协议与电机联调仅在本地开发，不包含在本仓库。

## 目录

```
zepLinux_for_esp32/
├── zephyr/                    # Zephyr + zepLinux 内核
├── modules/                   # hal/espressif 等
├── scripts/                   # 全系构建 / 烧录
└── docs/                      # 移植说明
```

## 测试（ESP32-S3 实测）

```
SUITE PASS  zeplinux_process      4/4
PROJECT EXECUTION SUCCESSFUL
```

构建验证：ESP32-S3 / ESP32 / ESP32-C3

## 上游

基于 [ucas-linux/OneWo-zepLinux](https://github.com/ucas-linux/OneWo-zepLinux)  
License: Apache-2.0
