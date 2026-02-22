#include <zephyr/bluetooth/bluetooth.h>
#include <zephyr/logging/log.h>

#include <pawtrack/ble.h>

LOG_MODULE_REGISTER(pawtrack_ble, LOG_LEVEL_INF);

int pawtrack_ble_init(void)
{
#if IS_ENABLED(CONFIG_BT)
	int err = bt_enable(NULL);

	if (err != 0) {
		LOG_ERR("Bluetooth init failed (%d)", err);
		return err;
	}

	LOG_INF("BLE module placeholder initialized");
#else
	LOG_WRN("CONFIG_BT is disabled; BLE module in placeholder mode");
#endif

	return 0;
}

void pawtrack_ble_process(void)
{
	/* TODO: Handle advertising, connections, and telemetry payloads. */
	LOG_DBG("BLE placeholder tick");
}
