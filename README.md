# zepLinux for ESP32

**OneWo-zepLinux**锛圸ephyr RTOS + Linux API 鍏煎灞傦級鐨?**ESP32 鍏ㄧ郴鍒楃Щ妞?*銆?

鍦?MCU 涓婅窇 Linux 椋庢牸鎺ュ彛锛歚pthread`銆乣sched_*`銆佽繘绋嬫ā鍨嬨€佷俊鍙枫€乂FS 绛夛紝鍚屾椂淇濈暀 Zephyr 鐨勮交閲忎笌纭疄鏃躲€?

| 鑺墖 | 鏋舵瀯 | 绀轰緥鏉跨骇 | 鏋勫缓 |
|------|------|----------|------|
| ESP32 | Xtensa | `esp32_devkitc` | 鉁?|
| ESP32-S2 | Xtensa | `esp32s2_devkitc` | 鉁?|
| ESP32-S3 | Xtensa | `esp32s3_devkitm` | 鉁?瀹炴祴 |
| ESP32-C3 | RISC-V | `esp32c3_devkitc` | 鉁?|
| ESP32-C6 | RISC-V | `esp32c6_devkitc` | 鉁?|
| ESP32-H2 | RISC-V | `esp32h2_devkitm` | 鉁?|

## 鐗规€?

- Zephyr 4.x 鍐呮牳 + zepLinux 杩涚▼妯″瀷锛坄CONFIG_PROCESS_MODEL`锛?
- Linux / POSIX 鍏煎鎺ュ彛锛堢嚎绋嬨€佽皟搴︺€佷俊鍙枫€佹枃浠剁瓑锛?
- Espressif TWAI锛圕AN锛夌瓑鐗囦笂澶栬椹卞姩鍙敤
- 鑴氭湰鍖栧伐鍏烽摼鍑嗗 / 澶氭澘缂栬瘧 / 鐑у綍

## 蹇€熷紑濮?

### 1. 鍏嬮殕骞跺垵濮嬪寲

```bash
git clone https://github.com/kxgx/zepLinux_for_esp32.git
cd zepLinux_for_esp32
west init -l zephyr
west update
```

### 2. 鍑嗗宸ュ叿閾?

```powershell
.\scripts\prepare_toolchain.ps1
```

鑷姩鏌ユ壘鏈満 PlatformIO 宸ュ叿閾撅紙`toolchain-xtensa-esp-elf` / `toolchain-riscv32-esp`锛夛紝涔熷彲鐢?`-Root` / `-Dest` 鎸囧畾璺緞銆侺inux 鍙敤 `west espressif install`銆?

### 3. 缂栬瘧锛堜换鎰?ESP32 鏉垮瀷锛?

```powershell
.\scripts\build_esp32_family.ps1 -Board esp32s3_devkitm/esp32s3/procpu
.\scripts\build_esp32_family.ps1 -Board esp32_devkitc
.\scripts\build_esp32_family.ps1 -Board esp32c3_devkitc
.\scripts\build_esp32_family.ps1 -Board esp32s2_devkitc
```

Linux/macOS锛?

```bash
./scripts/build_esp32_family.sh esp32s3_devkitm/esp32s3/procpu
```

浜х墿锛歚build-<board>/zephyr/zephyr.bin`

### 4. 鐑у綍

```powershell
.\scripts\flash.ps1 -Port COM5        # 鎴栬嚜鍔ㄨ瘑鍒覆鍙?
.\scripts\flash.ps1 -Port COM5 -BuildDir build-esp32s3_devkitm-esp32s3-procpu
```

鍙€夛細`-Flash` 鍙傛暟鍦ㄧ紪璇戝悗鐩存帴鐑у綍銆?

## 绀轰緥

| 璺緞 | 璇存槑 |
|------|------|
| `zephyr/samples/ansilic/esp32s3_zeplinux_tests` | 杩涚▼ / 绾跨▼ / 淇″彿閲?ztest |
| `zephyr/samples/ansilic/esp32s3_zeplinux_shell` | 杩涚▼ shell锛堜俊鍙?/ 浣滀笟鎺у埗锛?|

娴嬭瘯杈撳嚭绀轰緥锛圗SP32-S3 瀹炴祴锛夛細

```text
SUITE PASS - 100.00% [zeplinux_process]: pass = 4, fail = 0
PROJECT EXECUTION SUCCESSFUL
```

## 鐩綍缁撴瀯

```text
zepLinux_for_esp32/
鈹溾攢鈹€ zephyr/           # Zephyr + zepLinux 鍐呮牳涓庣ず渚?
鈹溾攢鈹€ scripts/          # 宸ュ叿閾?/ 缂栬瘧 / 鐑у綍
鈹溾攢鈹€ docs/             # 鏂囨。
鈹斺攢鈹€ README_ESP32.md   # 绉绘璇存槑锛堟洿缁嗭級
```

## 璐＄尞涓庤鍙?

鍩轰簬 [ucas-linux/OneWo-zepLinux](https://github.com/ucas-linux/OneWo-zepLinux)  
License: **Apache-2.0**

涓婃父锛歔OneWo-rtLinux](https://www.onewos.com/product/zeplinux)

