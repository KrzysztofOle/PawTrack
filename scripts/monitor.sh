#!/usr/bin/env sh
set -eu

BAUD="${BAUD:-115200}"
SERIAL_PORT="${SERIAL_PORT:-}"
MONITOR_WAIT_SECONDS="${MONITOR_WAIT_SECONDS:-10}"

resolve_serial_port() {
	for candidate in \
		/dev/cu.usbmodem* \
		/dev/cu.usbserial* \
		/dev/cu.SLAB_USBtoUART* \
		/dev/cu.wchusbserial* \
		/dev/tty.usbmodem* \
		/dev/tty.usbserial* \
		/dev/tty.SLAB_USBtoUART* \
		/dev/tty.wchusbserial*
	do
		if [ -e "${candidate}" ]; then
			echo "${candidate}"
			return 0
		fi
	done

	return 1
}

print_usage() {
	echo "Usage: $0 [--print-port]"
	echo "Environment variables:"
	echo "  SERIAL_PORT   Override detected serial device path"
	echo "  BAUD          UART baud rate (default: 115200)"
	echo "  MONITOR_WAIT_SECONDS  Time to wait for serial port (default: 10)"
}

wait_for_port() {
	tries=$((MONITOR_WAIT_SECONDS * 10))

	while [ "${tries}" -gt 0 ]; do
		if [ -e "${PORT}" ]; then
			return 0
		fi
		tries=$((tries - 1))
		sleep 0.1
	done

	return 1
}

configure_port_raw() {
	tries=$((MONITOR_WAIT_SECONDS * 10))

	while [ "${tries}" -gt 0 ]; do
		if stty -f "${PORT}" "${BAUD}" cs8 -cstopb -parenb -ixon -ixoff raw -echo 2>/dev/null; then
			return 0
		fi
		tries=$((tries - 1))
		sleep 0.1
	done

	return 1
}

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
	print_usage
	exit 0
fi

PORT="${SERIAL_PORT:-$(resolve_serial_port || true)}"
if [ -z "${PORT}" ]; then
	echo "ERROR: serial port not found."
	echo "Set SERIAL_PORT=/dev/cu.usbmodemXXXX and retry."
	exit 1
fi

if ! wait_for_port; then
	echo "ERROR: serial port ${PORT} did not appear within ${MONITOR_WAIT_SECONDS}s."
	exit 1
fi

if [ "${1:-}" = "--print-port" ]; then
	echo "${PORT}"
	exit 0
fi

if [ "${1:-}" != "" ]; then
	print_usage
	exit 1
fi

echo "Monitoring ${PORT} at ${BAUD} baud."
echo "Stop monitor with Ctrl-C (or tool-specific quit sequence)."

# In non-interactive task terminals, screen exits immediately.
if [ ! -t 0 ] || [ ! -t 1 ]; then
	if ! configure_port_raw; then
		echo "ERROR: failed to configure serial port ${PORT}."
		echo "Check if another process is using the device."
		exit 1
	fi
	exec cat "${PORT}"
fi

# Prefer dedicated serial monitors when available.
if command -v tio >/dev/null 2>&1; then
	exec tio -b "${BAUD}" "${PORT}"
fi

if command -v picocom >/dev/null 2>&1; then
	exec picocom -b "${BAUD}" "${PORT}"
fi

if command -v screen >/dev/null 2>&1; then
	exec screen "${PORT}" "${BAUD}"
fi

# Final fallback when pyserial is installed.
if command -v python3 >/dev/null 2>&1 && python3 -c "import serial" >/dev/null 2>&1; then
	exec python3 -m serial.tools.miniterm "${PORT}" "${BAUD}"
fi

if configure_port_raw; then
	exec cat "${PORT}"
fi

echo "ERROR: no monitor tool found (install tio, picocom, screen, or pyserial)."
exit 127
