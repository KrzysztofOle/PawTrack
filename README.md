# 🐾 PawTrack — Smart Activity & GPS Tracker for Pets (and Beyond)

PawTrack is a versatile **GPS-based activity tracker** designed to monitor your dog’s walks, routes, and motion patterns — but its use doesn’t stop there. Built with energy-efficient hardware and intelligent motion detection, PawTrack is ideal for any **battery-powered outdoor tracking application**.

## 🧠 Key features

- 📍 **Precise GPS logging** — record, store, and visualize outdoor routes
- 🐕 **Motion detection** — wake-on-motion logic minimizes power draw
- 🔋 **Low power consumption** — deep-sleep modes and smart sensors for long battery life
- 📊 **Synchronization & visualization** — upload data to your web platform for mapping and analytics
- 🌍 **Extendable architecture** — perfect for tracking pets, bikes, outdoor equipment, or personal assets

Whether you’re building a **pet activity tracking system**, enhancing your IoT skills, or creating your own sensor-enabled device, PawTrack provides an open-source foundation you can customize and expand.

## Zephyr app layout

This repository now includes a Zephyr-native application layout:

- `CMakeLists.txt` and `prj.conf` at project root
- `src/main.c` as the app entry point
- `src/modules/imu`, `src/modules/power`, and `src/modules/ble` for module-specific logic
- `include/pawtrack/*.h` for module interfaces

## Build and flash with west

Use a Zephyr workspace shell where `west` is installed and `ZEPHYR_BASE` is available.

```sh
west build -b seeed_xiao_mg24 -d build/seeed_xiao_mg24 .
west flash -d build/seeed_xiao_mg24
```

Note: if your local setup exposes this board as `xiao_mg24`, use that board name in place of `seeed_xiao_mg24`.
