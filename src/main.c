#include <zephyr/kernel.h>
#include <zephyr/logging/log.h>
#include <zephyr/sys/printk.h>

#include <pawtrack/ble.h>
#include <pawtrack/imu.h>
#include <pawtrack/power.h>

LOG_MODULE_REGISTER(pawtrack_main, LOG_LEVEL_INF);

static int pawtrack_modules_init(void)
{
	int err;

	err = pawtrack_imu_init();
	if (err != 0) {
		LOG_ERR("IMU init failed (%d)", err);
		return err;
	}

	err = pawtrack_power_init();
	if (err != 0) {
		LOG_ERR("Power init failed (%d)", err);
		return err;
	}

	err = pawtrack_ble_init();
	if (err != 0) {
		LOG_ERR("BLE init failed (%d)", err);
		return err;
	}

	return 0;
}

int main(void)
{
	printk("Hello World from PawTrack on %s\n", CONFIG_BOARD);

	if (pawtrack_modules_init() != 0) {
		LOG_ERR("Module initialization failed; staying alive for debug");
	}

	while (1) {
		pawtrack_imu_process();
		pawtrack_power_process();
		pawtrack_ble_process();
		k_sleep(K_SECONDS(5));
	}

	return 0;
}
