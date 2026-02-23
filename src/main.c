#include <errno.h>
#include <stdbool.h>

#include <zephyr/kernel.h>
#include <zephyr/drivers/gpio.h>
#include <zephyr/logging/log.h>
#include <zephyr/sys/printk.h>

#include <pawtrack/ble.h>
#include <pawtrack/imu.h>
#include <pawtrack/power.h>

LOG_MODULE_REGISTER(pawtrack_main, LOG_LEVEL_INF);

#define LED0_NODE DT_ALIAS(led0)
#define STATUS_LED_BLINK_INTERVAL K_MSEC(150)

static const struct gpio_dt_spec status_led = GPIO_DT_SPEC_GET_OR(LED0_NODE, gpios, {0});
static struct k_work_delayable status_led_blink_work;
static bool status_led_enabled;

static void pawtrack_status_led_toggle(void)
{
	int err;

	if (!status_led_enabled) {
		return;
	}

	err = gpio_pin_toggle_dt(&status_led);
	if (err != 0) {
		LOG_WRN("LED toggle failed (%d)", err);
	}
}

static void pawtrack_status_led_blink_handler(struct k_work *work)
{
	ARG_UNUSED(work);

	pawtrack_status_led_toggle();
	k_work_schedule(&status_led_blink_work, STATUS_LED_BLINK_INTERVAL);
}

static int pawtrack_status_led_init(void)
{
	int err;

	if (!gpio_is_ready_dt(&status_led)) {
		LOG_WRN("LED0 is not available on this board");
		return -ENODEV;
	}

	err = gpio_pin_configure_dt(&status_led, GPIO_OUTPUT_INACTIVE);
	if (err != 0) {
		LOG_ERR("LED configure failed (%d)", err);
		return err;
	}

	status_led_enabled = true;
	k_work_init_delayable(&status_led_blink_work, pawtrack_status_led_blink_handler);
	k_work_schedule(&status_led_blink_work, STATUS_LED_BLINK_INTERVAL);
	return 0;
}

static int pawtrack_modules_init(void)
{
	int err;

	err = pawtrack_status_led_init();
	if (err != 0) {
		LOG_WRN("Status LED disabled (%d)", err);
	}

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
	printk("===============================================\n");
	printk(" Hello World from PawTrack on %s\n", CONFIG_BOARD);
	printk("===============================================\n");

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
