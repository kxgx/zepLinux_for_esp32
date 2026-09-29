/* zepLinux kernel / process-model smoke tests (no newlib pthread) */
#include <zephyr/ztest.h>
#include <zephyr/kernel.h>
#include <zephyr/sys/printk.h>

#define STACK_SZ 1024
static K_THREAD_STACK_DEFINE(worker_stack, STACK_SZ);
static struct k_thread worker_thread;
static volatile int g_worker_done;

static void worker_entry(void* a, void* b, void* c)
{
	ARG_UNUSED(a);
	ARG_UNUSED(b);
	ARG_UNUSED(c);
	g_worker_done = 1;
}

ZTEST(zeplinux_process, test_current_thread)
{
	k_tid_t tid = k_current_get();
	zassert_not_null(tid, "current thread");
	printk("current thread ok\n");
}

ZTEST(zeplinux_process, test_kthread_join_like)
{
	g_worker_done = 0;
	k_tid_t tid = k_thread_create(&worker_thread, worker_stack, STACK_SZ,
				      worker_entry, NULL, NULL, NULL,
				      K_PRIO_PREEMPT(5), 0, K_NO_WAIT);
	zassert_not_null(tid, "k_thread_create");
	/* wait for flag */
	for (int i = 0; i < 50 && !g_worker_done; i++) {
		k_msleep(2);
	}
	zassert_equal(g_worker_done, 1, "worker should have run");
	printk("kthread ok\n");
}

ZTEST(zeplinux_process, test_sleep_ms)
{
	int64_t t0 = k_uptime_get();
	k_msleep(20);
	int64_t dt = k_uptime_get() - t0;
	zassert_true(dt >= 15, "sleep too short: %lld", (long long)dt);
	printk("k_msleep ok dt=%lld\n", (long long)dt);
}

ZTEST(zeplinux_process, test_fifo_sem)
{
	struct k_sem sem;
	k_sem_init(&sem, 0, 1);
	zassert_equal(k_sem_count_get(&sem), 0, "sem empty");
	k_sem_give(&sem);
	zassert_equal(k_sem_count_get(&sem), 1, "sem given");
	printk("sem ok\n");
}
