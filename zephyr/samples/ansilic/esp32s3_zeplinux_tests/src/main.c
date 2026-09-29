/* zepLinux test runner — ESP32 family */
#include <zephyr/ztest.h>
#include <zephyr/kernel.h>
#include <zephyr/sys/printk.h>

ZTEST_SUITE(zeplinux_process, NULL, NULL, NULL, NULL, NULL);

void test_main(void)
{
	printk("zepLinux: test_main entry\n");
	k_msleep(50);
	ztest_run_all(NULL, false, 1, 1);
	printk("zepLinux: test_main done\n");
}
