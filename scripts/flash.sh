#!/usr/bin/env sh
set -eu

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
APP_DIR="$(CDPATH= cd -- "${SCRIPT_DIR}/.." && pwd)"
WORKSPACE_DIR="$(CDPATH= cd -- "${APP_DIR}/../.." && pwd)"
BUILD_DIR="${BUILD_DIR:-${APP_DIR}/build}"
HEX_FILE="${HEX_FILE:-${BUILD_DIR}/zephyr/zephyr.hex}"
ZEPHYR_BASE_DIR="${ZEPHYR_BASE:-${WORKSPACE_DIR}/zephyr}"
BOARD_CFG="${BOARD_CFG:-${ZEPHYR_BASE_DIR}/boards/seeed/xiao_mg24/support/openocd.cfg}"

if [ ! -f "${HEX_FILE}" ]; then
	"${SCRIPT_DIR}/build.sh"
fi

resolve_arduino_openocd() {
	base="${HOME}/Library/Arduino15/packages/SiliconLabs/tools/openocd"
	latest=""

	if [ ! -d "${base}" ]; then
		return
	fi

	latest="$(ls -1d "${base}"/* 2>/dev/null | sort | tail -n 1 || true)"
	if [ -z "${latest}" ]; then
		return
	fi

	if [ -x "${latest}/bin/openocd" ] && [ -d "${latest}/share/openocd/scripts" ]; then
		echo "${latest}"
	fi
}

OPENOCD_ROOT="${OPENOCD_ROOT:-$(resolve_arduino_openocd)}"
OPENOCD_BIN="${OPENOCD_BIN:-${OPENOCD_ROOT:+${OPENOCD_ROOT}/bin/openocd}}"
OPENOCD_SCRIPTS="${OPENOCD_SCRIPTS:-${OPENOCD_ROOT:+${OPENOCD_ROOT}/share/openocd/scripts}}"

if [ -n "${OPENOCD_BIN}" ] && [ -x "${OPENOCD_BIN}" ] && \
	[ -n "${OPENOCD_SCRIPTS}" ] && [ -d "${OPENOCD_SCRIPTS}" ] && \
	[ -f "${BOARD_CFG}" ]; then
	exec "${OPENOCD_BIN}" \
		-s "$(dirname "${BOARD_CFG}")" \
		-s "${OPENOCD_SCRIPTS}" \
		-f "${BOARD_CFG}" \
		-c init \
		-c targets \
		-c "reset init" \
		-c "flash write_image erase ${HEX_FILE}" \
		-c "verify_image ${HEX_FILE}" \
		-c "reset run" \
		-c shutdown
fi

# Safe fallback when OpenOCD package is not available.
exec "${SCRIPT_DIR}/westw" flash \
	--build-dir "${BUILD_DIR}" \
	--skip-rebuild
