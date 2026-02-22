# Zasady pracy asystenta (AGENTS)

Twoje zadanie: Wspieraj mnie (Krzysztofa) w rozwoju projektu "PawTrack"
zgodnie z poniższymi zasadami.

Projekt: 🐾 PawTrack\
Środowisko: Zephyr RTOS + west + CMake\
Toolchain: zephyr-sdk-0.17.4\
Architektura: Seeed XIAO MG24 (EFR32MG24) + L76K GNSS + ADXL345

------------------------------------------------------------------------

## Ogólne zasady pracy

1. Odpowiadaj zawsze po polsku.
2. Formatuj wszystkie odpowiedzi w Markdown.
3. Kod generuj w języku C/C++ zgodnie z konwencją Zephyr.
4. Komentarze w kodzie zawsze po angielsku.
5. Dokumentacja:
    - README.md → angielski
    - README_PL.md → polski
6. Kod powinien być modularny i zgodny z architekturą Zephyr.
7. Preferuj rozwiązania event-driven.
8. Nie stosuj aktywnego polling, jeśli możliwe są przerwania sprzętowe.
9. Zmiany wprowadzaj stopniowo.
10. Nie wykonuj operacji git (commit/push) bez wyraźnego polecenia.

------------------------------------------------------------------------

## Architektura systemu (obowiązkowy model działania)

ADXL345 jest głównym elementem wake-on-motion.

Model działania:

1. MCU w deep sleep (EM4)
2. ADXL345 monitoruje ruch
3. Generuje przerwanie (INT1/INT2)
4. GPIO wybudza MCU
5. Uruchomienie GNSS (L76K)
6. Logowanie danych
7. Po bezruchu → powrót do sleep

System ma być ultra-low-power.

Nie proponuj: - ciągłego odczytu IMU w pętli - częstego budzenia MCU -
aktywnego polling GNSS

------------------------------------------------------------------------

## Struktura projektu (Zephyr)

PawTrack/ src/ main.c boards/ include/ CMakeLists.txt prj.conf README.md
README_PL.md

Modularne pliki:

- motion_detector.c / .h
- gps_manager.c / .h
- power_manager.c / .h

------------------------------------------------------------------------

## Zasady generowania kodu

1. Zgodność z Zephyr API.
2. Wykorzystuj:
    - device tree
    - k_work
    - k_timer (jeśli potrzebne)
    - GPIO interrupts
3. Low power:
    - Zephyr Power Management
    - EM4 jako preferowany tryb
    - Wyłączanie nieużywanych peryferiów

Przykład stylu:

// Configure ADXL345 for activity detection void
motion_detector_init(void) { // Initialize I2C device and configure
interrupts }

------------------------------------------------------------------------

## GPS -- zasady

1. GNSS aktywowany wyłącznie po wykryciu ruchu.
2. Dane buforowane lokalnie.
3. Synchronizacja możliwa po powrocie do domu.
4. GNSS wyłączony w stanie bezruchu.

------------------------------------------------------------------------

## README.md (EN)

Powinien zawierać:

1. Project Overview
2. Features
3. Hardware Requirements
4. Wiring Diagram
5. Software Setup (west + Zephyr SDK)
6. Build & Flash
7. Usage
8. Low Power Architecture
9. Contributing
10. License

README_PL.md

Identyczna struktura --- pełne tłumaczenie.

------------------------------------------------------------------------

## Testowanie (Zephyr)

1. Używaj ztest.
2. Testuj:
    - logikę wykrywania ruchu
    - maszynę stanów systemu
3. Opisuj jak uruchomić testy przez west.
4. Nie rozwijaj nowych funkcji przed przejściem testów.

------------------------------------------------------------------------

## Zarządzanie zmianami

1. Nie twórz changeloga automatycznie.
2. Commit message generuj tylko na polecenie.
3. Opis commita prezntuj w bloku kodu i formatowaniem .md
4. Format:

```markdown
    # **PawTrack**

    Krótki opis zmian.

    Sekcje dla plików: - Lista zmian - Krótkie techniczne uzasadnienie

    Styl: techniczny, bez emotikonów.
```

------------------------------------------------------------------------

## Precedencja zasad

„Najbliższy AGENTS.md wygrywa".

Jeżeli w podkatalogu znajduje się osobny AGENTS.md, stosuj jego zasady
zamiast głównego.

Nie łącz reguł między dokumentami. W razie konfliktu --- zgłoś do
wyjaśnienia.
