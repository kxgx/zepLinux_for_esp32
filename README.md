# zepLinux for ESP32

**OneWo-zepLinux**（Zephyr RTOS + Linux API 兼容层）的 **ESP32 全系列移植**。

在 MCU 上跑 Linux 风格接口：`pthread`、`sched_*`、进程模型、信号、VFS 等，同时保留 Zephyr 的轻量与硬实时。

| 芯片 | 架构 | 示例板级 | 构建 |
|------|------|----------|------|
| ESP32 | Xtensa | `esp32_devkitc` | ✓ |
| ESP32-S2 | Xtensa | `esp32s2_devkitc` | ✓ |
| ESP32-S3 | Xtensa | `esp32s3_devkitm` | ✓ 实测 |
| ESP32-C3 | RISC-V | `esp32c3_devkitc` | ✓ |
| ESP32-C6 | RISC-V | `esp32c6_devkitc` | ✓ |
| ESP32-H2 | RISC-V | `esp32h2_devkitm` | ✓ |

## 特性

- Zephyr 4.x 内核 + zepLinux 进程模型（`CONFIG_PROCESS_MODEL`）
- Linux / POSIX 兼容接口（线程、调度、信号、文件等）
- Espressif TWAI（CAN）等片上外设驱动可用
- 脚本化工具链准备 / 多板编译 / 烧录

## 快速开始

### 1. 克隆并初始化

```bash
git clone https://github.com/kxgx/zepLinux_for_esp32.git
cd zepLinux_for_esp32
west init -l zephyr
west update
```

### 2. 准备工具链

```powershell
.\scripts\prepare_toolchain.ps1
```

自动查找本机 PlatformIO 工具链（`toolchain-xtensa-esp-elf` / `toolchain-riscv32-esp`），也可用 `-Root` / `-Dest` 指定路径。Linux 可用 `west espressif install`。

### 3. 编译（任意 ESP32 板型）

```powershell
.\scripts\build_esp32_family.ps1 -Board esp32s3_devkitm/esp32s3/procpu
.\scripts\build_esp32_family.ps1 -Board esp32_devkitc
.\scripts\build_esp32_family.ps1 -Board esp32c3_devkitc
.\scripts\build_esp32_family.ps1 -Board esp32s2_devkitc
```

Linux/macOS：

```bash
./scripts/build_esp32_family.sh esp32s3_devkitm/esp32s3/procpu
```

产物：`build-<board>/zephyr/zephyr.bin`

### 4. 烧录

```powershell
.\scripts\flash.ps1 -Port COM5        # 或自动识别串口
.\scripts\flash.ps1 -Port COM5 -BuildDir build-esp32s3_devkitm-esp32s3-procpu
```

可选：`-Flash` 参数在编译后直接烧录。

## 示例

| 路径 | 说明 |
|------|------|
| `zephyr/samples/ansilic/esp32s3_zeplinux_tests` | 进程 / 线程 / 信号 ztest |
| `zephyr/samples/ansilic/esp32s3_zeplinux_shell` | 进程 shell（信号 / 作业控制） |

测试输出示例（ESP32-S3 实测）：

```text
SUITE PASS - 100.00% [zeplinux_process]: pass = 4, fail = 0
PROJECT EXECUTION SUCCESSFUL
```

## 目录结构

```text
zepLinux_for_esp32/
├── zephyr/           # Zephyr + zepLinux 内核与示例
├── scripts/          # 工具链 / 编译 / 烧录
├── docs/             # 文档
└── README_ESP32.md   # 移植说明（更细）
```

## 贡献与许可

基于 [ucas-linux/OneWo-zepLinux](https://github.com/ucas-linux/OneWo-zepLinux)  
License: **Apache-2.0**

上游：[OneWo-rtLinux](https://www.onewos.com/product/zeplinux)
