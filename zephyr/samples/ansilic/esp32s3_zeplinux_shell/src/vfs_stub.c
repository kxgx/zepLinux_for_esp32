// VFS stubs for ESP32-S3 (ramfs/VFS temporarily disabled)
#include <zephyr/kernel.h>
#include <stddef.h>
#include <stdint.h>

int cmd_ls_vfs(int argc, char** argv) {
    ARG_UNUSED(argc);
    ARG_UNUSED(argv);
    printk("ls: VFS disabled on this build\n");
    return 0;
}

// Minimal POSIX-ish FS API stubs used by shell commands
int fs_open(const char* path, int flags, ...) {
    ARG_UNUSED(path);
    ARG_UNUSED(flags);
    return -1;
}

int fs_write(int fd, const void* buf, size_t len) {
    ARG_UNUSED(fd);
    ARG_UNUSED(buf);
    ARG_UNUSED(len);
    return -1;
}

int fs_close(int fd) {
    ARG_UNUSED(fd);
    return -1;
}
