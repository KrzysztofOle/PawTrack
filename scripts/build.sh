#!/usr/bin/env sh
set -eu

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
APP_DIR="$(CDPATH= cd -- "${SCRIPT_DIR}/.." && pwd)"
BUILD_DIR="${BUILD_DIR:-${APP_DIR}/build}"
BOARD="${BOARD:-xiao_mg24}"
PYTHON_BIN="${PYTHON_BIN:-${HOME}/zephyr_venv/bin/python3}"
PRISTINE_BUILD=0
PRISTINE_MODE="auto"

if [ "${1:-}" = "--pristine" ]; then
	PRISTINE_BUILD=1
	PRISTINE_MODE="always"
	shift
fi

if [ "$#" -gt 0 ]; then
	exec "${SCRIPT_DIR}/westw" build "$@"
fi

if [ "${PRISTINE_BUILD}" -eq 0 ] && [ -f "${BUILD_DIR}/CMakeCache.txt" ]; then
	exec "${SCRIPT_DIR}/westw" build -d "${BUILD_DIR}"
fi

exec "${SCRIPT_DIR}/westw" build \
	-d "${BUILD_DIR}" \
	-b "${BOARD}" \
	-p "${PRISTINE_MODE}" \
	"${APP_DIR}" \
	-- \
	"-DPython3_EXECUTABLE=${PYTHON_BIN}" \
	-DCMAKE_EXPORT_COMPILE_COMMANDS=ON
