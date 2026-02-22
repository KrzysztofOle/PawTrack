#include <zephyr/logging/log.h>

#include <pawtrack/power.h>

LOG_MODULE_REGISTER(pawtrack_power, LOG_LEVEL_INF);

int pawtrack_power_init(void)
{
	LOG_INF("Power module placeholder initialized");
	return 0;
}

void pawtrack_power_process(void)
{
	/* TODO: Apply power policy and sleep heuristics. */
	LOG_DBG("Power placeholder tick");
}
