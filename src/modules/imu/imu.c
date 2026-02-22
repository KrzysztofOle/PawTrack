#include <zephyr/logging/log.h>

#include <pawtrack/imu.h>

LOG_MODULE_REGISTER(pawtrack_imu, LOG_LEVEL_INF);

int pawtrack_imu_init(void)
{
	LOG_INF("IMU module placeholder initialized");
	return 0;
}

void pawtrack_imu_process(void)
{
	/* TODO: Read and process IMU data. */
	LOG_DBG("IMU placeholder tick");
}
