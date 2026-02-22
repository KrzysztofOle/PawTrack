cmake_minimum_required(VERSION 3.20.0)

find_package(Zephyr REQUIRED HINTS $ENV{ZEPHYR_BASE})
project(PawTrack)

target_include_directories(app PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/include)

add_subdirectory(src/modules/imu)
add_subdirectory(src/modules/power)
add_subdirectory(src/modules/ble)

target_sources(app PRIVATE src/main.c)
