/* zepLinux test runner — ESP32 family */
#include <zephyr/ztest.h>

ZTEST_SUITE(zeplinux_process, NULL, NULL, NULL, NULL, NULL);

void test_main(void)
{
	ztest_run_all(NULL, false, 1, 1);
	/* All suites already reported; do not force fail here. */
}
