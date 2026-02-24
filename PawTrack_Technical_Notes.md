# PawTrack -- Technical Design Notes

**Document version:** 1.0\
**Last updated:** 2026-02-24

------------------------------------------------------------------------

## 1. Project Overview

PawTrack is an ultra-low-power GPS tracking device designed to:

-   Track dog movement using GNSS
-   Detect motion start/stop using ADXL345
-   Operate primarily in deep sleep (EM4)
-   Synchronize data after returning home

Target MCU: **Seeed XIAO MG24 (EFR32MG24)**\
Framework: **Zephyr RTOS**

------------------------------------------------------------------------

# 2. Battery Management

## 2.1 Hardware Configuration

Battery type: **Li-Po 3.7V (3.0V -- 4.2V)**\
Connection: Dedicated BAT connector on XIAO MG24 board

The board includes:

-   TPS22916 load switch
-   Voltage divider: 10kΩ / 10kΩ (1/2 scaling)
-   ADC input: PD04 (VBAT_ADC)
-   Control pin: PD03 (VBAT_CTL)

### Measurement Formula

V_bat = 2 × V_adc

------------------------------------------------------------------------

## 2.2 Measurement Procedure (Low Power Policy)

1.  Set `VBAT_CTL` HIGH to enable load switch.
2.  Wait 5 ms for stabilization.
3.  Perform ADC measurement on PD04.
4.  Set `VBAT_CTL` LOW to disable measurement path.

Measurement is performed only: - At system startup - Before GPS
synchronization - Before entering long EM4 sleep

Continuous polling is not allowed.

------------------------------------------------------------------------

## 2.3 Power Consumption Strategy

  State             Divider Current
  ----------------- ------------------------
  Sleep (EM4)       \~0 µA
  Measurement       Active only for \~5 ms
  Continuous mode   Not allowed

Design goal: Zero static current from voltage divider.

------------------------------------------------------------------------

# 3. Motion Detection Architecture

Primary wake-up source: **ADXL345 interrupt (INT1/INT2)**

System behavior:

1.  MCU in EM4
2.  ADXL345 detects motion
3.  Interrupt wakes MCU
4.  GNSS module powered ON
5.  Track logging starts
6.  Motion stop detected → return to sleep

Event-driven architecture only. No continuous IMU polling.

------------------------------------------------------------------------

# 4. GNSS Operation Policy

Module: L76K GNSS

-   Enabled only after motion detection
-   Data buffered locally
-   Synchronization performed after return home

GNSS must not run during stationary state.

------------------------------------------------------------------------

# 5. Low Power Design Rules

-   Prefer hardware interrupts
-   Use EM4 whenever possible
-   Avoid polling loops
-   Avoid periodic wakeups unless strictly required
-   ADC and peripherals enabled only when needed

------------------------------------------------------------------------

# 6. Future Technical Extensions

-   Battery percentage estimation curve (Li-Po discharge profile)
-   Brown-out protection logic
-   GPS block below critical voltage threshold
-   Dynamic sampling based on motion intensity

------------------------------------------------------------------------

# 7. Change Log

  Version   Date         Description
  --------- ------------ ---------------------------------
  1.0       2026-02-24   Initial technical documentation
